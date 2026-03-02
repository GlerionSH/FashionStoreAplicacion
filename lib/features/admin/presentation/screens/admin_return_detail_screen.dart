import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';

class AdminReturnDetailScreen extends ConsumerStatefulWidget {
  final String returnId;

  const AdminReturnDetailScreen({
    super.key,
    required this.returnId,
  });

  @override
  ConsumerState<AdminReturnDetailScreen> createState() => _AdminReturnDetailScreenState();
}

class _AdminReturnDetailScreenState extends ConsumerState<AdminReturnDetailScreen> {
  Map<String, dynamic>? _returnData;
  bool _loading = true;
  String? _error;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadReturnDetail();
  }

  Future<void> _loadReturnDetail() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-returns',
        method: HttpMethod.get,
        queryParameters: {'return_id': widget.returnId},
      );
      final data = resp.data as Map<String, dynamic>;
      if (data['error'] != null) throw Exception(data['error']);
      setState(() {
        _returnData = data['return'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _performAction(String action) async {
    final t = S.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    
    String? adminNotes;
    if (action == 'reject') {
      final notesCtrl = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.adminReturnReject),
          content: TextField(
            controller: notesCtrl,
            decoration: InputDecoration(labelText: t.adminCancellationAdminNotes),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.adminReturnReject)),
          ],
        ),
      );
      if (confirmed != true) return;
      adminNotes = notesCtrl.text.trim();
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.adminReturnApprove),
          content: const Text('Aprobar y procesar reembolso via Stripe?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CONFIRMAR')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _processing = true);
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-returns',
        method: HttpMethod.patch,
        body: {
          'return_id': widget.returnId,
          'action': action,
          if (adminNotes != null && adminNotes.isNotEmpty) 'admin_notes': adminNotes,
        },
      );
      final data = resp.data as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      if (data['error'] != null) {
        messenger.showSnackBar(SnackBar(content: Text('Error: ${data['error']}')));
      } else {
        final label = action == 'approve' ? 'Aprobado y reembolsado' : 'Rechazado';
        messenger.showSnackBar(SnackBar(content: Text(label)));
      }
      _loadReturnDetail();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _formatCents(int cents) => '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

  Color _statusColor(String status) => switch (status) {
    'approved' || 'refunded' => Colors.green.shade100,
    'rejected' => Colors.red.shade100,
    _ => Colors.orange.shade100,
  };

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('DETALLE DEVOLUCIÓN'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin-panel/devoluciones');
              }
            },
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _loadReturnDetail, child: Text(t.adminRetry)),
                    ],
                  ))
                : _returnData == null
                    ? Center(child: Text(t.adminReturnReason))
                    : _buildBody(t, theme),
      ),
    );
  }

  Widget _buildBody(S t, ThemeData theme) {
    final ret = _returnData!;
    final status = ret['status'] as String? ?? 'pending';
    final orderId = ret['order_id'] as String? ?? '';
    final reason = ret['reason'] as String? ?? '';
    final refundCents = ret['refund_total_cents'] as int? ?? 0;
    final requestedAt = ret['requested_at'] as String?;
    final notes = ret['notes'] as String?;
    final order = ret['order'] as Map<String, dynamic>?;
    final email = order?['email'] as String? ?? '';
    final requestType = ret['request_type'] as String? ?? 'cancellation';
    final shipment = ret['shipment'] as Map<String, dynamic>?;
    final items = ret['items'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 20),

          // Type badge
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: requestType == 'return' ? Colors.blue.shade50 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              requestType == 'return' ? 'DEVOLUCION' : 'CANCELACION',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1,
                color: requestType == 'return' ? Colors.blue.shade700 : Colors.amber.shade800,
              ),
            ),
          ),

          // Order info
          _infoRow('Pedido', orderId.length >= 8 ? orderId.substring(0, 8) : orderId),
          _infoRow('Email', email),
          if (requestedAt != null) _infoRow('Solicitado', DateTime.tryParse(requestedAt)?.toLocal().toString().substring(0, 16) ?? requestedAt),
          if (shipment != null) _infoRow('Envio', (shipment['status'] as String? ?? 'pending').toUpperCase()),
          const Divider(height: 32),

          // Return details
          Text('DETALLES', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _infoRow(t.adminReturnReason, reason.isEmpty ? 'Sin motivo' : reason),
          _infoRow('Monto reembolso', _formatCents(refundCents)),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('Notas', notes),
          ],
          // Items
          if (items.isNotEmpty) ...[
            const Divider(height: 32),
            Text('ARTICULOS', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...items.map((item) {
              final i = item as Map<String, dynamic>;
              final name = i['name'] as String? ?? 'Articulo';
              final size = i['size'] as String?;
              final qty = i['qty'] as int? ?? 1;
              final cents = i['line_total_cents'] as int? ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('$name${size != null ? " ($size)" : ""} x$qty', style: const TextStyle(fontSize: 13))),
                    Text(_formatCents(cents), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 32),

          // Actions
          if (status == 'requested') ...[
            Text('ACCIONES', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            if (_processing)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _performAction('reject'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(t.adminReturnReject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _performAction('approve'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(t.adminReturnApprove),
                    ),
                  ),
                ],
              ),
          ],
          if (status == 'refunded') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Reembolso procesado',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
