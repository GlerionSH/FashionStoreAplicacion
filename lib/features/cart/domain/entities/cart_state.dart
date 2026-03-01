import 'package:freezed_annotation/freezed_annotation.dart';

import 'cart_item.dart';

part 'cart_state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
  }) = _CartState;

  const CartState._();

  int get totalCents =>
      items.fold(0, (sum, i) => sum + i.priceCents * i.quantity);

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
}
