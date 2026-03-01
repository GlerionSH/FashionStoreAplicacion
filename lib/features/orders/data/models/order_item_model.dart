import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/order_item_entity.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') required String productId,
    required String name,
    required int qty,
    @JsonKey(name: 'price_cents') required int priceCents,
    @JsonKey(name: 'line_total_cents') required int lineTotalCents,
    String? size,
    @JsonKey(name: 'paid_unit_cents') int? paidUnitCents,
    @JsonKey(name: 'paid_line_total_cents') int? paidLineTotalCents,
  }) = _OrderItemModel;

  const OrderItemModel._();

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  OrderItemEntity toEntity() => OrderItemEntity(
        id: id,
        orderId: orderId,
        productId: productId,
        name: name,
        qty: qty,
        priceCents: priceCents,
        lineTotalCents: lineTotalCents,
        size: size,
        paidUnitCents: paidUnitCents,
        paidLineTotalCents: paidLineTotalCents,
      );
}
