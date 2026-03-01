import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';

class AdminCancellationsScreen extends StatefulWidget {
  const AdminCancellationsScreen({super.key});

  @override
  State<AdminCancellationsScreen> createState() => _AdminCancellationsScreenState();
}

class _AdminCancellationsScreenState extends State<AdminCancellationsScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-cancellations',
        method: HttpMethod.get,
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _requests = (data['requests'] as List? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _handleAction(Map<String, dynamic> req, String action) async {
    final t = S.of(context)!;
    final notesCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'approve' ? t.adminCancellationApprove : t.adminCancellationReject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: #${(req['order_id'] as String).substring(0, 8)}'),
            if (req['reason'] != null && (req['reason'] as String).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${t.adminCancellationReason}: ${req['reason']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(labelText: t.adminCancellationAdminNotes),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: action == 'approve'
                ? FilledButton.styleFrom(backgroundColor: Colors.green)
                : FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(action == 'approve' ? t.adminCancellationApprove : t.adminCancellationReject),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-cancellations',
        method: HttpMethod.patch,
        body: {
          'id': req['id'],
          'action': action,
          'admin_notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        },
      );
      final data = resp.data as Map<String, dynamic>;
      if (!mounted) return;
      if (data['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t.adminCancellationError}: ${data['error']}')));
      } else {
        final msg = action == 'approve' ? t.adminCancellationApproved : t.adminCancellationRejected;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _statusColor(String status) => switch (status) {
        'approved' => Colors.green.shade100,
        'rejected' => Colors.red.shade100,
        _          => Colors.orange.shade100,
      };

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminCancellationsTitle),
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
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
        ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!), const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: Text(t.adminRetry)),
                ]))
              : _requests.isEmpty
                  ? Center(child: Text(t.adminCancellationNoData))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      separatorBuilder: (_, i) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final req = _requests[i];
                        final status = req['status'] as String;
                        final orderId = req['order_id'] as String;
                        final email = req['email'] as String? ?? '';
                        final reason = req['reason'] as String? ?? '';
                        final isPending = status == 'requested';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      color: _statusColor(status),
                                      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(req['requested_at'] as String?),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Order: #${orderId.substring(0, 8)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                if (email.isNotEmpty)
                                  Text(email, style: theme.textTheme.bodySmall),
                                if (reason.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('${t.adminCancellationReason}: $reason',
                                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                ],
                                if (req['admin_notes'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Admin: ${req['admin_notes']}',
                                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _handleAction(req, 'reject'),
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                          child: Text(t.adminCancellationReject, style: const TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () => _handleAction(req, 'approve'),
                                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                          child: Text(t.adminCancellationApprove, style: const TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
