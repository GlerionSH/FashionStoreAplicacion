import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result returned by the create_checkout Edge Function (legacy).
class CheckoutResult {
  final String url;
  final String sessionId;
  final String orderId;
  final int subtotalCents;
  final int discountCents;
  final int totalCents;

  const CheckoutResult({
    required this.url,
    required this.sessionId,
    required this.orderId,
    required this.subtotalCents,
    required this.discountCents,
    required this.totalCents,
  });
}

/// Result returned by the create_payment_intent Edge Function (new).
class PaymentIntentResult {
  final String clientSecret;
  final String paymentIntentId;

  const PaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

/// Item shape sent to the create_checkout Edge Function.
class CheckoutItem {
  final String productId;
  final int qty;
  final String? size;

  const CheckoutItem({
    required this.productId,
    required this.qty,
    this.size,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'qty': qty,
        if (size != null) 'size': size,
      };
}

abstract class CheckoutRemoteDatasource {
  /// Creates order + items via create_checkout, returns Stripe Checkout URL.
  Future<CheckoutResult> createStripeSession({
    required List<CheckoutItem> items,
    required String email,
  });

  /// Creates a PaymentIntent for an existing order (PaymentSheet flow).
  Future<PaymentIntentResult> createPaymentIntent({
    required String orderId,
    String? customerEmail,
    String? couponCode,
  });

  /// Calls the invoice_pdf Edge Function to get a signed PDF URL.
  Future<String?> fetchInvoiceUrl({
    required String orderId,
    required String invoiceToken,
  });
}

class CheckoutRemoteDatasourceImpl implements CheckoutRemoteDatasource {
  const CheckoutRemoteDatasourceImpl();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<CheckoutResult> createStripeSession({
    required List<CheckoutItem> items,
    required String email,
  }) async {
    debugPrint('[CheckoutDS] invoke(create_checkout) email=$email, items=${items.length}');
    final response = await _client.functions.invoke(
      'create_checkout',
      body: {
        'email': email,
        'items': items.map((i) => i.toJson()).toList(),
      },
    );
    debugPrint('[CheckoutDS] create_checkout status=${response.status}');

    if (response.status != 200) {
      final msg = _extractError(response);
      debugPrint('[CheckoutDS] create_checkout ERROR: $msg');
      throw Exception(msg);
    }

    final data = response.data as Map<String, dynamic>;

    return CheckoutResult(
      url: data['url'] as String,
      sessionId: data['session_id'] as String,
      orderId: data['order_id'] as String,
      subtotalCents: data['subtotal_cents'] as int,
      discountCents: data['discount_cents'] as int,
      totalCents: data['total_cents'] as int,
    );
  }

  @override
  Future<PaymentIntentResult> createPaymentIntent({
    required String orderId,
    String? customerEmail,
    String? couponCode,
  }) async {
    debugPrint('[CheckoutDS] invoke(create_payment_intent) order_id=$orderId');
    late final FunctionResponse response;
    try {
      response = await _client.functions.invoke(
        'create_payment_intent',
        body: {
          'order_id': orderId,
          if (customerEmail != null) 'customer_email': customerEmail,
          if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        },
      );
      debugPrint('[CheckoutDS] create_payment_intent status=${response.status}');
    } catch (e) {
      debugPrint('[CheckoutDS] create_payment_intent EXCEPTION: ${e.runtimeType} — $e');
      rethrow;
    }

    if (response.status != 200) {
      final msg = _extractError(response);
      debugPrint('[CheckoutDS] create_payment_intent ERROR: $msg');
      debugPrint('[CheckoutDS] create_payment_intent RAW DATA: ${response.data}');
      throw Exception(msg);
    }

    final data = response.data as Map<String, dynamic>;

    return PaymentIntentResult(
      clientSecret: data['client_secret'] as String,
      paymentIntentId: data['payment_intent_id'] as String,
    );
  }

  @override
  Future<String?> fetchInvoiceUrl({
    required String orderId,
    required String invoiceToken,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'invoice_pdf',
        method: HttpMethod.get,
        queryParameters: {
          'order_id': orderId,
          'token': invoiceToken,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final url = data['url'];
        if (url is String && url.isNotEmpty) return url;
      }
    } catch (_) {
      // Not ready yet or error — return null
    }
    return null;
  }

  String _extractError(FunctionResponse response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['error'] as String? ??
            'Error del servidor (${response.status})';
      }
      return 'Error del servidor (${response.status})';
    } catch (_) {
      return 'Error del servidor (${response.status})';
    }
  }
}
