import '../../../../shared/services/supabase_service.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDatasource {
  Future<List<OrderModel>> listOrders({
    required String userId,
    required String email,
  });
  Future<OrderModel?> getOrderById(String orderId);
  Future<List<OrderItemModel>> getOrderItems(String orderId);
}

class OrdersRemoteDatasourceImpl implements OrdersRemoteDatasource {
  const OrdersRemoteDatasourceImpl();

  static const _orderColumns =
      'id,created_at,email,user_id,subtotal_cents,discount_cents,'
      'total_cents,status,invoice_token,invoice_number,'
      'invoice_issued_at,paid_at,refund_total_cents,'
      'email_sent_at,email_last_error';

  static const _itemColumns =
      'id,order_id,product_id,name,qty,price_cents,'
      'line_total_cents,size,paid_unit_cents,paid_line_total_cents';

  @override
  Future<List<OrderModel>> listOrders({
    required String userId,
    required String email,
  }) async {
    final orFilter = (email.trim().isEmpty)
        ? 'user_id.eq.$userId'
        : 'user_id.eq.$userId,email.eq.${email.trim()}';

    final result = await SupabaseService.client
        .from('fs_orders')
        .select(_orderColumns)
        .or(orFilter)
        .order('created_at', ascending: false);

    return (result as List)
        .cast<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final row = await SupabaseService.client
        .from('fs_orders')
        .select(_orderColumns)
        .eq('id', orderId)
        .maybeSingle();

    if (row == null) return null;
    return OrderModel.fromJson(row);
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final result = await SupabaseService.client
        .from('fs_order_items')
        .select(_itemColumns)
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (result as List)
        .cast<Map<String, dynamic>>()
        .map(OrderItemModel.fromJson)
        .toList();
  }
}
