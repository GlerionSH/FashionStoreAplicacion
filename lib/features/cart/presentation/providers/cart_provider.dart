import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cart_local_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_state.dart';
import '../../domain/repositories/cart_repository.dart';

export '../../domain/entities/cart_item.dart';
export '../../domain/entities/cart_state.dart';

final cartLocalDatasourceProvider = Provider<CartLocalDatasource>((ref) {
  return const CartLocalDatasourceImpl();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartLocalDatasourceProvider));
});

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    _load();
    return const CartState();
  }

  CartRepository get _repo => ref.read(cartRepositoryProvider);

  Future<void> _load() async {
    final result = await _repo.load();
    result.fold(
      (_) => {},
      (items) => state = CartState(items: items),
    );
  }

  Future<void> _persist() async {
    await _repo.save(state.items);
  }

  Future<void> addItem({
    required String productId,
    required String name,
    required String slug,
    String? imageUrl,
    required int priceCents,
    int quantity = 1,
    String? size,
  }) async {
    if (quantity <= 0) return;

    final key = '$productId|${size ?? ""}';
    final idx = state.items.indexWhere((i) => i.uniqueKey == key);

    if (idx == -1) {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            productId: productId,
            name: name,
            slug: slug,
            imageUrl: imageUrl,
            priceCents: priceCents,
            quantity: quantity,
            size: size,
          ),
        ],
      );
    } else {
      final existing = state.items[idx];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      final newItems = [...state.items];
      newItems[idx] = updated;
      state = state.copyWith(items: newItems);
    }

    await _persist();
  }

  Future<void> removeItem(String uniqueKey) async {
    state = state.copyWith(
      items: state.items.where((i) => i.uniqueKey != uniqueKey).toList(),
    );
    await _persist();
  }

  Future<void> updateQuantity(String uniqueKey, {required int quantity}) async {
    if (quantity <= 0) {
      await removeItem(uniqueKey);
      return;
    }

    final idx = state.items.indexWhere((i) => i.uniqueKey == uniqueKey);
    if (idx == -1) return;

    final newItems = [...state.items];
    newItems[idx] = newItems[idx].copyWith(quantity: quantity);
    state = state.copyWith(items: newItems);
    await _persist();
  }

  Future<void> clear() async {
    state = const CartState();
    await _persist();
  }
}
