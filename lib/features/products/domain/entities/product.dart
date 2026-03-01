import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? nameEs,
    String? nameEn,
    required String slug,
    String? description,
    String? descriptionEs,
    String? descriptionEn,
    required int priceCents,
    required int stock,
    String? categoryId,
    String? categoryName,
    String? categoryNameEs,
    String? categoryNameEn,
    required bool isActive,
    required List<String> images,
    required String productType,
    required List<String> sizes,
    required Map<String, int> sizeStock,
    required bool isFlash,
  }) = _Product;
}
