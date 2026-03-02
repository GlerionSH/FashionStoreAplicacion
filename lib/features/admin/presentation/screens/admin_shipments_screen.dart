import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';

class AdminShipmentsScreen extends StatefulWidget {
  const AdminShipmentsScreen({super.key});

  @override
  State<AdminShipmentsScreen> createState() => _AdminShipmentsScreenState();
}

class _AdminShipmentsScreenState extends State<AdminShipmentsScreen> {
  List<Map<String, dynamic>> _shipments = [];
  bool _loading = true;
  String? _error;

  static const _statuses = ['pending', 'preparing', 'shipped', 'delivered', 'cancelled'];

  String _statusLabel(S t, String status) => switch (status) {
    'pending' => t.shipmentStatusPending,
    'preparing' => t.shipmentStatusPreparing,
    'shipped' => t.shipmentStatusShipped,
    'delivered' => t.shipmentStatusDelivered,
    'cancelled' => t.shipmentStatusCancelled,
    _ => status,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-shipments',
        method: HttpMethod.get,
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _shipments = (data['shipments'] as List? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _editShipment(Map<String, dynamic> shipment) async {
    final t = S.of(context)!;
    final carrierCtrl = TextEditingController(text: shipment['carrier'] as String? ?? '');
    final trackingCtrl = TextEditingController(text: shipment['tracking_number'] as String? ?? '');
    final notesCtrl = TextEditingController(text: shipment['notes'] as String? ?? '');
    String selectedStatus = shipment['status'] as String? ?? 'pending';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('${t.adminShipmentOrder}: ${(shipment['order_id'] as String).substring(0, 8)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(t, s)))).toList(),
                  onChanged: (v) => setDlgState(() => selectedStatus = v ?? selectedStatus),
                  decoration: InputDecoration(labelText: t.adminShipmentStatus),
                ),
                const SizedBox(height: 8),
                TextField(controller: carrierCtrl, decoration: InputDecoration(labelText: t.adminShipmentCarrier)),
                TextField(controller: trackingCtrl, decoration: InputDecoration(labelText: t.adminShipmentTracking)),
                TextField(controller: notesCtrl, decoration: InputDecoration(labelText: t.adminShipmentNotes)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.adminShipmentSave)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    try {
      await SupabaseService.client.functions.invoke(
        'admin-shipments',
        method: HttpMethod.patch,
        body: {
          'id': shipment['id'],
          'order_id': shipment['order_id'],
          'status': selectedStatus,
          'carrier': carrierCtrl.text.trim(),
          'tracking_number': trackingCtrl.text.trim(),
          'notes': notesCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminShipmentSaved)));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _createShipment() async {
    final t = S.of(context)!;
    final orderIdCtrl = TextEditingController();
    final carrierCtrl = TextEditingController();
    final trackingCtrl = TextEditingController();
    String selectedStatus = 'pending';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(t.adminShipmentCreate),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: orderIdCtrl, decoration: const InputDecoration(labelText: 'Order ID')),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(t, s)))).toList(),
                  onChanged: (v) => setDlgState(() => selectedStatus = v ?? selectedStatus),
                  decoration: InputDecoration(labelText: t.adminShipmentStatus),
                ),
                TextField(controller: carrierCtrl, decoration: InputDecoration(labelText: t.adminShipmentCarrier)),
                TextField(controller: trackingCtrl, decoration: InputDecoration(labelText: t.adminShipmentTracking)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.adminShipmentCreate)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    try {
      await SupabaseService.client.functions.invoke(
        'admin-shipments',
        body: {
          'order_id': orderIdCtrl.text.trim(),
          'status': selectedStatus,
          'carrier': carrierCtrl.text.trim(),
          'tracking_number': trackingCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminShipmentCreated)));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _statusColor(String? status) => switch (status) {
        'shipped'   => Colors.blue.shade100,
        'delivered' => Colors.green.shade100,
        'cancelled' => Colors.red.shade100,
        'preparing' => Colors.orange.shade100,
        _           => Colors.grey.shade100,
      };

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminShipmentsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin-panel');
              }
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _createShipment),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!), const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: Text(t.adminRetry)),
                  ]))
                : _shipments.isEmpty
                    ? Center(child: Text(t.adminShipmentNoData))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _shipments.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _shipments[i];
                          final orderId = s['order_id'] as String;
                          final status = s['status'] as String? ?? 'pending';
                          final order = s['order'] as Map<String, dynamic>?;
                          final email = order?['email'] as String? ?? '';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: _statusColor(status),
                              child: Text(_statusLabel(t, status), style: const TextStyle(fontSize: 11)),
                            ),
                            title: Text('#${orderId.substring(0, 8)}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (email.isNotEmpty) Text(email, style: theme.textTheme.bodySmall),
                                if (s['carrier'] != null) Text('${s['carrier']}  ${s['tracking_number'] ?? ''}',
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _editShipment(s),
                            ),
                            onTap: () => _editShipment(s),
                          );
                        },
                      ),
      ),
    );
  }
}
