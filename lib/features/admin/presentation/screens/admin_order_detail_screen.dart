import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../orders/presentation/providers/admin_orders_providers.dart';

class AdminOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAv = ref.watch(adminOrderDetailProvider(orderId));
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminOrderDetailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel/pedidos'),
        ),
      ),
      body: orderAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: theme.textTheme.bodySmall),
        ),
        data: (order) => _OrderDetailBody(
          order: order,
          orderId: orderId,
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const _OrderDetailBody({required this.order, required this.orderId});

  String _eur(int cents) =>
      '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} \u20ac';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context)!;
    final status = order['status'] as String? ?? '-';
    final email = order['email'] as String? ?? '-';
    final subtotalCents = (order['subtotal_cents'] as num?)?.toInt() ?? 0;
    final discountCents = (order['discount_cents'] as num?)?.toInt() ?? 0;
    final totalCents = (order['total_cents'] as num?)?.toInt() ?? 0;
    final invoiceToken = order['invoice_token'] as String?;
    final paidAt = order['paid_at'] as String? ?? '';
    final items = order['items'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // ── Order info ──
        _InfoRow('ID', orderId.length > 12 ? orderId.substring(0, 12) : orderId),
        _InfoRow(t.adminFieldEmail, email),
        _InfoRow(t.adminOrderStatusLabel, status.toUpperCase()),
        if (paidAt.isNotEmpty) _InfoRow(t.adminOrderPaidLabel, paidAt.substring(0, 10)),
        const Divider(height: 28),

        // ── Totals ──
        _InfoRow(t.ordersSubtotal, _eur(subtotalCents)),
        if (discountCents > 0) _InfoRow(t.ordersDiscount, '-${_eur(discountCents)}'),
        if ((order['coupon_discount_cents'] as num?)?.toInt() != null &&
            ((order['coupon_discount_cents'] as num?)?.toInt() ?? 0) > 0)
          _InfoRow(
            '${t.ordersCouponDiscount} (${order['coupon_code'] ?? ''})',
            '-${_eur((order['coupon_discount_cents'] as num).toInt())}',
          ),
        _InfoRow(t.checkoutTotal, _eur(totalCents)),
        const Divider(height: 28),

        // ── Status change ──
        Text(t.adminChangeStatus,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.0,
                color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: ['pending', 'paid', 'preparing', 'shipped', 'delivered', 'cancelled', 'refunded']
              .map((s) => OutlinedButton(
                    onPressed: s == status
                        ? null
                        : () async {
                            await ref
                                .read(adminOrdersDatasourceProvider)
                                .updateOrderStatus(orderId, status: s);
                            ref.invalidate(adminOrderDetailProvider(orderId));
                            ref.invalidate(adminOrdersListProvider);
                          },
                    style: s == status
                        ? OutlinedButton.styleFrom(backgroundColor: const Color(0xFF111111), foregroundColor: Colors.white)
                        : null,
                    child: Text(s.toUpperCase(),
                        style: const TextStyle(fontSize: 10)),
                  ))
              .toList(),
        ),
        const Divider(height: 28),

        // ── Shipment form ──
        _ShipmentFormSection(orderId: orderId),
        const Divider(height: 28),

        // ── Cancellation request (if any) ──
        _CancellationSection(orderId: orderId),

        // ── Invoice ──
        if (invoiceToken != null && invoiceToken.isNotEmpty) ...[
          OutlinedButton.icon(
            icon: const Icon(Icons.receipt_outlined, size: 18),
            label: Text(t.adminViewInvoice),
            onPressed: () async {
              final baseUrl = (dotenv.env['SUPABASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');
              final url =
                  '$baseUrl/functions/v1/invoice_pdf?order_id=${Uri.encodeComponent(orderId)}&token=${Uri.encodeComponent(invoiceToken)}';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const Divider(height: 28),
        ],

        // ── Items ──
        Text(t.adminOrderItems,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.0,
                color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(t.adminNoItemsLoaded,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))
        else
          ...items.map((item) {
            final m = item as Map<String, dynamic>;
            final name = m['name'] as String? ?? '-';
            final qty = (m['qty'] as num?)?.toInt() ?? 1;
            final size = m['size'] as String?;
            final lineCents = (m['line_total_cents'] as num?)?.toInt() ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${name.toUpperCase()}${size != null ? ' ($size)' : ''} x$qty',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(_eur(lineCents),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Shipment form ─────────────────────────────────────────────────────────
class _ShipmentFormSection extends StatefulWidget {
  final String orderId;
  const _ShipmentFormSection({required this.orderId});
  @override
  State<_ShipmentFormSection> createState() => _ShipmentFormSectionState();
}

class _ShipmentFormSectionState extends State<_ShipmentFormSection> {
  Map<String, dynamic>? _shipment;
  bool _loading = true;
  bool _saving = false;
  late final TextEditingController _carrierCtrl;
  late final TextEditingController _trackingCtrl;
  late final TextEditingController _notesCtrl;
  String _selectedStatus = 'pending';

  static const _statuses = ['pending', 'preparing', 'shipped', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _carrierCtrl = TextEditingController();
    _trackingCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _carrierCtrl.dispose();
    _trackingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final resp = await Supabase.instance.client
          .from('fs_shipments')
          .select('*')
          .eq('order_id', widget.orderId)
          .maybeSingle();
      if (mounted) {
        _shipment = resp;
        if (resp != null) {
          _selectedStatus = resp['status'] as String? ?? 'pending';
          _carrierCtrl.text = resp['carrier'] as String? ?? '';
          _trackingCtrl.text = resp['tracking_number'] as String? ?? '';
          _notesCtrl.text = resp['notes'] as String? ?? '';
        }
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final t = S.of(context)!;
    setState(() => _saving = true);
    try {
      if (_shipment == null) {
        await SupabaseService.client.functions.invoke(
          'admin-shipments',
          body: {
            'order_id': widget.orderId,
            'status': _selectedStatus,
            'carrier': _carrierCtrl.text.trim(),
            'tracking_number': _trackingCtrl.text.trim(),
            'notes': _notesCtrl.text.trim(),
          },
        );
      } else {
        await SupabaseService.client.functions.invoke(
          'admin-shipments',
          method: HttpMethod.patch,
          body: {
            'id': _shipment!['id'],
            'order_id': widget.orderId,
            'status': _selectedStatus,
            'carrier': _carrierCtrl.text.trim(),
            'tracking_number': _trackingCtrl.text.trim(),
            'notes': _notesCtrl.text.trim(),
          },
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminShipmentSaved)));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    if (_loading) return const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.adminShipmentsTitle,
            style: const TextStyle(fontSize: 11, letterSpacing: 1.0, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _selectedStatus = v ?? _selectedStatus),
          decoration: InputDecoration(labelText: t.adminShipmentStatus, isDense: true),
        ),
        const SizedBox(height: 8),
        TextField(controller: _carrierCtrl, decoration: InputDecoration(labelText: t.adminShipmentCarrier, isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(controller: _trackingCtrl, decoration: InputDecoration(labelText: t.adminShipmentTracking, isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: t.adminShipmentNotes, isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_shipment == null ? t.adminShipmentCreate : t.adminShipmentSave, style: const TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

// ── Cancellation section ───────────────────────────────────────────────────
class _CancellationSection extends StatefulWidget {
  final String orderId;
  const _CancellationSection({required this.orderId});
  @override
  State<_CancellationSection> createState() => _CancellationSectionState();
}

class _CancellationSectionState extends State<_CancellationSection> {
  Map<String, dynamic>? _request;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await Supabase.instance.client
          .from('fs_cancellation_requests')
          .select('*')
          .eq('order_id', widget.orderId)
          .maybeSingle();
      if (mounted) setState(() { _request = resp; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _request == null) return const SizedBox.shrink();
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final status = _request!['status'] as String;
    final reason = _request!['reason'] as String? ?? '';
    final email = _request!['email'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.adminCancellationsTitle,
            style: const TextStyle(fontSize: 11, letterSpacing: 1.0, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          color: status == 'requested' ? Colors.orange.shade50 : Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${status.toUpperCase()}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              if (email.isNotEmpty) Text(email, style: theme.textTheme.bodySmall),
              if (reason.isNotEmpty) Text('Reason: $reason', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 0.5)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
