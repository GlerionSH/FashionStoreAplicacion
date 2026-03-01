import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

const _storageKey = 'fashionstore_cart_v1';

abstract class CartLocalDatasource {
  Future<List<CartItemModel>> load();
  Future<void> save(List<CartItemModel> items);
}

class CartLocalDatasourceImpl implements CartLocalDatasource {
  const CartLocalDatasourceImpl();

  @override
  Future<List<CartItemModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(CartItemModel.fromJson).toList();
  }

  @override
  Future<void> save(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }
}
