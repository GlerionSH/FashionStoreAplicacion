import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartBannerState {
  final bool visible;
  final String message;

  const CartBannerState({
    this.visible = false,
    this.message = '',
  });

  CartBannerState copyWith({
    bool? visible,
    String? message,
  }) {
    return CartBannerState(
      visible: visible ?? this.visible,
      message: message ?? this.message,
    );
  }
}

final cartBannerProvider = NotifierProvider<CartBannerNotifier, CartBannerState>(
  CartBannerNotifier.new,
);

class CartBannerNotifier extends Notifier<CartBannerState> {
  Timer? _timer;

  @override
  CartBannerState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    return const CartBannerState();
  }

  void showAdded(String name, {Duration duration = const Duration(seconds: 4)}) {
    _timer?.cancel();
    state = CartBannerState(visible: true, message: 'Producto añadido: $name');
    _timer = Timer(duration, hide);
  }

  void hide() {
    _timer?.cancel();
    _timer = null;
    if (!state.visible) return;
    state = state.copyWith(visible: false);
  }
}
