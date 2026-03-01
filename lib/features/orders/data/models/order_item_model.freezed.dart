// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) {
  return _OrderItemModel.fromJson(json);
}

/// @nodoc
mixin _$OrderItemModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_cents')
  int get priceCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'line_total_cents')
  int get lineTotalCents => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_unit_cents')
  int? get paidUnitCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_line_total_cents')
  int? get paidLineTotalCents => throw _privateConstructorUsedError;

  /// Serializes this OrderItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemModelCopyWith<OrderItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemModelCopyWith<$Res> {
  factory $OrderItemModelCopyWith(
    OrderItemModel value,
    $Res Function(OrderItemModel) then,
  ) = _$OrderItemModelCopyWithImpl<$Res, OrderItemModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'product_id') String productId,
    String name,
    int qty,
    @JsonKey(name: 'price_cents') int priceCents,
    @JsonKey(name: 'line_total_cents') int lineTotalCents,
    String? size,
    @JsonKey(name: 'paid_unit_cents') int? paidUnitCents,
    @JsonKey(name: 'paid_line_total_cents') int? paidLineTotalCents,
  });
}

/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res, $Val extends OrderItemModel>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? name = null,
    Object? qty = null,
    Object? priceCents = null,
    Object? lineTotalCents = null,
    Object? size = freezed,
    Object? paidUnitCents = freezed,
    Object? paidLineTotalCents = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as int,
            priceCents: null == priceCents
                ? _value.priceCents
                : priceCents // ignore: cast_nullable_to_non_nullable
                      as int,
            lineTotalCents: null == lineTotalCents
                ? _value.lineTotalCents
                : lineTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            paidUnitCents: freezed == paidUnitCents
                ? _value.paidUnitCents
                : paidUnitCents // ignore: cast_nullable_to_non_nullable
                      as int?,
            paidLineTotalCents: freezed == paidLineTotalCents
                ? _value.paidLineTotalCents
                : paidLineTotalCents // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemModelImplCopyWith<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  factory _$$OrderItemModelImplCopyWith(
    _$OrderItemModelImpl value,
    $Res Function(_$OrderItemModelImpl) then,
  ) = __$$OrderItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'product_id') String productId,
    String name,
    int qty,
    @JsonKey(name: 'price_cents') int priceCents,
    @JsonKey(name: 'line_total_cents') int lineTotalCents,
    String? size,
    @JsonKey(name: 'paid_unit_cents') int? paidUnitCents,
    @JsonKey(name: 'paid_line_total_cents') int? paidLineTotalCents,
  });
}

/// @nodoc
class __$$OrderItemModelImplCopyWithImpl<$Res>
    extends _$OrderItemModelCopyWithImpl<$Res, _$OrderItemModelImpl>
    implements _$$OrderItemModelImplCopyWith<$Res> {
  __$$OrderItemModelImplCopyWithImpl(
    _$OrderItemModelImpl _value,
    $Res Function(_$OrderItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? name = null,
    Object? qty = null,
    Object? priceCents = null,
    Object? lineTotalCents = null,
    Object? size = freezed,
    Object? paidUnitCents = freezed,
    Object? paidLineTotalCents = freezed,
  }) {
    return _then(
      _$OrderItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as int,
        priceCents: null == priceCents
            ? _value.priceCents
            : priceCents // ignore: cast_nullable_to_non_nullable
                  as int,
        lineTotalCents: null == lineTotalCents
            ? _value.lineTotalCents
            : lineTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        paidUnitCents: freezed == paidUnitCents
            ? _value.paidUnitCents
            : paidUnitCents // ignore: cast_nullable_to_non_nullable
                  as int?,
        paidLineTotalCents: freezed == paidLineTotalCents
            ? _value.paidLineTotalCents
            : paidLineTotalCents // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemModelImpl extends _OrderItemModel {
  const _$OrderItemModelImpl({
    required this.id,
    @JsonKey(name: 'order_id') required this.orderId,
    @JsonKey(name: 'product_id') required this.productId,
    required this.name,
    required this.qty,
    @JsonKey(name: 'price_cents') required this.priceCents,
    @JsonKey(name: 'line_total_cents') required this.lineTotalCents,
    this.size,
    @JsonKey(name: 'paid_unit_cents') this.paidUnitCents,
    @JsonKey(name: 'paid_line_total_cents') this.paidLineTotalCents,
  }) : super._();

  factory _$OrderItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final String name;
  @override
  final int qty;
  @override
  @JsonKey(name: 'price_cents')
  final int priceCents;
  @override
  @JsonKey(name: 'line_total_cents')
  final int lineTotalCents;
  @override
  final String? size;
  @override
  @JsonKey(name: 'paid_unit_cents')
  final int? paidUnitCents;
  @override
  @JsonKey(name: 'paid_line_total_cents')
  final int? paidLineTotalCents;

  @override
  String toString() {
    return 'OrderItemModel(id: $id, orderId: $orderId, productId: $productId, name: $name, qty: $qty, priceCents: $priceCents, lineTotalCents: $lineTotalCents, size: $size, paidUnitCents: $paidUnitCents, paidLineTotalCents: $paidLineTotalCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.priceCents, priceCents) ||
                other.priceCents == priceCents) &&
            (identical(other.lineTotalCents, lineTotalCents) ||
                other.lineTotalCents == lineTotalCents) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.paidUnitCents, paidUnitCents) ||
                other.paidUnitCents == paidUnitCents) &&
            (identical(other.paidLineTotalCents, paidLineTotalCents) ||
                other.paidLineTotalCents == paidLineTotalCents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    productId,
    name,
    qty,
    priceCents,
    lineTotalCents,
    size,
    paidUnitCents,
    paidLineTotalCents,
  );

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      __$$OrderItemModelImplCopyWithImpl<_$OrderItemModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemModelImplToJson(this);
  }
}

abstract class _OrderItemModel extends OrderItemModel {
  const factory _OrderItemModel({
    required final String id,
    @JsonKey(name: 'order_id') required final String orderId,
    @JsonKey(name: 'product_id') required final String productId,
    required final String name,
    required final int qty,
    @JsonKey(name: 'price_cents') required final int priceCents,
    @JsonKey(name: 'line_total_cents') required final int lineTotalCents,
    final String? size,
    @JsonKey(name: 'paid_unit_cents') final int? paidUnitCents,
    @JsonKey(name: 'paid_line_total_cents') final int? paidLineTotalCents,
  }) = _$OrderItemModelImpl;
  const _OrderItemModel._() : super._();

  factory _OrderItemModel.fromJson(Map<String, dynamic> json) =
      _$OrderItemModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  String get name;
  @override
  int get qty;
  @override
  @JsonKey(name: 'price_cents')
  int get priceCents;
  @override
  @JsonKey(name: 'line_total_cents')
  int get lineTotalCents;
  @override
  String? get size;
  @override
  @JsonKey(name: 'paid_unit_cents')
  int? get paidUnitCents;
  @override
  @JsonKey(name: 'paid_line_total_cents')
  int? get paidLineTotalCents;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
