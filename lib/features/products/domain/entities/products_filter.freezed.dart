// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductsFilter {
  String? get categoryId => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;

  /// Create a copy of ProductsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductsFilterCopyWith<ProductsFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductsFilterCopyWith<$Res> {
  factory $ProductsFilterCopyWith(
    ProductsFilter value,
    $Res Function(ProductsFilter) then,
  ) = _$ProductsFilterCopyWithImpl<$Res, ProductsFilter>;
  @useResult
  $Res call({String? categoryId, String? search, int page});
}

/// @nodoc
class _$ProductsFilterCopyWithImpl<$Res, $Val extends ProductsFilter>
    implements $ProductsFilterCopyWith<$Res> {
  _$ProductsFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? search = freezed,
    Object? page = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            search: freezed == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String?,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductsFilterImplCopyWith<$Res>
    implements $ProductsFilterCopyWith<$Res> {
  factory _$$ProductsFilterImplCopyWith(
    _$ProductsFilterImpl value,
    $Res Function(_$ProductsFilterImpl) then,
  ) = __$$ProductsFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? categoryId, String? search, int page});
}

/// @nodoc
class __$$ProductsFilterImplCopyWithImpl<$Res>
    extends _$ProductsFilterCopyWithImpl<$Res, _$ProductsFilterImpl>
    implements _$$ProductsFilterImplCopyWith<$Res> {
  __$$ProductsFilterImplCopyWithImpl(
    _$ProductsFilterImpl _value,
    $Res Function(_$ProductsFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = freezed,
    Object? search = freezed,
    Object? page = null,
  }) {
    return _then(
      _$ProductsFilterImpl(
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        search: freezed == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String?,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ProductsFilterImpl implements _ProductsFilter {
  const _$ProductsFilterImpl({this.categoryId, this.search, this.page = 0});

  @override
  final String? categoryId;
  @override
  final String? search;
  @override
  @JsonKey()
  final int page;

  @override
  String toString() {
    return 'ProductsFilter(categoryId: $categoryId, search: $search, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductsFilterImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.page, page) || other.page == page));
  }

  @override
  int get hashCode => Object.hash(runtimeType, categoryId, search, page);

  /// Create a copy of ProductsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductsFilterImplCopyWith<_$ProductsFilterImpl> get copyWith =>
      __$$ProductsFilterImplCopyWithImpl<_$ProductsFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductsFilter implements ProductsFilter {
  const factory _ProductsFilter({
    final String? categoryId,
    final String? search,
    final int page,
  }) = _$ProductsFilterImpl;

  @override
  String? get categoryId;
  @override
  String? get search;
  @override
  int get page;

  /// Create a copy of ProductsFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductsFilterImplCopyWith<_$ProductsFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
