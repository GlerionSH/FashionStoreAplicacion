import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_text.dart';
import '../../../../shared/widgets/fs_price_text.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_providers.dart';
import '../widgets/add_to_cart_btn.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    final resultAv = ref.watch(productBySlugProvider(widget.slug));
    final theme = Theme.of(context);
    final t = S.of(context)!;

    return resultAv.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Error: $e', style: theme.textTheme.bodySmall),
        ),
      ),
      data: (either) => either.fold(
        (failure) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(failure.message, style: theme.textTheme.bodySmall),
          ),
        ),
        (product) {
          if (product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(t.productNotFound,
                    style: theme.textTheme.bodySmall),
              ),
            );
          }
          return _buildDetail(context, product);
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final locale = Localizations.localeOf(context);
    final cartState = ref.watch(cartProvider);
    final hasSizes = product.sizes.isNotEmpty;
    final displayName = localizedText(
      es: product.nameEs ?? product.name,
      en: product.nameEn ?? product.name,
      locale: locale,
      fallback: product.name,
    );
    final displayCategory = localizedText(
      es: product.categoryNameEs ?? product.categoryName,
      en: product.categoryNameEn ?? product.categoryName,
      locale: locale,
      fallback: product.categoryName ?? '',
    );
    final displayDesc = localizedText(
      es: product.descriptionEs ?? product.description,
      en: product.descriptionEn ?? product.description,
      locale: locale,
      fallback: product.description ?? '',
    );
    final needsSize = hasSizes && _selectedSize == null;
    final firstImage =
        product.images.isNotEmpty ? product.images.first : null;

    // Determine if truly out of stock (global or all sizes)
    final bool globallyOutOfStock;
    if (hasSizes) {
      globallyOutOfStock = !product.sizeStock.values.any((v) => v > 0);
    } else {
      globallyOutOfStock = product.stock <= 0;
    }

    // If a size is selected, check its specific stock
    final selectedSizeStock = _selectedSize != null
        ? (product.sizeStock[_selectedSize] ?? 0)
        : null;
    final selectedSizeOutOfStock =
        selectedSizeStock != null && selectedSizeStock <= 0;

    // Cart-quantity-aware: check if user already has max in cart
    bool maxInCart = false;
    if (!globallyOutOfStock && !needsSize && !selectedSizeOutOfStock) {
      final key = '${product.id}|${_selectedSize ?? ""}';
      final inCart = cartState.items
          .where((i) => i.uniqueKey == key)
          .fold<int>(0, (sum, i) => sum + i.quantity);
      final stockForKey = _selectedSize != null
          ? (product.sizeStock[_selectedSize] ?? 0)
          : product.stock;
      maxInCart = inCart >= stockForKey;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('[ProductDetailScreen] Back navigation');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          actions: const [SizedBox(width: 48)],
        ),
        body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Gallery ---
                  AspectRatio(
                    aspectRatio: 0.75,
                    child: product.images.length > 1
                        ? _ImageGallery(images: product.images)
                        : firstImage != null
                            ? Image.network(firstImage, fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, _, _) =>
                                    _imagePlaceholder())
                            : _imagePlaceholder(),
                  ),

                  // --- Category ---
                  if (displayCategory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        displayCategory.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                  // --- Info ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      displayName.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: FsPriceText(
                      priceCents: product.priceCents,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  // --- Stock total (only in detail, not in card) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      globallyOutOfStock
                          ? t.productSoldOut
                          : hasSizes
                              ? t.productStockTotal(product.stock)
                              : t.productStockAvailable(product.stock),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: globallyOutOfStock
                            ? Colors.red.shade400
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),

                  if (displayDesc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        displayDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),

                  // --- Size selector ---
                  if (hasSizes) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Text(t.productSize,
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111111),
                          )),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.sizes.map((size) {
                          final stock = product.sizeStock[size] ?? 0;
                          final available = stock > 0;
                          final selected = _selectedSize == size;

                          return GestureDetector(
                            onTap: available
                                ? () =>
                                    setState(() => _selectedSize = size)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF111111)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: !available
                                      ? const Color(0xFFE5E5E5)
                                      : selected
                                          ? const Color(0xFF111111)
                                          : const Color(0xFFBDBDBD),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                  color: !available
                                      ? const Color(0xFFBDBDBD)
                                      : selected
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                  decoration: !available
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // --- Stock per size table ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.productStockPerSize,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9E9E9E),
                              )),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: product.sizes.map((size) {
                              final qty = product.sizeStock[size] ?? 0;
                              return Text(
                                '$size: $qty',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: qty > 0
                                      ? const Color(0xFF616161)
                                      : Colors.red.shade300,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // --- Bottom CTA ---
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: globallyOutOfStock
                  ? FilledButton(
                      onPressed: null,
                      child: Text(t.productSoldOutUpper),
                    )
                  : needsSize
                      ? FilledButton(
                          onPressed: null,
                          child: Text(t.productSelectSize),
                        )
                      : selectedSizeOutOfStock
                          ? FilledButton(
                              onPressed: null,
                              child: Text(t.productSizeSoldOut),
                            )
                          : maxInCart
                              ? FilledButton(
                                  onPressed: null,
                                  child: Text(t.productMaxInCart,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12)),
                                )
                              : AddToCartBtn(
                                  productId: product.id,
                                  name: product.name,
                                  slug: product.slug,
                                  imageUrl: firstImage,
                                  priceCents: product.priceCents,
                                  size: _selectedSize,
                                  child: Text(t.productAddToCart),
                                ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
            child: Icon(Icons.image_outlined, size: 48,
                color: Color(0xFFBDBDBD))),
      );
}

class _ImageGallery extends StatefulWidget {
  final List<String> images;

  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => Image.network(
            widget.images[i],
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.broken_image_outlined, size: 36,
                  color: Color(0xFFBDBDBD)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == i
                      ? const Color(0xFF111111)
                      : const Color(0xFFBDBDBD),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
