import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_banner_provider.dart';

class CartBannerOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final Listenable routeListenable;
  final GoRouter router;

  const CartBannerOverlay({
    super.key,
    required this.child,
    required this.routeListenable,
    required this.router,
  });

  @override
  ConsumerState<CartBannerOverlay> createState() => _CartBannerOverlayState();
}

class _CartBannerOverlayState extends ConsumerState<CartBannerOverlay> {
  @override
  void initState() {
    super.initState();
    widget.routeListenable.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant CartBannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeListenable != widget.routeListenable) {
      oldWidget.routeListenable.removeListener(_onRouteChanged);
      widget.routeListenable.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    ref.read(cartBannerProvider.notifier).hide();
  }

  @override
  void dispose() {
    widget.routeListenable.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartBannerProvider);

    return Stack(
      children: [
        widget.child,
        if (state.visible)
          Positioned(
            left: 12,
            right: 12,
            bottom: 74,
            child: SafeArea(
              top: false,
              child: Material(
                color: const Color(0xFF000000),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.3,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              ref.read(cartBannerProvider.notifier).hide();
                              widget.router.go('/carrito');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: const Size(0, 36),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('VER CARRITO'),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(cartBannerProvider.notifier).hide(),
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
