// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      email: json['email'] as String?,
      userId: json['user_id'] as String?,
      subtotalCents: (json['subtotal_cents'] as num).toInt(),
      discountCents: (json['discount_cents'] as num?)?.toInt() ?? 0,
      totalCents: (json['total_cents'] as num).toInt(),
      status: json['status'] as String,
      invoiceToken: json['invoice_token'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      invoiceIssuedAt: json['invoice_issued_at'] as String?,
      paidAt: json['paid_at'] as String?,
      refundTotalCents: (json['refund_total_cents'] as num?)?.toInt() ?? 0,
      emailSentAt: json['email_sent_at'] as String?,
      emailLastError: json['email_last_error'] as String?,
      couponCode: json['coupon_code'] as String?,
      couponPercent: (json['coupon_percent'] as num?)?.toInt(),
      couponDiscountCents:
          (json['coupon_discount_cents'] as num?)?.toInt() ?? 0,
      cancelRequestedAt: json['cancel_requested_at'] as String?,
      refundedAt: json['refunded_at'] as String?,
      stripeRefundId: json['stripe_refund_id'] as String?,
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'email': instance.email,
      'user_id': instance.userId,
      'subtotal_cents': instance.subtotalCents,
      'discount_cents': instance.discountCents,
      'total_cents': instance.totalCents,
      'status': instance.status,
      'invoice_token': instance.invoiceToken,
      'invoice_number': instance.invoiceNumber,
      'invoice_issued_at': instance.invoiceIssuedAt,
      'paid_at': instance.paidAt,
      'refund_total_cents': instance.refundTotalCents,
      'email_sent_at': instance.emailSentAt,
      'email_last_error': instance.emailLastError,
      'coupon_code': instance.couponCode,
      'coupon_percent': instance.couponPercent,
      'coupon_discount_cents': instance.couponDiscountCents,
      'cancel_requested_at': instance.cancelRequestedAt,
      'refunded_at': instance.refundedAt,
      'stripe_refund_id': instance.stripeRefundId,
    };
