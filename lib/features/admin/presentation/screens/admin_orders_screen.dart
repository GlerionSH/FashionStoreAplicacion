import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../orders/presentation/providers/admin_orders_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAv = ref.watch(adminOrdersListProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminOrdersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel'),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF000000),
        onRefresh: () async => ref.invalidate(adminOrdersListProvider),
        child: ordersAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: theme.textTheme.bodySmall),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return Center(
                child: Text(t.adminNoOrders,
                    style: theme.textTheme.bodySmall),
              );
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) => _OrderTile(order: orders[i]),
            );
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final id = (order['id'] ?? '').toString();
    final email = order['email'] as String? ?? '-';
    final status = order['status'] as String? ?? '-';
    final totalCents = (order['total_cents'] as num?)?.toInt() ?? 0;
    final total =
        '${(totalCents / 100).toStringAsFixed(2).replaceAll('.', ',')} \u20ac';
    final createdAt = order['created_at'] as String? ?? '';
    final dateStr = createdAt.length >= 10 ? createdAt.substring(0, 10) : '';

    return InkWell(
      onTap: () => context.go('/admin-panel/pedidos/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '#${id.length > 8 ? id.substring(0, 8) : id}  $dateStr',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                _StatusChip(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: isPaid ? Colors.white : const Color(0xFF616161),
        ),
      ),
    );
  }
}
