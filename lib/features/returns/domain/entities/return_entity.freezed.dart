// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'return_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReturnEntity {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  DateTime? get refundedAt => throw _privateConstructorUsedError;
  String get refundMethod => throw _privateConstructorUsedError;
  int get refundTotalCents => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<ReturnItemEntity> get items => throw _privateConstructorUsedError;

  /// Create a copy of ReturnEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReturnEntityCopyWith<ReturnEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReturnEntityCopyWith<$Res> {
  factory $ReturnEntityCopyWith(
    ReturnEntity value,
    $Res Function(ReturnEntity) then,
  ) = _$ReturnEntityCopyWithImpl<$Res, ReturnEntity>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String status,
    String? reason,
    DateTime requestedAt,
    DateTime? reviewedAt,
    DateTime? refundedAt,
    String refundMethod,
    int refundTotalCents,
    String currency,
    String? notes,
    List<ReturnItemEntity> items,
  });
}

/// @nodoc
class _$ReturnEntityCopyWithImpl<$Res, $Val extends ReturnEntity>
    implements $ReturnEntityCopyWith<$Res> {
  _$ReturnEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReturnEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? reason = freezed,
    Object? requestedAt = null,
    Object? reviewedAt = freezed,
    Object? refundedAt = freezed,
    Object? refundMethod = null,
    Object? refundTotalCents = null,
    Object? currency = null,
    Object? notes = freezed,
    Object? items = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reviewedAt: freezed == reviewedAt
                ? _value.reviewedAt
                : reviewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            refundedAt: freezed == refundedAt
                ? _value.refundedAt
                : refundedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            refundMethod: null == refundMethod
                ? _value.refundMethod
                : refundMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            refundTotalCents: null == refundTotalCents
                ? _value.refundTotalCents
                : refundTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ReturnItemEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReturnEntityImplCopyWith<$Res>
    implements $ReturnEntityCopyWith<$Res> {
  factory _$$ReturnEntityImplCopyWith(
    _$ReturnEntityImpl value,
    $Res Function(_$ReturnEntityImpl) then,
  ) = __$$ReturnEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String status,
    String? reason,
    DateTime requestedAt,
    DateTime? reviewedAt,
    DateTime? refundedAt,
    String refundMethod,
    int refundTotalCents,
    String currency,
    String? notes,
    List<ReturnItemEntity> items,
  });
}

/// @nodoc
class __$$ReturnEntityImplCopyWithImpl<$Res>
    extends _$ReturnEntityCopyWithImpl<$Res, _$ReturnEntityImpl>
    implements _$$ReturnEntityImplCopyWith<$Res> {
  __$$ReturnEntityImplCopyWithImpl(
    _$ReturnEntityImpl _value,
    $Res Function(_$ReturnEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReturnEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? reason = freezed,
    Object? requestedAt = null,
    Object? reviewedAt = freezed,
    Object? refundedAt = freezed,
    Object? refundMethod = null,
    Object? refundTotalCents = null,
    Object? currency = null,
    Object? notes = freezed,
    Object? items = null,
  }) {
    return _then(
      _$ReturnEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reviewedAt: freezed == reviewedAt
            ? _value.reviewedAt
            : reviewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        refundedAt: freezed == refundedAt
            ? _value.refundedAt
            : refundedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        refundMethod: null == refundMethod
            ? _value.refundMethod
            : refundMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        refundTotalCents: null == refundTotalCents
            ? _value.refundTotalCents
            : refundTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ReturnItemEntity>,
      ),
    );
  }
}

/// @nodoc

class _$ReturnEntityImpl implements _ReturnEntity {
  const _$ReturnEntityImpl({
    required this.id,
    required this.orderId,
    required this.status,
    this.reason,
    required this.requestedAt,
    this.reviewedAt,
    this.refundedAt,
    required this.refundMethod,
    required this.refundTotalCents,
    required this.currency,
    this.notes,
    final List<ReturnItemEntity> items = const [],
  }) : _items = items;

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String status;
  @override
  final String? reason;
  @override
  final DateTime requestedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final DateTime? refundedAt;
  @override
  final String refundMethod;
  @override
  final int refundTotalCents;
  @override
  final String currency;
  @override
  final String? notes;
  final List<ReturnItemEntity> _items;
  @override
  @JsonKey()
  List<ReturnItemEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ReturnEntity(id: $id, orderId: $orderId, status: $status, reason: $reason, requestedAt: $requestedAt, reviewedAt: $reviewedAt, refundedAt: $refundedAt, refundMethod: $refundMethod, refundTotalCents: $refundTotalCents, currency: $currency, notes: $notes, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReturnEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.refundedAt, refundedAt) ||
                other.refundedAt == refundedAt) &&
            (identical(other.refundMethod, refundMethod) ||
                other.refundMethod == refundMethod) &&
            (identical(other.refundTotalCents, refundTotalCents) ||
                other.refundTotalCents == refundTotalCents) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    status,
    reason,
    requestedAt,
    reviewedAt,
    refundedAt,
    refundMethod,
    refundTotalCents,
    currency,
    notes,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of ReturnEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReturnEntityImplCopyWith<_$ReturnEntityImpl> get copyWith =>
      __$$ReturnEntityImplCopyWithImpl<_$ReturnEntityImpl>(this, _$identity);
}

abstract class _ReturnEntity implements ReturnEntity {
  const factory _ReturnEntity({
    required final String id,
    required final String orderId,
    required final String status,
    final String? reason,
    required final DateTime requestedAt,
    final DateTime? reviewedAt,
    final DateTime? refundedAt,
    required final String refundMethod,
    required final int refundTotalCents,
    required final String currency,
    final String? notes,
    final List<ReturnItemEntity> items,
  }) = _$ReturnEntityImpl;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get status;
  @override
  String? get reason;
  @override
  DateTime get requestedAt;
  @override
  DateTime? get reviewedAt;
  @override
  DateTime? get refundedAt;
  @override
  String get refundMethod;
  @override
  int get refundTotalCents;
  @override
  String get currency;
  @override
  String? get notes;
  @override
  List<ReturnItemEntity> get items;

  /// Create a copy of ReturnEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReturnEntityImplCopyWith<_$ReturnEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReturnItemEntity {
  String get id => throw _privateConstructorUsedError;
  String get orderItemId => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  int get lineTotalCents => throw _privateConstructorUsedError;

  /// Create a copy of ReturnItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReturnItemEntityCopyWith<ReturnItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReturnItemEntityCopyWith<$Res> {
  factory $ReturnItemEntityCopyWith(
    ReturnItemEntity value,
    $Res Function(ReturnItemEntity) then,
  ) = _$ReturnItemEntityCopyWithImpl<$Res, ReturnItemEntity>;
  @useResult
  $Res call({String id, String orderItemId, int qty, int lineTotalCents});
}

/// @nodoc
class _$ReturnItemEntityCopyWithImpl<$Res, $Val extends ReturnItemEntity>
    implements $ReturnItemEntityCopyWith<$Res> {
  _$ReturnItemEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReturnItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderItemId = null,
    Object? qty = null,
    Object? lineTotalCents = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderItemId: null == orderItemId
                ? _value.orderItemId
                : orderItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as int,
            lineTotalCents: null == lineTotalCents
                ? _value.lineTotalCents
                : lineTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReturnItemEntityImplCopyWith<$Res>
    implements $ReturnItemEntityCopyWith<$Res> {
  factory _$$ReturnItemEntityImplCopyWith(
    _$ReturnItemEntityImpl value,
    $Res Function(_$ReturnItemEntityImpl) then,
  ) = __$$ReturnItemEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String orderItemId, int qty, int lineTotalCents});
}

/// @nodoc
class __$$ReturnItemEntityImplCopyWithImpl<$Res>
    extends _$ReturnItemEntityCopyWithImpl<$Res, _$ReturnItemEntityImpl>
    implements _$$ReturnItemEntityImplCopyWith<$Res> {
  __$$ReturnItemEntityImplCopyWithImpl(
    _$ReturnItemEntityImpl _value,
    $Res Function(_$ReturnItemEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReturnItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderItemId = null,
    Object? qty = null,
    Object? lineTotalCents = null,
  }) {
    return _then(
      _$ReturnItemEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderItemId: null == orderItemId
            ? _value.orderItemId
            : orderItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as int,
        lineTotalCents: null == lineTotalCents
            ? _value.lineTotalCents
            : lineTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ReturnItemEntityImpl implements _ReturnItemEntity {
  const _$ReturnItemEntityImpl({
    required this.id,
    required this.orderItemId,
    required this.qty,
    required this.lineTotalCents,
  });

  @override
  final String id;
  @override
  final String orderItemId;
  @override
  final int qty;
  @override
  final int lineTotalCents;

  @override
  String toString() {
    return 'ReturnItemEntity(id: $id, orderItemId: $orderItemId, qty: $qty, lineTotalCents: $lineTotalCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReturnItemEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lineTotalCents, lineTotalCents) ||
                other.lineTotalCents == lineTotalCents));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, orderItemId, qty, lineTotalCents);

  /// Create a copy of ReturnItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReturnItemEntityImplCopyWith<_$ReturnItemEntityImpl> get copyWith =>
      __$$ReturnItemEntityImplCopyWithImpl<_$ReturnItemEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ReturnItemEntity implements ReturnItemEntity {
  const factory _ReturnItemEntity({
    required final String id,
    required final String orderItemId,
    required final int qty,
    required final int lineTotalCents,
  }) = _$ReturnItemEntityImpl;

  @override
  String get id;
  @override
  String get orderItemId;
  @override
  int get qty;
  @override
  int get lineTotalCents;

  /// Create a copy of ReturnItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReturnItemEntityImplCopyWith<_$ReturnItemEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
