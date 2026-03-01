import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/fs_product_card.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../providers/products_providers.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String? _selectedCategoryId;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(catalogProvider.notifier).loadMore();
    }
  }

  void _onCategoryChanged(String? id) {
    setState(() => _selectedCategoryId = id);
    ref.read(catalogProvider.notifier).applyFilter(
          categoryId: id,
          search: _searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim(),
        );
  }

  void _onSearch(String value) {
    ref.read(catalogProvider.notifier).applyFilter(
          categoryId: _selectedCategoryId,
          search: value.trim().isEmpty ? null : value.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final categoriesAv = ref.watch(categoriesProvider);
    final productsAv = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: t.productSearch,
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                style: theme.textTheme.bodyMedium,
                onSubmitted: _onSearch,
              ),
            ),
          ),
          categoriesAv.when(
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox.shrink(),
            data: (either) => either.fold(
              (_) => const SizedBox.shrink(),
              (categories) => _CategoryChips(
                categories: categories,
                selected: _selectedCategoryId,
                onSelected: _onCategoryChanged,
              ),
            ),
          ),
          Expanded(
            child: productsAv.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $e',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 180,
                        child: FilledButton(
                          onPressed: () =>
                              ref.invalidate(catalogProvider),
                          child: Text(t.generalRetry),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 36, color: Color(0xFF9E9E9E)),
                        const SizedBox(height: 12),
                        Text(t.productNoResults,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.55,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              FsProductCard(product: products[i]),
                          childCount: products.length,
                        ),
                      ),
                    ),
                    if (notifier.hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                              child: CircularProgressIndicator()),
                        ),
                      ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 16)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip(context, S.of(context)!.productAll, selected == null, () => onSelected(null)),
          for (final cat in categories)
            _chip(
              context,
              cat.name.toUpperCase(),
              selected == cat.id,
              () => onSelected(selected == cat.id ? null : cat.id),
            ),
        ],
      ),
    );
  }

  Widget _chip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: 1.0,
                color: isSelected
                    ? const Color(0xFF111111)
                    : const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 16 : 0,
              height: 1,
              color: const Color(0xFF111111),
            ),
          ],
        ),
      ),
    );
  }
}
