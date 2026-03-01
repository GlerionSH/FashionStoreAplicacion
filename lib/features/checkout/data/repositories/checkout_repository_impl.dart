import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDatasource remote;

  const CheckoutRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, CheckoutResult>> createStripeSession({
    required List<CheckoutItem> items,
    required String email,
  }) async {
    try {
      final result = await remote.createStripeSession(
        items: items,
        email: email,
      );
      return right(result);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntentResult>> createPaymentIntent({
    required String orderId,
    String? customerEmail,
    String? couponCode,
  }) async {
    try {
      final result = await remote.createPaymentIntent(
        orderId: orderId,
        customerEmail: customerEmail,
        couponCode: couponCode,
      );
      return right(result);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> fetchInvoiceUrl({
    required String orderId,
    required String invoiceToken,
  }) async {
    try {
      final url = await remote.fetchInvoiceUrl(
        orderId: orderId,
        invoiceToken: invoiceToken,
      );
      return right(url);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
