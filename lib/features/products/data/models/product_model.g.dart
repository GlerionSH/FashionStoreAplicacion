// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEs: json['name_es'] as String?,
      nameEn: json['name_en'] as String?,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      descriptionEs: json['description_es'] as String?,
      descriptionEn: json['description_en'] as String?,
      priceCents: _safeInt(json['price_cents']),
      stock: _safeInt(json['stock']),
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      categoryNameEs: json['category_name_es'] as String?,
      categoryNameEn: json['category_name_en'] as String?,
      isActive: _safeBool(json['is_active']),
      images: _stringListFromJson(json['images']),
      productType: _safeString(json['product_type']),
      sizes: _stringListFromJson(json['sizes']),
      sizeStock: _sizeStockFromJson(json['size_stock']),
      isFlash: _safeBool(json['is_flash']),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_es': instance.nameEs,
      'name_en': instance.nameEn,
      'slug': instance.slug,
      'description': instance.description,
      'description_es': instance.descriptionEs,
      'description_en': instance.descriptionEn,
      'price_cents': instance.priceCents,
      'stock': instance.stock,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'category_name_es': instance.categoryNameEs,
      'category_name_en': instance.categoryNameEn,
      'is_active': instance.isActive,
      'images': _stringListToJson(instance.images),
      'product_type': instance.productType,
      'sizes': _stringListToJson(instance.sizes),
      'size_stock': _sizeStockToJson(instance.sizeStock),
      'is_flash': instance.isFlash,
    };
