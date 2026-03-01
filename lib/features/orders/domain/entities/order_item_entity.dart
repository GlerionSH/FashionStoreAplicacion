import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_entity.freezed.dart';

@freezed
class OrderItemEntity with _$OrderItemEntity {
  const factory OrderItemEntity({
    required String id,
    required String orderId,
    required String productId,
    required String name,
    required int qty,
    required int priceCents,
    required int lineTotalCents,
    String? size,
    int? paidUnitCents,
    int? paidLineTotalCents,
  }) = _OrderItemEntity;
}
