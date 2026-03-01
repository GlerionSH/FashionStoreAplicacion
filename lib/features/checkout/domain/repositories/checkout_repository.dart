import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/checkout_remote_datasource.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, CheckoutResult>> createStripeSession({
    required List<CheckoutItem> items,
    required String email,
  });

  Future<Either<Failure, PaymentIntentResult>> createPaymentIntent({
    required String orderId,
    String? customerEmail,
    String? couponCode,
  });

  Future<Either<Failure, String?>> fetchInvoiceUrl({
    required String orderId,
    required String invoiceToken,
  });
}
