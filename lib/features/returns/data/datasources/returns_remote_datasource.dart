import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/return_entity.dart';

abstract class ReturnsRemoteDatasource {
  /// Fetch all returns for the current user from Supabase.
  Future<List<ReturnEntity>> getMyReturns();

  /// Request a new return via Supabase insert.
  Future<String> requestReturn({
    required String orderId,
    String? reason,
    required List<ReturnRequestItem> items,
  });
}

class ReturnRequestItem {
  final String orderItemId;
  final int qty;

  const ReturnRequestItem({required this.orderItemId, required this.qty});

  Map<String, dynamic> toJson() => {
        'order_item_id': orderItemId,
        'qty': qty,
      };
}

class ReturnsRemoteDatasourceImpl implements ReturnsRemoteDatasource {
  const ReturnsRemoteDatasourceImpl();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<ReturnEntity>> getMyReturns() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No autenticado');

    // Get orders belonging to the current user (by email)
    final email = _client.auth.currentUser?.email;
    if (email == null) throw Exception('No se pudo obtener el email');

    final orderIds = await _client
        .from('fs_orders')
        .select('id')
        .eq('email', email);

    final ids = (orderIds as List).map((o) => o['id'] as String).toList();
    if (ids.isEmpty) return [];

    final rawReturns = await _client
        .from('fs_returns')
        .select('*, fs_return_items(*)')
        .inFilter('order_id', ids)
        .order('requested_at', ascending: false);

    return (rawReturns as List).map((raw) {
      final rawItems = raw['fs_return_items'] as List? ?? [];
      final items = rawItems
          .map((ri) => ReturnItemEntity(
                id: ri['id'] as String,
                orderItemId: ri['order_item_id'] as String,
                qty: ri['qty'] as int,
                lineTotalCents: (ri['line_total_cents'] as num?)?.toInt() ?? 0,
              ))
          .toList();

      return ReturnEntity(
        id: raw['id'] as String,
        orderId: raw['order_id'] as String,
        status: raw['status'] as String,
        reason: raw['reason'] as String?,
        requestedAt: DateTime.parse(raw['requested_at'] as String),
        reviewedAt: raw['reviewed_at'] != null
            ? DateTime.parse(raw['reviewed_at'] as String)
            : null,
        refundedAt: raw['refunded_at'] != null
            ? DateTime.parse(raw['refunded_at'] as String)
            : null,
        refundMethod: raw['refund_method'] as String? ?? 'manual',
        refundTotalCents: (raw['refund_total_cents'] as num?)?.toInt() ?? 0,
        currency: raw['currency'] as String? ?? 'EUR',
        notes: raw['notes'] as String?,
        items: items,
      );
    }).toList();
  }

  @override
  Future<String> requestReturn({
    required String orderId,
    String? reason,
    required List<ReturnRequestItem> items,
  }) async {
    // Insert the return request
    final returnData = await _client
        .from('fs_returns')
        .insert({
          'order_id': orderId,
          'reason': reason,
          'status': 'requested',
          'requested_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    final returnId = returnData['id'] as String;

    // Insert return items
    final returnItems = items
        .map((i) => {
              'return_id': returnId,
              ...i.toJson(),
            })
        .toList();

    await _client.from('fs_return_items').insert(returnItems);

    return returnId;
  }
}
