import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/providers/cart_banner_provider.dart';

class AddToCartBtn extends ConsumerWidget {
  final String productId;
  final String name;
  final String slug;
  final String? imageUrl;
  final int priceCents;
  final int quantity;
  final String? size;
  final Widget? child;

  const AddToCartBtn({
    super.key,
    required this.productId,
    required this.name,
    required this.slug,
    this.imageUrl,
    required this.priceCents,
    this.quantity = 1,
    this.size,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () async {
        await ref.read(cartProvider.notifier).addItem(
              productId: productId,
              name: name,
              slug: slug,
              imageUrl: imageUrl,
              priceCents: priceCents,
              quantity: quantity,
              size: size,
            );

        if (!context.mounted) return;

        ref.read(cartBannerProvider.notifier).showAdded(name);
      },
      child: child ?? const Text('Anadir al carrito'),
    );
  }
}
