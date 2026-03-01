// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'subtotal_cents')
  int get subtotalCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_cents')
  int get discountCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_cents')
  int get totalCents => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_token')
  String? get invoiceToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_number')
  String? get invoiceNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_issued_at')
  String? get invoiceIssuedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_at')
  String? get paidAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'refund_total_cents')
  int get refundTotalCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_sent_at')
  String? get emailSentAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_last_error')
  String? get emailLastError => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_code')
  String? get couponCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_percent')
  int? get couponPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_discount_cents')
  int get couponDiscountCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancel_requested_at')
  String? get cancelRequestedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'refunded_at')
  String? get refundedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'stripe_refund_id')
  String? get stripeRefundId => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'created_at') String createdAt,
    String? email,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'subtotal_cents') int subtotalCents,
    @JsonKey(name: 'discount_cents') int discountCents,
    @JsonKey(name: 'total_cents') int totalCents,
    String status,
    @JsonKey(name: 'invoice_token') String? invoiceToken,
    @JsonKey(name: 'invoice_number') String? invoiceNumber,
    @JsonKey(name: 'invoice_issued_at') String? invoiceIssuedAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'refund_total_cents') int refundTotalCents,
    @JsonKey(name: 'email_sent_at') String? emailSentAt,
    @JsonKey(name: 'email_last_error') String? emailLastError,
    @JsonKey(name: 'coupon_code') String? couponCode,
    @JsonKey(name: 'coupon_percent') int? couponPercent,
    @JsonKey(name: 'coupon_discount_cents') int couponDiscountCents,
    @JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,
    @JsonKey(name: 'refunded_at') String? refundedAt,
    @JsonKey(name: 'stripe_refund_id') String? stripeRefundId,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
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
                      as String,
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
                      as String?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            refundTotalCents: null == refundTotalCents
                ? _value.refundTotalCents
                : refundTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            emailSentAt: freezed == emailSentAt
                ? _value.emailSentAt
                : emailSentAt // ignore: cast_nullable_to_non_nullable
                      as String?,
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
                      as String?,
            refundedAt: freezed == refundedAt
                ? _value.refundedAt
                : refundedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'created_at') String createdAt,
    String? email,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'subtotal_cents') int subtotalCents,
    @JsonKey(name: 'discount_cents') int discountCents,
    @JsonKey(name: 'total_cents') int totalCents,
    String status,
    @JsonKey(name: 'invoice_token') String? invoiceToken,
    @JsonKey(name: 'invoice_number') String? invoiceNumber,
    @JsonKey(name: 'invoice_issued_at') String? invoiceIssuedAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'refund_total_cents') int refundTotalCents,
    @JsonKey(name: 'email_sent_at') String? emailSentAt,
    @JsonKey(name: 'email_last_error') String? emailLastError,
    @JsonKey(name: 'coupon_code') String? couponCode,
    @JsonKey(name: 'coupon_percent') int? couponPercent,
    @JsonKey(name: 'coupon_discount_cents') int couponDiscountCents,
    @JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,
    @JsonKey(name: 'refunded_at') String? refundedAt,
    @JsonKey(name: 'stripe_refund_id') String? stripeRefundId,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
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
      _$OrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
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
                  as String?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        refundTotalCents: null == refundTotalCents
            ? _value.refundTotalCents
            : refundTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        emailSentAt: freezed == emailSentAt
            ? _value.emailSentAt
            : emailSentAt // ignore: cast_nullable_to_non_nullable
                  as String?,
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
                  as String?,
        refundedAt: freezed == refundedAt
            ? _value.refundedAt
            : refundedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        stripeRefundId: freezed == stripeRefundId
            ? _value.stripeRefundId
            : stripeRefundId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    @JsonKey(name: 'created_at') required this.createdAt,
    this.email,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'subtotal_cents') required this.subtotalCents,
    @JsonKey(name: 'discount_cents') this.discountCents = 0,
    @JsonKey(name: 'total_cents') required this.totalCents,
    required this.status,
    @JsonKey(name: 'invoice_token') this.invoiceToken,
    @JsonKey(name: 'invoice_number') this.invoiceNumber,
    @JsonKey(name: 'invoice_issued_at') this.invoiceIssuedAt,
    @JsonKey(name: 'paid_at') this.paidAt,
    @JsonKey(name: 'refund_total_cents') this.refundTotalCents = 0,
    @JsonKey(name: 'email_sent_at') this.emailSentAt,
    @JsonKey(name: 'email_last_error') this.emailLastError,
    @JsonKey(name: 'coupon_code') this.couponCode,
    @JsonKey(name: 'coupon_percent') this.couponPercent,
    @JsonKey(name: 'coupon_discount_cents') this.couponDiscountCents = 0,
    @JsonKey(name: 'cancel_requested_at') this.cancelRequestedAt,
    @JsonKey(name: 'refunded_at') this.refundedAt,
    @JsonKey(name: 'stripe_refund_id') this.stripeRefundId,
  }) : super._();

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  final String? email;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'subtotal_cents')
  final int subtotalCents;
  @override
  @JsonKey(name: 'discount_cents')
  final int discountCents;
  @override
  @JsonKey(name: 'total_cents')
  final int totalCents;
  @override
  final String status;
  @override
  @JsonKey(name: 'invoice_token')
  final String? invoiceToken;
  @override
  @JsonKey(name: 'invoice_number')
  final String? invoiceNumber;
  @override
  @JsonKey(name: 'invoice_issued_at')
  final String? invoiceIssuedAt;
  @override
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  @override
  @JsonKey(name: 'refund_total_cents')
  final int refundTotalCents;
  @override
  @JsonKey(name: 'email_sent_at')
  final String? emailSentAt;
  @override
  @JsonKey(name: 'email_last_error')
  final String? emailLastError;
  @override
  @JsonKey(name: 'coupon_code')
  final String? couponCode;
  @override
  @JsonKey(name: 'coupon_percent')
  final int? couponPercent;
  @override
  @JsonKey(name: 'coupon_discount_cents')
  final int couponDiscountCents;
  @override
  @JsonKey(name: 'cancel_requested_at')
  final String? cancelRequestedAt;
  @override
  @JsonKey(name: 'refunded_at')
  final String? refundedAt;
  @override
  @JsonKey(name: 'stripe_refund_id')
  final String? stripeRefundId;

  @override
  String toString() {
    return 'OrderModel(id: $id, createdAt: $createdAt, email: $email, userId: $userId, subtotalCents: $subtotalCents, discountCents: $discountCents, totalCents: $totalCents, status: $status, invoiceToken: $invoiceToken, invoiceNumber: $invoiceNumber, invoiceIssuedAt: $invoiceIssuedAt, paidAt: $paidAt, refundTotalCents: $refundTotalCents, emailSentAt: $emailSentAt, emailLastError: $emailLastError, couponCode: $couponCode, couponPercent: $couponPercent, couponDiscountCents: $couponDiscountCents, cancelRequestedAt: $cancelRequestedAt, refundedAt: $refundedAt, stripeRefundId: $stripeRefundId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(this);
  }
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel({
    required final String id,
    @JsonKey(name: 'created_at') required final String createdAt,
    final String? email,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'subtotal_cents') required final int subtotalCents,
    @JsonKey(name: 'discount_cents') final int discountCents,
    @JsonKey(name: 'total_cents') required final int totalCents,
    required final String status,
    @JsonKey(name: 'invoice_token') final String? invoiceToken,
    @JsonKey(name: 'invoice_number') final String? invoiceNumber,
    @JsonKey(name: 'invoice_issued_at') final String? invoiceIssuedAt,
    @JsonKey(name: 'paid_at') final String? paidAt,
    @JsonKey(name: 'refund_total_cents') final int refundTotalCents,
    @JsonKey(name: 'email_sent_at') final String? emailSentAt,
    @JsonKey(name: 'email_last_error') final String? emailLastError,
    @JsonKey(name: 'coupon_code') final String? couponCode,
    @JsonKey(name: 'coupon_percent') final int? couponPercent,
    @JsonKey(name: 'coupon_discount_cents') final int couponDiscountCents,
    @JsonKey(name: 'cancel_requested_at') final String? cancelRequestedAt,
    @JsonKey(name: 'refunded_at') final String? refundedAt,
    @JsonKey(name: 'stripe_refund_id') final String? stripeRefundId,
  }) = _$OrderModelImpl;
  const _OrderModel._() : super._();

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  String? get email;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'subtotal_cents')
  int get subtotalCents;
  @override
  @JsonKey(name: 'discount_cents')
  int get discountCents;
  @override
  @JsonKey(name: 'total_cents')
  int get totalCents;
  @override
  String get status;
  @override
  @JsonKey(name: 'invoice_token')
  String? get invoiceToken;
  @override
  @JsonKey(name: 'invoice_number')
  String? get invoiceNumber;
  @override
  @JsonKey(name: 'invoice_issued_at')
  String? get invoiceIssuedAt;
  @override
  @JsonKey(name: 'paid_at')
  String? get paidAt;
  @override
  @JsonKey(name: 'refund_total_cents')
  int get refundTotalCents;
  @override
  @JsonKey(name: 'email_sent_at')
  String? get emailSentAt;
  @override
  @JsonKey(name: 'email_last_error')
  String? get emailLastError;
  @override
  @JsonKey(name: 'coupon_code')
  String? get couponCode;
  @override
  @JsonKey(name: 'coupon_percent')
  int? get couponPercent;
  @override
  @JsonKey(name: 'coupon_discount_cents')
  int get couponDiscountCents;
  @override
  @JsonKey(name: 'cancel_requested_at')
  String? get cancelRequestedAt;
  @override
  @JsonKey(name: 'refunded_at')
  String? get refundedAt;
  @override
  @JsonKey(name: 'stripe_refund_id')
  String? get stripeRefundId;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
