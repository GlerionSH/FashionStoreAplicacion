// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemModelImpl _$$OrderItemModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemModelImpl(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      priceCents: (json['price_cents'] as num).toInt(),
      lineTotalCents: (json['line_total_cents'] as num).toInt(),
      size: json['size'] as String?,
      paidUnitCents: (json['paid_unit_cents'] as num?)?.toInt(),
      paidLineTotalCents: (json['paid_line_total_cents'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$OrderItemModelImplToJson(
  _$OrderItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'product_id': instance.productId,
  'name': instance.name,
  'qty': instance.qty,
  'price_cents': instance.priceCents,
  'line_total_cents': instance.lineTotalCents,
  'size': instance.size,
  'paid_unit_cents': instance.paidUnitCents,
  'paid_line_total_cents': instance.paidLineTotalCents,
};
