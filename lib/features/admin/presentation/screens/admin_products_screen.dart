import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../products/data/models/product_model.dart';
import '../../products/presentation/providers/admin_products_providers.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final productsAv = ref.watch(adminProductsListProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminProductsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: () => context.go('/admin-panel/productos/nuevo'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: t.adminSearchProduct,
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF000000),
              onRefresh: () async {
                ref.invalidate(adminProductsListProvider);
              },
              child: productsAv.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: theme.textTheme.bodySmall),
                ),
                data: (products) {
                  final filtered = _search.isEmpty
                      ? products
                      : products
                          .where((p) =>
                              p.name.toLowerCase().contains(_search) ||
                              p.slug.toLowerCase().contains(_search))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(t.adminNoResults,
                          style: theme.textTheme.bodySmall),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) =>
                        _ProductTile(product: filtered[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final ProductModel product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price =
        '${(product.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',')} \u20ac';
    final firstImage =
        product.images.isNotEmpty ? product.images.first : null;

    return InkWell(
      onTap: () => context.go('/admin-panel/productos/${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 65,
              child: firstImage != null
                  ? Image.network(firstImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.image_outlined,
                                size: 18, color: Color(0xFFBDBDBD)),
                          ))
                  : Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(Icons.image_outlined,
                          size: 18, color: Color(0xFFBDBDBD)),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 4),
                  Text(price,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF616161),
                      )),
                  const SizedBox(height: 2),
                  Text(S.of(context)!.adminProductStockLabel(product.stock),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      )),
                ],
              ),
            ),
            Switch(
              value: product.isActive,
              activeTrackColor: const Color(0xFF111111),
              onChanged: (val) async {
                await ref
                    .read(adminProductsDatasourceProvider)
                    .toggleActive(product.id, isActive: val);
                ref.invalidate(adminProductsListProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
