import '../../../../shared/services/supabase_service.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDatasource {
  Future<List<CategoryModel>> listCategories();
}

class CategoriesRemoteDatasourceImpl implements CategoriesRemoteDatasource {
  const CategoriesRemoteDatasourceImpl();

  @override
  Future<List<CategoryModel>> listCategories() async {
    final result = await SupabaseService.client
        .from('fs_categories')
        .select('id,name,name_es,name_en,slug')
        .order('name', ascending: true);

    final rows = (result as List).cast<Map<String, dynamic>>();
    return rows.map(CategoryModel.fromJson).toList();
  }
}
