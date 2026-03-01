import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/products_filter.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../offers/presentation/providers/offers_switch_provider.dart';

const _pageSize = 20;

final productsRemoteDatasourceProvider = Provider<ProductsRemoteDatasource>((ref) {
  return const ProductsRemoteDatasourceImpl();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productsRemoteDatasourceProvider));
});

final productsProvider = FutureProvider.family<Either<Failure, List<Product>>, ProductsFilter>(
  (ref, filter) {
    return ref.watch(productRepositoryProvider).getProducts(
          limit: _pageSize,
          offset: filter.page * _pageSize,
          categoryId: filter.categoryId,
          search: filter.search,
        );
  },
);

final productBySlugProvider = FutureProvider.family<Either<Failure, Product?>, String>(
  (ref, slug) {
    return ref.watch(productRepositoryProvider).getBySlug(slug);
  },
);

final flashProductsProvider = FutureProvider<Either<Failure, List<Product>>>((ref) {
  final enabled = ref.watch(offersSwitchProvider).valueOrNull ?? false;
  if (!enabled) return Future.value(right(const <Product>[]));
  return ref.watch(productRepositoryProvider).getFlashProducts();
});

final catalogProvider =
    AsyncNotifierProvider<CatalogNotifier, List<Product>>(CatalogNotifier.new);

class CatalogNotifier extends AsyncNotifier<List<Product>> {
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _categoryId;
  String? _search;

  bool get hasMore => _hasMore;

  @override
  Future<List<Product>> build() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchPage(0);
  }

  Future<List<Product>> _fetchPage(int page) async {
    final result = await ref.read(productRepositoryProvider).getProducts(
          limit: _pageSize,
          offset: page * _pageSize,
          categoryId: _categoryId,
          search: _search,
        );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) {
        if (products.length < _pageSize) _hasMore = false;
        return products;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    final current = state.valueOrNull ?? [];
    _page++;
    try {
      final more = await _fetchPage(_page);
      state = AsyncData([...current, ...more]);
    } catch (_) {
      _page--;
    } finally {
      _isLoadingMore = false;
    }
  }

  void applyFilter({String? categoryId, String? search}) {
    _categoryId = categoryId;
    _search = search;
    _page = 0;
    _hasMore = true;
    ref.invalidateSelf();
  }
}
