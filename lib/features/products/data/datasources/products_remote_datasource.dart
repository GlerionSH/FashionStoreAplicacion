import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';
import '../../../../shared/services/supabase_service.dart';

abstract class ProductsRemoteDatasource {
  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int offset,
    String? categoryId,
    String? search,
  });
  Future<ProductModel?> getBySlug(String slug);
  Future<List<ProductModel>> fetchFlashProducts();
}

class ProductsRemoteDatasourceImpl implements ProductsRemoteDatasource {
  const ProductsRemoteDatasourceImpl();

  static const _tag = 'ProductsDatasource';

  static const _columns =
      'id,name,name_es,name_en,slug,description,description_es,description_en,'
      'price_cents,stock,category_id,is_active,images,product_type,sizes,size_stock,is_flash,'
      'fs_categories(name,name_es,name_en)';

  static Map<String, dynamic> _flattenCategory(Map<String, dynamic> row) {
    final cat = row['fs_categories'];
    final flat = Map<String, dynamic>.from(row);
    flat.remove('fs_categories');
    if (cat is Map) {
      flat['category_name'] = cat['name'];
      flat['category_name_es'] = cat['name_es'];
      flat['category_name_en'] = cat['name_en'];
    }
    return flat;
  }

  void _logDebug(String msg) {
    dev.log(msg, name: _tag);
    if (kDebugMode) debugPrint('[$_tag] $msg');
  }

  Never _rethrowClassified(Object e, StackTrace st, String context) {
    if (e is PostgrestException) {
      final code = e.code;
      final statusHint = (code == '42501' || code == '401' || code == '403')
          ? ' [posible RLS/permisos]'
          : '';
      _logDebug('PostgrestException ($context): '
          'code=$code, msg=${e.message}, hint=${e.hint}$statusHint');
      Error.throwWithStackTrace(e, st);
    }

    if (e is AuthException) {
      _logDebug('AuthException ($context): '
          'statusCode=${e.statusCode}, msg=${e.message}');
      Error.throwWithStackTrace(e, st);
    }

    if (e is http.ClientException) {
      final isCors = kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('XMLHttpRequest'));
      final label = isCors ? 'CORS/Red' : 'ClientException';
      _logDebug('$label ($context): ${e.message}');
      Error.throwWithStackTrace(e, st);
    }

    _logDebug('UnknownError ($context): ${e.runtimeType} — $e');
    Error.throwWithStackTrace(e, st);
  }

  @override
  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int offset,
    String? categoryId,
    String? search,
  }) async {
    _logDebug('fetchProducts(limit=$limit, offset=$offset, '
        'cat=$categoryId, search=$search)');
    try {
      var query = SupabaseService.client
          .from('fs_products')
          .select(_columns)
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      final result = await query
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (result as List).cast<Map<String, dynamic>>();
      _logDebug('fetchProducts OK — ${list.length} rows');
      return list.map(_flattenCategory).map(ProductModel.fromJson).toList();
    } catch (e, st) {
      _rethrowClassified(e, st, 'fetchProducts');
    }
  }

  @override
  Future<ProductModel?> getBySlug(String slug) async {
    _logDebug('getBySlug($slug)');
    try {
      final row = await SupabaseService.client
          .from('fs_products')
          .select(_columns)
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();

      if (row == null) {
        _logDebug('getBySlug($slug) — not found');
        return null;
      }
      _logDebug('getBySlug($slug) OK');
      return ProductModel.fromJson(_flattenCategory(row));
    } catch (e, st) {
      _rethrowClassified(e, st, 'getBySlug');
    }
  }

  @override
  Future<List<ProductModel>> fetchFlashProducts() async {
    _logDebug('fetchFlashProducts()');
    try {
      final result = await SupabaseService.client
          .from('fs_products')
          .select(_columns)
          .eq('is_active', true)
          .eq('is_flash', true)
          .order('id', ascending: false);

      final list = (result as List).cast<Map<String, dynamic>>();
      _logDebug('fetchFlashProducts OK — ${list.length} rows');
      return list.map(_flattenCategory).map(ProductModel.fromJson).toList();
    } catch (e, st) {
      _rethrowClassified(e, st, 'fetchFlashProducts');
    }
  }
}
