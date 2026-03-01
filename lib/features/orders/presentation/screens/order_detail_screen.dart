import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/files/pdf_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../providers/orders_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAv = ref.watch(orderDetailProvider(orderId));
    final itemsAv = ref.watch(orderItemsProvider(orderId));
    final t = S.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('[OrderDetailScreen] Back navigation');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(t.ordersDetail)),
        body: orderAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (either) => either.fold(
          (failure) => Center(child: Text(failure.message)),
          (order) {
            if (order == null) {
              return Center(child: Text(t.ordersNotFound));
            }
            return _OrderDetailBody(
              order: order,
              itemsAv: itemsAv,
            );
          },
        ),
      ),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final OrderEntity order;
  final AsyncValue<Either<Failure, List<OrderItemEntity>>> itemsAv;

  const _OrderDetailBody({
    required this.order,
    required this.itemsAv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          _InfoRow(t.checkoutOrder, '${order.id.substring(0, 8)}...'),
          _InfoRow(t.ordersDate, _formatDateTime(order.createdAt)),
          _InfoRow(t.ordersStatus, _statusLabel(t, order.status)),
          if (order.paidAt != null)
            _InfoRow(t.ordersPaidAt, _formatDateTime(order.paidAt!)),

          const Divider(height: 32),

          // Totals
          _InfoRow(t.ordersSubtotal, _formatCents(order.subtotalCents)),
          if (order.discountCents > 0)
            _InfoRow(t.ordersDiscount, '- ${_formatCents(order.discountCents)}'),
          if (order.couponDiscountCents > 0)
            _InfoRow(
              t.couponDiscount(order.couponPercent ?? 0),
              '- ${_formatCents(order.couponDiscountCents)}',
            ),
          _InfoRow(t.checkoutTotal, _formatCents(order.totalCents),
              bold: true),
          if (order.refundTotalCents > 0)
            _InfoRow(t.ordersRefunded, _formatCents(order.refundTotalCents)),

          // Invoice
          if (order.invoiceToken != null && order.status == 'paid') ...[
            const SizedBox(height: 16),
            _InvoiceButton(order: order),
          ],

          // Shipping info block
          if (['paid', 'preparing', 'shipped', 'delivered'].contains(order.status)) ...[
            const Divider(height: 32),
            _ShipmentInfoBlock(orderId: order.id),
          ],

          // Cancel request button
          if (['paid', 'preparing'].contains(order.status) &&
              order.cancelRequestedAt == null) ...[
            const SizedBox(height: 8),
            _CancelRequestButton(order: order),
          ],
          if (order.cancelRequestedAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(t.ordersCancelRequested,
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
                ],
              ),
            ),
          ],

          const Divider(height: 32),

          // Items
          Text(t.ordersItems,
              style: theme.textTheme.titleSmall?.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 12),
          itemsAv.when<Widget>(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${t.ordersLoadItemsError}: $e'),
            data: (Either<Failure, List<OrderItemEntity>> either) =>
                either.fold(
              (Failure failure) => Text(failure.message),
              (List<OrderItemEntity> items) => _ItemsList(items: items),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCents(int cents) =>
      '${(cents / 100).toStringAsFixed(2)} \u20ac';

  String _formatDateTime(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _statusLabel(S t, String status) => switch (status) {
        'paid' => t.checkoutPaid,
        'pending' => t.checkoutPending,
        'cancelled' => t.ordersStatusCancelled,
        'refunded' => t.ordersStatusRefunded,
        'shipped' => t.ordersStatusShipped,
        'delivered' => t.ordersStatusDelivered,
        'preparing' => t.ordersStatusPreparing,
        'test' => t.checkoutTest,
        _ => status,
      };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade600)),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

class _InvoiceButton extends StatefulWidget {
  final OrderEntity order;

  const _InvoiceButton({required this.order});

  @override
  State<_InvoiceButton> createState() => _InvoiceButtonState();
}

class _InvoiceButtonState extends State<_InvoiceButton> {
  bool _loading = false;

  Future<void> _download() async {
    if (_loading) return;
    final t = S.of(context)!;

    setState(() => _loading = true);
    try {
      await PdfService.downloadAndOpenInvoice(
        orderId: widget.order.id,
        invoiceToken: widget.order.invoiceToken!,
      );
    } on PdfDownloadException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'no_session' => t.ordersInvoiceLoginRequired,
        'session_expired' => t.ordersInvoiceSessionExpired,
        'not_found' => t.ordersInvoiceNotFound,
        _ => t.ordersInvoiceError,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (kDebugMode) debugPrint('[InvoiceButton] error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.ordersInvoiceError)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _download,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download, size: 18),
        label: Text(t.ordersDownloadInvoice),
      ),
    );
  }
}

// ── Shipment info block ───────────────────────────────────────────────────
class _ShipmentInfoBlock extends StatefulWidget {
  final String orderId;
  const _ShipmentInfoBlock({required this.orderId});
  @override
  State<_ShipmentInfoBlock> createState() => _ShipmentInfoBlockState();
}

class _ShipmentInfoBlockState extends State<_ShipmentInfoBlock> {
  Map<String, dynamic>? _shipment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await Supabase.instance.client
          .from('fs_shipments')
          .select('status, carrier, tracking_number, shipped_at, delivered_at')
          .eq('order_id', widget.orderId)
          .maybeSingle();
      if (mounted) setState(() { _shipment = resp; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _shipStatusLabel(S t, String? s) => switch (s) {
        'preparing' => t.ordersShipmentPreparing,
        'shipped'   => t.ordersShipmentShipped,
        'delivered' => t.ordersShipmentDelivered,
        'cancelled' => t.ordersShipmentCancelled,
        _           => t.ordersShipmentPending,
      };

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    if (_loading) return const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (_shipment == null) return const SizedBox.shrink();
    final status = _shipment!['status'] as String?;
    final carrier = _shipment!['carrier'] as String?;
    final tracking = _shipment!['tracking_number'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.ordersShippingStatus,
            style: theme.textTheme.titleSmall?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _InfoRow(t.ordersStatus, _shipStatusLabel(t, status)),
        if (carrier != null && carrier.isNotEmpty)
          _InfoRow(t.ordersCarrier, carrier),
        if (tracking != null && tracking.isNotEmpty)
          _InfoRow(t.ordersTracking, tracking),
      ],
    );
  }
}

// ── Cancel request button ─────────────────────────────────────────────────
class _CancelRequestButton extends StatefulWidget {
  final OrderEntity order;
  const _CancelRequestButton({required this.order});
  @override
  State<_CancelRequestButton> createState() => _CancelRequestButtonState();
}

class _CancelRequestButtonState extends State<_CancelRequestButton> {
  bool _loading = false;
  bool _sent = false;

  Future<void> _requestCancel() async {
    final t = S.of(context)!;
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.ordersCancelRequestTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(hintText: t.ordersCancelRequestReason),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.ordersCancelRequestSend)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      final resp = await Supabase.instance.client.functions.invoke(
        'request-cancel',
        body: {'order_id': widget.order.id, 'reason': reasonCtrl.text.trim()},
      );
      final data = resp.data as Map<String, dynamic>;
      if (!mounted) return;
      if (data['ok'] == true) {
        setState(() => _sent = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.ordersCancelRequestSent)));
      } else {
        final msg = data['error'] as String? ?? t.ordersCancelRequestError;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context)!.ordersCancelRequestError)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return const SizedBox.shrink();
    final t = S.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _requestCancel,
        icon: _loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.cancel_outlined, size: 18),
        label: Text(t.ordersCancelRequest),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<OrderItemEntity> items;

  const _ItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          if (item.size != null)
                            Text('${t.ordersSize}: ${item.size}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600)),
                          Text('x${item.qty}',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(item.lineTotalCents / 100).toStringAsFixed(2)} \u20ac',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (item.paidLineTotalCents != null &&
                            item.paidLineTotalCents != item.lineTotalCents)
                          Text(
                            '${(item.paidLineTotalCents! / 100).toStringAsFixed(2)} \u20ac ${t.ordersPaidLabel}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
