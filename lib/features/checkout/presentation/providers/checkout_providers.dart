import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../data/datasources/checkout_remote_datasource.dart';
import '../../data/repositories/checkout_repository_impl.dart';
import '../../domain/repositories/checkout_repository.dart';

final checkoutRemoteDatasourceProvider =
    Provider<CheckoutRemoteDatasource>((ref) {
  return const CheckoutRemoteDatasourceImpl();
});

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepositoryImpl(ref.watch(checkoutRemoteDatasourceProvider));
});

final checkoutNotifierProvider =
    AsyncNotifierProvider<CheckoutNotifier, CheckoutResult?>(
        CheckoutNotifier.new);

class CheckoutNotifier extends AsyncNotifier<CheckoutResult?> {
  @override
  Future<CheckoutResult?> build() async => null;

  /// Legacy: Calls the create_checkout Supabase Edge Function.
  Future<Failure?> startCheckout({
    required List<CheckoutItem> items,
    String? email,
  }) async {
    state = const AsyncLoading();

    final session = ref.read(authSessionProvider);
    final userEmail = email ?? session?.user.email ?? '';

    if (userEmail.isEmpty) {
      const failure = ValidationFailure('Email es obligatorio para el checkout');
      state = AsyncError(failure, StackTrace.current);
      return failure;
    }

    final result =
        await ref.read(checkoutRepositoryProvider).createStripeSession(
              items: items,
              email: userEmail,
            );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (checkoutResult) {
        state = AsyncData(checkoutResult);
        return null;
      },
    );
  }

  static const _edgeFnTimeout = Duration(seconds: 20);

  /// Quick DNS check to detect offline state before calling Edge Functions.
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// NEW: Full PaymentSheet flow.
  /// 1) create_checkout → creates order + items in DB, returns orderId
  /// 2) create_payment_intent → returns client_secret
  /// 3) Stripe.instance.initPaymentSheet + presentPaymentSheet
  /// Returns orderId on success, or Failure on error.
  Future<({String? orderId, Failure? failure})> payWithPaymentSheet({
    required List<CheckoutItem> items,
    String? email,
    String? couponCode,
  }) async {
    final session = ref.read(authSessionProvider);
    final userEmail = email ?? session?.user.email ?? '';

    if (userEmail.isEmpty) {
      return (orderId: null, failure: const ValidationFailure('Email es obligatorio'));
    }

    // Network pre-check
    if (!await _isOnline()) {
      return (
        orderId: null,
        failure: const NetworkFailure('Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.'),
      );
    }

    // Step 1: Create order + items via create_checkout (with timeout)
    debugPrint('[PaymentSheet] Step 1: creating order via create_checkout...');
    try {
      final orderResult = await ref
          .read(checkoutRepositoryProvider)
          .createStripeSession(items: items, email: userEmail)
          .timeout(_edgeFnTimeout);

      final checkoutResult = orderResult.fold((f) => null, (r) => r);

      if (checkoutResult == null) {
        final failure = orderResult.fold((f) => f, (_) => null);
        return (orderId: null, failure: failure ?? const NetworkFailure('Error creando pedido'));
      }

      final orderId = checkoutResult.orderId;
      debugPrint('[PaymentSheet] Order created: $orderId');

      // Step 2: Create PaymentIntent via create_payment_intent (with timeout)
      debugPrint('[PaymentSheet] Step 2: creating PaymentIntent...');
      final piResult = await ref
          .read(checkoutRepositoryProvider)
          .createPaymentIntent(
            orderId: orderId,
            customerEmail: userEmail,
            couponCode: couponCode,
          )
          .timeout(_edgeFnTimeout);

      final piData = piResult.fold((f) => null, (r) => r);

      if (piData == null) {
        final failure = piResult.fold((f) => f, (_) => null);
        return (orderId: orderId, failure: failure ?? const NetworkFailure('Error creando PaymentIntent'));
      }

      debugPrint('[PaymentSheet] PaymentIntent created: ${piData.paymentIntentId}');

      // Step 3: Init + present PaymentSheet
      debugPrint('[PaymentSheet] Step 3: initializing PaymentSheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: piData.clientSecret,
          merchantDisplayName: 'Fashion Store',
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'ES',
            currencyCode: 'EUR',
            testEnv: true,
          ),
        ),
      );

      debugPrint('[PaymentSheet] Presenting PaymentSheet...');
      await Stripe.instance.presentPaymentSheet();

      debugPrint('[PaymentSheet] ✅ Payment completed successfully!');
      return (orderId: orderId, failure: null);
    } on TimeoutException {
      debugPrint('[PaymentSheet] Timeout calling Edge Function');
      return (
        orderId: null,
        failure: const NetworkFailure('El servidor tardó demasiado. Inténtalo de nuevo.'),
      );
    } on SocketException catch (e) {
      debugPrint('[PaymentSheet] SocketException: $e');
      return (
        orderId: null,
        failure: const NetworkFailure('Error de red. Comprueba tu conexión e inténtalo de nuevo.'),
      );
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        debugPrint('[PaymentSheet] User cancelled payment.');
        return (orderId: null, failure: const ValidationFailure('Pago cancelado'));
      }
      debugPrint('[PaymentSheet] StripeException: ${e.error.localizedMessage}');
      return (
        orderId: null,
        failure: NetworkFailure(e.error.localizedMessage ?? 'Error en el pago'),
      );
    } catch (e) {
      debugPrint('[PaymentSheet] Unexpected error: $e');
      return (orderId: null, failure: NetworkFailure('Error inesperado: $e'));
    }
  }

  /// Calls the invoice_pdf Edge Function.
  Future<String?> pollInvoiceUrl({
    required String orderId,
    required String invoiceToken,
  }) async {
    final result =
        await ref.read(checkoutRepositoryProvider).fetchInvoiceUrl(
              orderId: orderId,
              invoiceToken: invoiceToken,
            );

    return result.fold(
      (_) => null,
      (url) => url,
    );
  }
}
