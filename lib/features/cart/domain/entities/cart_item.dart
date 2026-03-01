import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String productId,
    required String name,
    required String slug,
    String? imageUrl,
    required int priceCents,
    required int quantity,
    String? size,
  }) = _CartItem;

  const CartItem._();

  String get uniqueKey => '$productId|${size ?? ""}';
}
