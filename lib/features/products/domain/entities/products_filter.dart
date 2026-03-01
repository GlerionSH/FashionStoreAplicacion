import 'package:freezed_annotation/freezed_annotation.dart';

part 'products_filter.freezed.dart';

@freezed
class ProductsFilter with _$ProductsFilter {
  const factory ProductsFilter({
    String? categoryId,
    String? search,
    @Default(0) int page,
  }) = _ProductsFilter;
}
