import 'package:freezed_annotation/freezed_annotation.dart';

part 'return_entity.freezed.dart';

@freezed
class ReturnEntity with _$ReturnEntity {
  const factory ReturnEntity({
    required String id,
    required String orderId,
    required String status,
    String? reason,
    required DateTime requestedAt,
    DateTime? reviewedAt,
    DateTime? refundedAt,
    required String refundMethod,
    required int refundTotalCents,
    required String currency,
    String? notes,
    @Default([]) List<ReturnItemEntity> items,
  }) = _ReturnEntity;
}

@freezed
class ReturnItemEntity with _$ReturnItemEntity {
  const factory ReturnItemEntity({
    required String id,
    required String orderItemId,
    required int qty,
    required int lineTotalCents,
  }) = _ReturnItemEntity;
}
