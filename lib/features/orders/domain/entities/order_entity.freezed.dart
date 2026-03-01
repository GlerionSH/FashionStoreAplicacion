// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrderEntity {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  int get subtotalCents => throw _privateConstructorUsedError;
  int get discountCents => throw _privateConstructorUsedError;
  int get totalCents => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get invoiceToken => throw _privateConstructorUsedError;
  String? get invoiceNumber => throw _privateConstructorUsedError;
  DateTime? get invoiceIssuedAt => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  int get refundTotalCents => throw _privateConstructorUsedError;
  DateTime? get emailSentAt => throw _privateConstructorUsedError;
  String? get emailLastError => throw _privateConstructorUsedError;
  String? get couponCode => throw _privateConstructorUsedError;
  int? get couponPercent => throw _privateConstructorUsedError;
  int get couponDiscountCents => throw _privateConstructorUsedError;
  DateTime? get cancelRequestedAt => throw _privateConstructorUsedError;
  DateTime? get refundedAt => throw _privateConstructorUsedError;
  String? get stripeRefundId => throw _privateConstructorUsedError;

  /// Create a copy of OrderEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderEntityCopyWith<OrderEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderEntityCopyWith<$Res> {
  factory $OrderEntityCopyWith(
    OrderEntity value,
    $Res Function(OrderEntity) then,
  ) = _$OrderEntityCopyWithImpl<$Res, OrderEntity>;
  @useResult
  $Res call({
    String id,
    DateTime createdAt,
    String? email,
    String? userId,
    int subtotalCents,
    int discountCents,
    int totalCents,
    String status,
    String? invoiceToken,
    String? invoiceNumber,
    DateTime? invoiceIssuedAt,
    DateTime? paidAt,
    int refundTotalCents,
    DateTime? emailSentAt,
    String? emailLastError,
    String? couponCode,
    int? couponPercent,
    int couponDiscountCents,
    DateTime? cancelRequestedAt,
    DateTime? refundedAt,
    String? stripeRefundId,
  });
}

/// @nodoc
class _$OrderEntityCopyWithImpl<$Res, $Val extends OrderEntity>
    implements $OrderEntityCopyWith<$Res> {
  _$OrderEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? userId = freezed,
    Object? subtotalCents = null,
    Object? discountCents = null,
    Object? totalCents = null,
    Object? status = null,
    Object? invoiceToken = freezed,
    Object? invoiceNumber = freezed,
    Object? invoiceIssuedAt = freezed,
    Object? paidAt = freezed,
    Object? refundTotalCents = null,
    Object? emailSentAt = freezed,
    Object? emailLastError = freezed,
    Object? couponCode = freezed,
    Object? couponPercent = freezed,
    Object? couponDiscountCents = null,
    Object? cancelRequestedAt = freezed,
    Object? refundedAt = freezed,
    Object? stripeRefundId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            subtotalCents: null == subtotalCents
                ? _value.subtotalCents
                : subtotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            discountCents: null == discountCents
                ? _value.discountCents
                : discountCents // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCents: null == totalCents
                ? _value.totalCents
                : totalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            invoiceToken: freezed == invoiceToken
                ? _value.invoiceToken
                : invoiceToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceNumber: freezed == invoiceNumber
                ? _value.invoiceNumber
                : invoiceNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceIssuedAt: freezed == invoiceIssuedAt
                ? _value.invoiceIssuedAt
                : invoiceIssuedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            refundTotalCents: null == refundTotalCents
                ? _value.refundTotalCents
                : refundTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            emailSentAt: freezed == emailSentAt
                ? _value.emailSentAt
                : emailSentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            emailLastError: freezed == emailLastError
                ? _value.emailLastError
                : emailLastError // ignore: cast_nullable_to_non_nullable
                      as String?,
            couponCode: freezed == couponCode
                ? _value.couponCode
                : couponCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            couponPercent: freezed == couponPercent
                ? _value.couponPercent
                : couponPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            couponDiscountCents: null == couponDiscountCents
                ? _value.couponDiscountCents
                : couponDiscountCents // ignore: cast_nullable_to_non_nullable
                      as int,
            cancelRequestedAt: freezed == cancelRequestedAt
                ? _value.cancelRequestedAt
                : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            refundedAt: freezed == refundedAt
                ? _value.refundedAt
                : refundedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            stripeRefundId: freezed == stripeRefundId
                ? _value.stripeRefundId
                : stripeRefundId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderEntityImplCopyWith<$Res>
    implements $OrderEntityCopyWith<$Res> {
  factory _$$OrderEntityImplCopyWith(
    _$OrderEntityImpl value,
    $Res Function(_$OrderEntityImpl) then,
  ) = __$$OrderEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime createdAt,
    String? email,
    String? userId,
    int subtotalCents,
    int discountCents,
    int totalCents,
    String status,
    String? invoiceToken,
    String? invoiceNumber,
    DateTime? invoiceIssuedAt,
    DateTime? paidAt,
    int refundTotalCents,
    DateTime? emailSentAt,
    String? emailLastError,
    String? couponCode,
    int? couponPercent,
    int couponDiscountCents,
    DateTime? cancelRequestedAt,
    DateTime? refundedAt,
    String? stripeRefundId,
  });
}

/// @nodoc
class __$$OrderEntityImplCopyWithImpl<$Res>
    extends _$OrderEntityCopyWithImpl<$Res, _$OrderEntityImpl>
    implements _$$OrderEntityImplCopyWith<$Res> {
  __$$OrderEntityImplCopyWithImpl(
    _$OrderEntityImpl _value,
    $Res Function(_$OrderEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? userId = freezed,
    Object? subtotalCents = null,
    Object? discountCents = null,
    Object? totalCents = null,
    Object? status = null,
    Object? invoiceToken = freezed,
    Object? invoiceNumber = freezed,
    Object? invoiceIssuedAt = freezed,
    Object? paidAt = freezed,
    Object? refundTotalCents = null,
    Object? emailSentAt = freezed,
    Object? emailLastError = freezed,
    Object? couponCode = freezed,
    Object? couponPercent = freezed,
    Object? couponDiscountCents = null,
    Object? cancelRequestedAt = freezed,
    Object? refundedAt = freezed,
    Object? stripeRefundId = freezed,
  }) {
    return _then(
      _$OrderEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        subtotalCents: null == subtotalCents
            ? _value.subtotalCents
            : subtotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        discountCents: null == discountCents
            ? _value.discountCents
            : discountCents // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCents: null == totalCents
            ? _value.totalCents
            : totalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        invoiceToken: freezed == invoiceToken
            ? _value.invoiceToken
            : invoiceToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceNumber: freezed == invoiceNumber
            ? _value.invoiceNumber
            : invoiceNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceIssuedAt: freezed == invoiceIssuedAt
            ? _value.invoiceIssuedAt
            : invoiceIssuedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        refundTotalCents: null == refundTotalCents
            ? _value.refundTotalCents
            : refundTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        emailSentAt: freezed == emailSentAt
            ? _value.emailSentAt
            : emailSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        emailLastError: freezed == emailLastError
            ? _value.emailLastError
            : emailLastError // ignore: cast_nullable_to_non_nullable
                  as String?,
        couponCode: freezed == couponCode
            ? _value.couponCode
            : couponCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        couponPercent: freezed == couponPercent
            ? _value.couponPercent
            : couponPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        couponDiscountCents: null == couponDiscountCents
            ? _value.couponDiscountCents
            : couponDiscountCents // ignore: cast_nullable_to_non_nullable
                  as int,
        cancelRequestedAt: freezed == cancelRequestedAt
            ? _value.cancelRequestedAt
            : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        refundedAt: freezed == refundedAt
            ? _value.refundedAt
            : refundedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stripeRefundId: freezed == stripeRefundId
            ? _value.stripeRefundId
            : stripeRefundId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$OrderEntityImpl implements _OrderEntity {
  const _$OrderEntityImpl({
    required this.id,
    required this.createdAt,
    this.email,
    this.userId,
    required this.subtotalCents,
    required this.discountCents,
    required this.totalCents,
    required this.status,
    this.invoiceToken,
    this.invoiceNumber,
    this.invoiceIssuedAt,
    this.paidAt,
    required this.refundTotalCents,
    this.emailSentAt,
    this.emailLastError,
    this.couponCode,
    this.couponPercent,
    this.couponDiscountCents = 0,
    this.cancelRequestedAt,
    this.refundedAt,
    this.stripeRefundId,
  });

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final String? email;
  @override
  final String? userId;
  @override
  final int subtotalCents;
  @override
  final int discountCents;
  @override
  final int totalCents;
  @override
  final String status;
  @override
  final String? invoiceToken;
  @override
  final String? invoiceNumber;
  @override
  final DateTime? invoiceIssuedAt;
  @override
  final DateTime? paidAt;
  @override
  final int refundTotalCents;
  @override
  final DateTime? emailSentAt;
  @override
  final String? emailLastError;
  @override
  final String? couponCode;
  @override
  final int? couponPercent;
  @override
  @JsonKey()
  final int couponDiscountCents;
  @override
  final DateTime? cancelRequestedAt;
  @override
  final DateTime? refundedAt;
  @override
  final String? stripeRefundId;

  @override
  String toString() {
    return 'OrderEntity(id: $id, createdAt: $createdAt, email: $email, userId: $userId, subtotalCents: $subtotalCents, discountCents: $discountCents, totalCents: $totalCents, status: $status, invoiceToken: $invoiceToken, invoiceNumber: $invoiceNumber, invoiceIssuedAt: $invoiceIssuedAt, paidAt: $paidAt, refundTotalCents: $refundTotalCents, emailSentAt: $emailSentAt, emailLastError: $emailLastError, couponCode: $couponCode, couponPercent: $couponPercent, couponDiscountCents: $couponDiscountCents, cancelRequestedAt: $cancelRequestedAt, refundedAt: $refundedAt, stripeRefundId: $stripeRefundId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subtotalCents, subtotalCents) ||
                other.subtotalCents == subtotalCents) &&
            (identical(other.discountCents, discountCents) ||
                other.discountCents == discountCents) &&
            (identical(other.totalCents, totalCents) ||
                other.totalCents == totalCents) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.invoiceToken, invoiceToken) ||
                other.invoiceToken == invoiceToken) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.invoiceIssuedAt, invoiceIssuedAt) ||
                other.invoiceIssuedAt == invoiceIssuedAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.refundTotalCents, refundTotalCents) ||
                other.refundTotalCents == refundTotalCents) &&
            (identical(other.emailSentAt, emailSentAt) ||
                other.emailSentAt == emailSentAt) &&
            (identical(other.emailLastError, emailLastError) ||
                other.emailLastError == emailLastError) &&
            (identical(other.couponCode, couponCode) ||
                other.couponCode == couponCode) &&
            (identical(other.couponPercent, couponPercent) ||
                other.couponPercent == couponPercent) &&
            (identical(other.couponDiscountCents, couponDiscountCents) ||
                other.couponDiscountCents == couponDiscountCents) &&
            (identical(other.cancelRequestedAt, cancelRequestedAt) ||
                other.cancelRequestedAt == cancelRequestedAt) &&
            (identical(other.refundedAt, refundedAt) ||
                other.refundedAt == refundedAt) &&
            (identical(other.stripeRefundId, stripeRefundId) ||
                other.stripeRefundId == stripeRefundId));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    createdAt,
    email,
    userId,
    subtotalCents,
    discountCents,
    totalCents,
    status,
    invoiceToken,
    invoiceNumber,
    invoiceIssuedAt,
    paidAt,
    refundTotalCents,
    emailSentAt,
    emailLastError,
    couponCode,
    couponPercent,
    couponDiscountCents,
    cancelRequestedAt,
    refundedAt,
    stripeRefundId,
  ]);

  /// Create a copy of OrderEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderEntityImplCopyWith<_$OrderEntityImpl> get copyWith =>
      __$$OrderEntityImplCopyWithImpl<_$OrderEntityImpl>(this, _$identity);
}

abstract class _OrderEntity implements OrderEntity {
  const factory _OrderEntity({
    required final String id,
    required final DateTime createdAt,
    final String? email,
    final String? userId,
    required final int subtotalCents,
    required final int discountCents,
    required final int totalCents,
    required final String status,
    final String? invoiceToken,
    final String? invoiceNumber,
    final DateTime? invoiceIssuedAt,
    final DateTime? paidAt,
    required final int refundTotalCents,
    final DateTime? emailSentAt,
    final String? emailLastError,
    final String? couponCode,
    final int? couponPercent,
    final int couponDiscountCents,
    final DateTime? cancelRequestedAt,
    final DateTime? refundedAt,
    final String? stripeRefundId,
  }) = _$OrderEntityImpl;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  String? get email;
  @override
  String? get userId;
  @override
  int get subtotalCents;
  @override
  int get discountCents;
  @override
  int get totalCents;
  @override
  String get status;
  @override
  String? get invoiceToken;
  @override
  String? get invoiceNumber;
  @override
  DateTime? get invoiceIssuedAt;
  @override
  DateTime? get paidAt;
  @override
  int get refundTotalCents;
  @override
  DateTime? get emailSentAt;
  @override
  String? get emailLastError;
  @override
  String? get couponCode;
  @override
  int? get couponPercent;
  @override
  int get couponDiscountCents;
  @override
  DateTime? get cancelRequestedAt;
  @override
  DateTime? get refundedAt;
  @override
  String? get stripeRefundId;

  /// Create a copy of OrderEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderEntityImplCopyWith<_$OrderEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
