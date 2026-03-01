import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/order_entity.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'created_at') required String createdAt,
    String? email,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'subtotal_cents') required int subtotalCents,
    @JsonKey(name: 'discount_cents') @Default(0) int discountCents,
    @JsonKey(name: 'total_cents') required int totalCents,
    required String status,
    @JsonKey(name: 'invoice_token') String? invoiceToken,
    @JsonKey(name: 'invoice_number') String? invoiceNumber,
    @JsonKey(name: 'invoice_issued_at') String? invoiceIssuedAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'refund_total_cents') @Default(0) int refundTotalCents,
    @JsonKey(name: 'email_sent_at') String? emailSentAt,
    @JsonKey(name: 'email_last_error') String? emailLastError,
    @JsonKey(name: 'coupon_code') String? couponCode,
    @JsonKey(name: 'coupon_percent') int? couponPercent,
    @JsonKey(name: 'coupon_discount_cents') @Default(0) int couponDiscountCents,
    @JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,
    @JsonKey(name: 'refunded_at') String? refundedAt,
    @JsonKey(name: 'stripe_refund_id') String? stripeRefundId,
  }) = _OrderModel;

  const OrderModel._();

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  OrderEntity toEntity() => OrderEntity(
        id: id,
        createdAt: DateTime.parse(createdAt),
        email: email,
        userId: userId,
        subtotalCents: subtotalCents,
        discountCents: discountCents,
        totalCents: totalCents,
        status: status,
        invoiceToken: invoiceToken,
        invoiceNumber: invoiceNumber,
        invoiceIssuedAt:
            invoiceIssuedAt != null ? DateTime.parse(invoiceIssuedAt!) : null,
        paidAt: paidAt != null ? DateTime.parse(paidAt!) : null,
        refundTotalCents: refundTotalCents,
        emailSentAt:
            emailSentAt != null ? DateTime.tryParse(emailSentAt!) : null,
        emailLastError: emailLastError,
        couponCode: couponCode,
        couponPercent: couponPercent,
        couponDiscountCents: couponDiscountCents,
        cancelRequestedAt: cancelRequestedAt != null
            ? DateTime.tryParse(cancelRequestedAt!)
            : null,
        refundedAt:
            refundedAt != null ? DateTime.tryParse(refundedAt!) : null,
        stripeRefundId: stripeRefundId,
      );
}
