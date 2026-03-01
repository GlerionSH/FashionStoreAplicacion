import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? nameEs,
    String? nameEn,
    required String slug,
  }) = _Category;
}
