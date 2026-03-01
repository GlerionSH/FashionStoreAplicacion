import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  List<Map<String, dynamic>> _coupons = [];
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
        'admin-coupons',
        method: HttpMethod.get,
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _coupons = (data['coupons'] as List? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> coupon) async {
    final t = S.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final msg = coupon['active'] == true ? t.adminCouponDeactivated : t.adminCouponActivated;
    try {
      await SupabaseService.client.functions.invoke(
        'admin-coupons',
        method: HttpMethod.patch,
        body: {'id': coupon['id'], 'active': !(coupon['active'] as bool)},
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      _load();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteCoupon(String id) async {
    final t = S.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final deletedMsg = t.adminProductDeleted;
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-coupons',
        method: HttpMethod.delete,
        body: {'id': id},
      );
      if (!mounted) return;
      final data = resp.data as Map<String, dynamic>;
      if (data['error'] != null) {
        messenger.showSnackBar(SnackBar(content: Text(data['error'] as String)));
      } else {
        messenger.showSnackBar(SnackBar(content: Text(deletedMsg)));
        _load();
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showCreateDialog() async {
    final t = S.of(context)!;
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final maxPerUserCtrl = TextEditingController();
    final minOrderCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.adminCouponNew),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeCtrl, decoration: InputDecoration(labelText: t.adminCouponCode), textCapitalization: TextCapitalization.characters),
              TextField(controller: percentCtrl, decoration: InputDecoration(labelText: t.adminCouponPercent), keyboardType: TextInputType.number),
              TextField(controller: maxCtrl, decoration: InputDecoration(labelText: t.adminCouponMaxRedemptions), keyboardType: TextInputType.number),
              TextField(controller: maxPerUserCtrl, decoration: InputDecoration(labelText: t.adminCouponMaxPerUser), keyboardType: TextInputType.number),
              TextField(controller: minOrderCtrl, decoration: InputDecoration(labelText: t.adminCouponMinOrder), keyboardType: TextInputType.number),
              TextField(controller: notesCtrl, decoration: InputDecoration(labelText: t.adminCouponNotes)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.adminCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.adminCouponCreate)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final body = {
        'code': codeCtrl.text.trim().toUpperCase(),
        'percent_off': int.tryParse(percentCtrl.text) ?? 10,
        if (maxCtrl.text.isNotEmpty) 'max_redemptions': int.tryParse(maxCtrl.text),
        if (maxPerUserCtrl.text.isNotEmpty) 'max_redemptions_per_user': int.tryParse(maxPerUserCtrl.text),
        if (minOrderCtrl.text.isNotEmpty) 'min_order_cents': int.tryParse(minOrderCtrl.text),
        if (notesCtrl.text.isNotEmpty) 'notes': notesCtrl.text.trim(),
      };
      await SupabaseService.client.functions.invoke('admin-coupons', body: body);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminCouponCreated)));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminCouponsTitle),
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
            IconButton(icon: const Icon(Icons.add), onPressed: _showCreateDialog),
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
                : _coupons.isEmpty
                    ? Center(child: Text(t.adminCouponNoData))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _coupons.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = _coupons[i];
                          final isActive = c['active'] == true;
                          final redemptionsData = c['redemptions_count'];
                          int redemptionsCount = 0;
                          if (redemptionsData is List && redemptionsData.isNotEmpty) {
                            final first = redemptionsData.first;
                            if (first is Map) redemptionsCount = (first['count'] as num?)?.toInt() ?? 0;
                          }
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Text(c['code'] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                      decoration: isActive ? null : TextDecoration.lineThrough,
                                    )),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                  child: Text(
                                    '${c['percent_off']}%',
                                    style: TextStyle(fontSize: 11, color: isActive ? Colors.green.shade800 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${t.adminCouponRedemptions}: $redemptionsCount'
                              '${c['max_redemptions'] != null ? ' / ${c['max_redemptions']}' : ''}'
                              '${c['notes'] != null ? ' · ${c['notes']}' : ''}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(value: isActive, onChanged: (_) => _toggleActive(c)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () => _deleteCoupon(c['id'] as String),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
