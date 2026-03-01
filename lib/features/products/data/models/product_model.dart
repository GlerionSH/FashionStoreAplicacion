import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    @JsonKey(name: 'name_es') String? nameEs,
    @JsonKey(name: 'name_en') String? nameEn,
    required String slug,
    String? description,
    @JsonKey(name: 'description_es') String? descriptionEs,
    @JsonKey(name: 'description_en') String? descriptionEn,
    @JsonKey(name: 'price_cents', fromJson: _safeInt) required int priceCents,
    @JsonKey(fromJson: _safeInt) required int stock,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'category_name_es') String? categoryNameEs,
    @JsonKey(name: 'category_name_en') String? categoryNameEn,
    @JsonKey(name: 'is_active', fromJson: _safeBool) required bool isActive,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required List<String> images,
    @JsonKey(name: 'product_type', fromJson: _safeString) required String productType,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required List<String> sizes,
    @JsonKey(name: 'size_stock', fromJson: _sizeStockFromJson, toJson: _sizeStockToJson)
    required Map<String, int> sizeStock,
    @JsonKey(name: 'is_flash', fromJson: _safeBool) required bool isFlash,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

List<String> _stringListFromJson(dynamic value) {
  if (value == null) return const <String>[];
  if (value is List) return value.map((e) => e.toString()).toList();
  return const <String>[];
}

dynamic _stringListToJson(List<String> value) => value;

int _safeInt(dynamic v) => v is num ? v.toInt() : 0;
bool _safeBool(dynamic v) => v == true;
String _safeString(dynamic v) => v is String ? v : 'simple';

Map<String, int> _sizeStockFromJson(dynamic value) {
  if (value == null) return const <String, int>{};
  if (value is Map) {
    return value.map(
      (k, v) => MapEntry(
        k.toString(),
        v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0,
      ),
    );
  }
  return const <String, int>{};
}

dynamic _sizeStockToJson(Map<String, int> value) => value;

extension ProductModelMapper on ProductModel {
  Product toEntity() => Product(
        id: id,
        name: name,
        nameEs: nameEs,
        nameEn: nameEn,
        slug: slug,
        description: description,
        descriptionEs: descriptionEs,
        descriptionEn: descriptionEn,
        priceCents: priceCents,
        stock: stock,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryNameEs: categoryNameEs,
        categoryNameEn: categoryNameEn,
        isActive: isActive,
        images: images,
        productType: productType,
        sizes: sizes,
        sizeStock: sizeStock,
        isFlash: isFlash,
      );
}
