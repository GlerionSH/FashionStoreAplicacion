import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    @JsonKey(name: 'name_es') String? nameEs,
    @JsonKey(name: 'name_en') String? nameEn,
    required String slug,
  }) = _CategoryModel;

  const CategoryModel._();

  Category toEntity() => Category(
        id: id,
        name: name,
        nameEs: nameEs,
        nameEn: nameEn,
        slug: slug,
      );

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}
