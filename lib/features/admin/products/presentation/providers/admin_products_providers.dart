import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../products/data/models/product_model.dart';
import '../../data/datasources/admin_products_datasource.dart';
export '../../data/datasources/admin_products_datasource.dart';

final adminProductsDatasourceProvider = Provider<AdminProductsDatasource>((ref) {
  return const AdminProductsDatasourceImpl();
});

final adminProductsListProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(adminProductsDatasourceProvider).listProducts();
});

final adminProductDetailProvider =
    FutureProvider.family<ProductModel, String>((ref, id) {
  return ref.watch(adminProductsDatasourceProvider).getProduct(id);
});
