// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_es')
  String? get nameEs => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_en')
  String? get nameEn => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'description_es')
  String? get descriptionEs => throw _privateConstructorUsedError;
  @JsonKey(name: 'description_en')
  String? get descriptionEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_cents', fromJson: _safeInt)
  int get priceCents => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _safeInt)
  int get stock => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name')
  String? get categoryName => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name_es')
  String? get categoryNameEs => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name_en')
  String? get categoryNameEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active', fromJson: _safeBool)
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_type', fromJson: _safeString)
  String get productType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get sizes => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'size_stock',
    fromJson: _sizeStockFromJson,
    toJson: _sizeStockToJson,
  )
  Map<String, int> get sizeStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_flash', fromJson: _safeBool)
  bool get isFlash => throw _privateConstructorUsedError;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'name_es') String? nameEs,
    @JsonKey(name: 'name_en') String? nameEn,
    String slug,
    String? description,
    @JsonKey(name: 'description_es') String? descriptionEs,
    @JsonKey(name: 'description_en') String? descriptionEn,
    @JsonKey(name: 'price_cents', fromJson: _safeInt) int priceCents,
    @JsonKey(fromJson: _safeInt) int stock,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'category_name_es') String? categoryNameEs,
    @JsonKey(name: 'category_name_en') String? categoryNameEn,
    @JsonKey(name: 'is_active', fromJson: _safeBool) bool isActive,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String> images,
    @JsonKey(name: 'product_type', fromJson: _safeString) String productType,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String> sizes,
    @JsonKey(
      name: 'size_stock',
      fromJson: _sizeStockFromJson,
      toJson: _sizeStockToJson,
    )
    Map<String, int> sizeStock,
    @JsonKey(name: 'is_flash', fromJson: _safeBool) bool isFlash,
  });
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameEs = freezed,
    Object? nameEn = freezed,
    Object? slug = null,
    Object? description = freezed,
    Object? descriptionEs = freezed,
    Object? descriptionEn = freezed,
    Object? priceCents = null,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryNameEs = freezed,
    Object? categoryNameEn = freezed,
    Object? isActive = null,
    Object? images = null,
    Object? productType = null,
    Object? sizes = null,
    Object? sizeStock = null,
    Object? isFlash = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEs: freezed == nameEs
                ? _value.nameEs
                : nameEs // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameEn: freezed == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String?,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            descriptionEs: freezed == descriptionEs
                ? _value.descriptionEs
                : descriptionEs // ignore: cast_nullable_to_non_nullable
                      as String?,
            descriptionEn: freezed == descriptionEn
                ? _value.descriptionEn
                : descriptionEn // ignore: cast_nullable_to_non_nullable
                      as String?,
            priceCents: null == priceCents
                ? _value.priceCents
                : priceCents // ignore: cast_nullable_to_non_nullable
                      as int,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryName: freezed == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryNameEs: freezed == categoryNameEs
                ? _value.categoryNameEs
                : categoryNameEs // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryNameEn: freezed == categoryNameEn
                ? _value.categoryNameEn
                : categoryNameEn // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            productType: null == productType
                ? _value.productType
                : productType // ignore: cast_nullable_to_non_nullable
                      as String,
            sizes: null == sizes
                ? _value.sizes
                : sizes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sizeStock: null == sizeStock
                ? _value.sizeStock
                : sizeStock // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            isFlash: null == isFlash
                ? _value.isFlash
                : isFlash // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
    _$ProductModelImpl value,
    $Res Function(_$ProductModelImpl) then,
  ) = __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'name_es') String? nameEs,
    @JsonKey(name: 'name_en') String? nameEn,
    String slug,
    String? description,
    @JsonKey(name: 'description_es') String? descriptionEs,
    @JsonKey(name: 'description_en') String? descriptionEn,
    @JsonKey(name: 'price_cents', fromJson: _safeInt) int priceCents,
    @JsonKey(fromJson: _safeInt) int stock,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'category_name_es') String? categoryNameEs,
    @JsonKey(name: 'category_name_en') String? categoryNameEn,
    @JsonKey(name: 'is_active', fromJson: _safeBool) bool isActive,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String> images,
    @JsonKey(name: 'product_type', fromJson: _safeString) String productType,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String> sizes,
    @JsonKey(
      name: 'size_stock',
      fromJson: _sizeStockFromJson,
      toJson: _sizeStockToJson,
    )
    Map<String, int> sizeStock,
    @JsonKey(name: 'is_flash', fromJson: _safeBool) bool isFlash,
  });
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
    _$ProductModelImpl _value,
    $Res Function(_$ProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameEs = freezed,
    Object? nameEn = freezed,
    Object? slug = null,
    Object? description = freezed,
    Object? descriptionEs = freezed,
    Object? descriptionEn = freezed,
    Object? priceCents = null,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryNameEs = freezed,
    Object? categoryNameEn = freezed,
    Object? isActive = null,
    Object? images = null,
    Object? productType = null,
    Object? sizes = null,
    Object? sizeStock = null,
    Object? isFlash = null,
  }) {
    return _then(
      _$ProductModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEs: freezed == nameEs
            ? _value.nameEs
            : nameEs // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameEn: freezed == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String?,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        descriptionEs: freezed == descriptionEs
            ? _value.descriptionEs
            : descriptionEs // ignore: cast_nullable_to_non_nullable
                  as String?,
        descriptionEn: freezed == descriptionEn
            ? _value.descriptionEn
            : descriptionEn // ignore: cast_nullable_to_non_nullable
                  as String?,
        priceCents: null == priceCents
            ? _value.priceCents
            : priceCents // ignore: cast_nullable_to_non_nullable
                  as int,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryName: freezed == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryNameEs: freezed == categoryNameEs
            ? _value.categoryNameEs
            : categoryNameEs // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryNameEn: freezed == categoryNameEn
            ? _value.categoryNameEn
            : categoryNameEn // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        productType: null == productType
            ? _value.productType
            : productType // ignore: cast_nullable_to_non_nullable
                  as String,
        sizes: null == sizes
            ? _value._sizes
            : sizes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sizeStock: null == sizeStock
            ? _value._sizeStock
            : sizeStock // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        isFlash: null == isFlash
            ? _value.isFlash
            : isFlash // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'name_es') this.nameEs,
    @JsonKey(name: 'name_en') this.nameEn,
    required this.slug,
    this.description,
    @JsonKey(name: 'description_es') this.descriptionEs,
    @JsonKey(name: 'description_en') this.descriptionEn,
    @JsonKey(name: 'price_cents', fromJson: _safeInt) required this.priceCents,
    @JsonKey(fromJson: _safeInt) required this.stock,
    @JsonKey(name: 'category_id') this.categoryId,
    @JsonKey(name: 'category_name') this.categoryName,
    @JsonKey(name: 'category_name_es') this.categoryNameEs,
    @JsonKey(name: 'category_name_en') this.categoryNameEn,
    @JsonKey(name: 'is_active', fromJson: _safeBool) required this.isActive,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required final List<String> images,
    @JsonKey(name: 'product_type', fromJson: _safeString)
    required this.productType,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required final List<String> sizes,
    @JsonKey(
      name: 'size_stock',
      fromJson: _sizeStockFromJson,
      toJson: _sizeStockToJson,
    )
    required final Map<String, int> sizeStock,
    @JsonKey(name: 'is_flash', fromJson: _safeBool) required this.isFlash,
  }) : _images = images,
       _sizes = sizes,
       _sizeStock = sizeStock;

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'name_es')
  final String? nameEs;
  @override
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @override
  final String slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'description_es')
  final String? descriptionEs;
  @override
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @override
  @JsonKey(name: 'price_cents', fromJson: _safeInt)
  final int priceCents;
  @override
  @JsonKey(fromJson: _safeInt)
  final int stock;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @override
  @JsonKey(name: 'category_name_es')
  final String? categoryNameEs;
  @override
  @JsonKey(name: 'category_name_en')
  final String? categoryNameEn;
  @override
  @JsonKey(name: 'is_active', fromJson: _safeBool)
  final bool isActive;
  final List<String> _images;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey(name: 'product_type', fromJson: _safeString)
  final String productType;
  final List<String> _sizes;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get sizes {
    if (_sizes is EqualUnmodifiableListView) return _sizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sizes);
  }

  final Map<String, int> _sizeStock;
  @override
  @JsonKey(
    name: 'size_stock',
    fromJson: _sizeStockFromJson,
    toJson: _sizeStockToJson,
  )
  Map<String, int> get sizeStock {
    if (_sizeStock is EqualUnmodifiableMapView) return _sizeStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sizeStock);
  }

  @override
  @JsonKey(name: 'is_flash', fromJson: _safeBool)
  final bool isFlash;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, nameEs: $nameEs, nameEn: $nameEn, slug: $slug, description: $description, descriptionEs: $descriptionEs, descriptionEn: $descriptionEn, priceCents: $priceCents, stock: $stock, categoryId: $categoryId, categoryName: $categoryName, categoryNameEs: $categoryNameEs, categoryNameEn: $categoryNameEn, isActive: $isActive, images: $images, productType: $productType, sizes: $sizes, sizeStock: $sizeStock, isFlash: $isFlash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameEs, nameEs) || other.nameEs == nameEs) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionEs, descriptionEs) ||
                other.descriptionEs == descriptionEs) &&
            (identical(other.descriptionEn, descriptionEn) ||
                other.descriptionEn == descriptionEn) &&
            (identical(other.priceCents, priceCents) ||
                other.priceCents == priceCents) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryNameEs, categoryNameEs) ||
                other.categoryNameEs == categoryNameEs) &&
            (identical(other.categoryNameEn, categoryNameEn) ||
                other.categoryNameEn == categoryNameEn) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.productType, productType) ||
                other.productType == productType) &&
            const DeepCollectionEquality().equals(other._sizes, _sizes) &&
            const DeepCollectionEquality().equals(
              other._sizeStock,
              _sizeStock,
            ) &&
            (identical(other.isFlash, isFlash) || other.isFlash == isFlash));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    nameEs,
    nameEn,
    slug,
    description,
    descriptionEs,
    descriptionEn,
    priceCents,
    stock,
    categoryId,
    categoryName,
    categoryNameEs,
    categoryNameEn,
    isActive,
    const DeepCollectionEquality().hash(_images),
    productType,
    const DeepCollectionEquality().hash(_sizes),
    const DeepCollectionEquality().hash(_sizeStock),
    isFlash,
  ]);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(this);
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel({
    required final String id,
    required final String name,
    @JsonKey(name: 'name_es') final String? nameEs,
    @JsonKey(name: 'name_en') final String? nameEn,
    required final String slug,
    final String? description,
    @JsonKey(name: 'description_es') final String? descriptionEs,
    @JsonKey(name: 'description_en') final String? descriptionEn,
    @JsonKey(name: 'price_cents', fromJson: _safeInt)
    required final int priceCents,
    @JsonKey(fromJson: _safeInt) required final int stock,
    @JsonKey(name: 'category_id') final String? categoryId,
    @JsonKey(name: 'category_name') final String? categoryName,
    @JsonKey(name: 'category_name_es') final String? categoryNameEs,
    @JsonKey(name: 'category_name_en') final String? categoryNameEn,
    @JsonKey(name: 'is_active', fromJson: _safeBool)
    required final bool isActive,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required final List<String> images,
    @JsonKey(name: 'product_type', fromJson: _safeString)
    required final String productType,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    required final List<String> sizes,
    @JsonKey(
      name: 'size_stock',
      fromJson: _sizeStockFromJson,
      toJson: _sizeStockToJson,
    )
    required final Map<String, int> sizeStock,
    @JsonKey(name: 'is_flash', fromJson: _safeBool) required final bool isFlash,
  }) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'name_es')
  String? get nameEs;
  @override
  @JsonKey(name: 'name_en')
  String? get nameEn;
  @override
  String get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'description_es')
  String? get descriptionEs;
  @override
  @JsonKey(name: 'description_en')
  String? get descriptionEn;
  @override
  @JsonKey(name: 'price_cents', fromJson: _safeInt)
  int get priceCents;
  @override
  @JsonKey(fromJson: _safeInt)
  int get stock;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'category_name')
  String? get categoryName;
  @override
  @JsonKey(name: 'category_name_es')
  String? get categoryNameEs;
  @override
  @JsonKey(name: 'category_name_en')
  String? get categoryNameEn;
  @override
  @JsonKey(name: 'is_active', fromJson: _safeBool)
  bool get isActive;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get images;
  @override
  @JsonKey(name: 'product_type', fromJson: _safeString)
  String get productType;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String> get sizes;
  @override
  @JsonKey(
    name: 'size_stock',
    fromJson: _sizeStockFromJson,
    toJson: _sizeStockToJson,
  )
  Map<String, int> get sizeStock;
  @override
  @JsonKey(name: 'is_flash', fromJson: _safeBool)
  bool get isFlash;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
