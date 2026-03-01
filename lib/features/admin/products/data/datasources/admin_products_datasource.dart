import '../../../../products/data/models/product_model.dart';
import '../../../../../shared/services/supabase_service.dart';

abstract class AdminProductsDatasource {
  Future<List<ProductModel>> listProducts({int limit = 50, int offset = 0});
  Future<ProductModel> getProduct(String id);
  Future<void> upsertProduct(Map<String, dynamic> data);
  Future<void> toggleActive(String id, {required bool isActive});
  Future<void> deleteProduct(String id);
}

class AdminProductsDatasourceImpl implements AdminProductsDatasource {
  const AdminProductsDatasourceImpl();

  static const _table = 'fs_products';
  static const _columns =
      'id,name,name_es,name_en,slug,description,description_es,description_en,'
      'price_cents,stock,category_id,is_active,images,product_type,sizes,size_stock,is_flash';

  @override
  Future<List<ProductModel>> listProducts({int limit = 50, int offset = 0}) async {
    final result = await SupabaseService.client
        .from(_table)
        .select(_columns)
        .order('name', ascending: true)
        .range(offset, offset + limit - 1);

    return (result as List)
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    final row = await SupabaseService.client
        .from(_table)
        .select(_columns)
        .eq('id', id)
        .single();

    return ProductModel.fromJson(row);
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> data) async {
    await SupabaseService.client.from(_table).upsert(data);
  }

  @override
  Future<void> toggleActive(String id, {required bool isActive}) async {
    await SupabaseService.client
        .from(_table)
        .update({'is_active': isActive}).eq('id', id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await SupabaseService.client.from(_table).delete().eq('id', id);
  }
}
