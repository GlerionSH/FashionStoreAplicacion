import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../domain/entities/flash_offer.dart';
import '../providers/flash_offers_providers.dart';

class FlashBanner extends ConsumerWidget {
  const FlashBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAv = ref.watch(activeFlashOfferProvider);

    return offerAv.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (either) => either.fold(
        (_) => const SizedBox.shrink(),
        (offer) {
          if (offer == null) return const SizedBox.shrink();
          return _FlashBannerWithProducts(offer: offer);
        },
      ),
    );
  }
}

class _FlashBannerWithProducts extends ConsumerWidget {
  final FlashOffer offer;

  const _FlashBannerWithProducts({required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashAv = ref.watch(flashProductsProvider);

    return flashAv.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (either) => either.fold(
        (_) => const SizedBox.shrink(),
        (products) {
          if (products.isEmpty) return const SizedBox.shrink();
          return _FlashBannerContent(
              products: products, discountPercent: offer.discountPercent);
        },
      ),
    );
  }
}

class _FlashBannerContent extends StatelessWidget {
  final List<Product> products;
  final int discountPercent;

  const _FlashBannerContent({
    required this.products,
    required this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'OFERTAS FLASH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 0.5),
                ),
                child: Text(
                  '-$discountPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final p = products[index];
                final originalPrice =
                    (p.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
                final discountedCents =
                    applyPercentDiscountCents(p.priceCents, discountPercent);
                final discountedPrice =
                    (discountedCents / 100).toStringAsFixed(2).replaceAll('.', ',');

                return GestureDetector(
                  onTap: () => context.go('/productos/${p.slug}'),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          p.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '$originalPrice \u20ac',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$discountedPrice \u20ac',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
