import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_entity.freezed.dart';

@freezed
class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    required String id,
    required DateTime createdAt,
    String? email,
    String? userId,
    required int subtotalCents,
    required int discountCents,
    required int totalCents,
    required String status,
    String? invoiceToken,
    String? invoiceNumber,
    DateTime? invoiceIssuedAt,
    DateTime? paidAt,
    required int refundTotalCents,
    DateTime? emailSentAt,
    String? emailLastError,
    String? couponCode,
    int? couponPercent,
    @Default(0) int couponDiscountCents,
    DateTime? cancelRequestedAt,
    DateTime? refundedAt,
    String? stripeRefundId,
  }) = _OrderEntity;
}
