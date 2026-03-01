import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/domain/entities/product.dart';
import '../../l10n/app_localizations.dart';
import '../utils/localized_text.dart';
import 'fs_price_text.dart';

class FsProductCard extends StatelessWidget {
  final Product product;

  const FsProductCard({super.key, required this.product});

  bool get _isAvailable {
    if (product.sizes.isNotEmpty) {
      return product.sizeStock.values.any((v) => v > 0);
    }
    return product.stock > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final locale = Localizations.localeOf(context);
    final imageUrl =
        product.images.isNotEmpty ? product.images.first : null;
    final catLabel = localizedText(
      es: product.categoryNameEs ?? product.categoryName,
      en: product.categoryNameEn ?? product.categoryName,
      locale: locale,
      fallback: product.categoryName ?? '',
    );
    final displayName = localizedText(
      es: product.nameEs ?? product.name,
      en: product.nameEn ?? product.name,
      locale: locale,
      fallback: product.name,
    );
    final available = _isAvailable;

    return GestureDetector(
      onTap: () => context.go('/productos/${product.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image with fixed aspect ratio ---
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
                  ),
                  if (!available)
                    Container(
                      color: Colors.white54,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        color: const Color(0xFF111111),
                        child: Text(
                          t.productSoldOutUpper,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (catLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                catLabel.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF111111),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              FsPriceText(
                priceCents: product.priceCents,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  available ? t.productAvailable : t.productSoldOut,
                  style: TextStyle(
                    fontSize: 9,
                    color: available
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_outlined, size: 32, color: Color(0xFFBDBDBD)),
    );
  }
}
