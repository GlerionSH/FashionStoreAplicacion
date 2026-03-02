import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../dashboard/data/datasources/admin_dashboard_datasource.dart';
import '../providers/admin_providers.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAv = ref.watch(adminDashboardStatsProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => context.go('/admin-panel/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF000000),
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
        },
        child: statsAv.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Icon(Icons.error_outline,
                  size: 40, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text('Error: $e',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(adminDashboardStatsProvider),
                  child: Text(t.adminRetry),
                ),
              ),
            ],
          ),
          data: (stats) => _DashboardBody(stats: stats),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardStats stats;
  const _DashboardBody({required this.stats});

  String _formatEur(int cents) =>
      '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} \u20ac';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // ── Metrics grid ──
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _MetricCard(
              label: S.of(context)!.adminMetricOrders,
              value: '${stats.totalOrders}',
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              label: S.of(context)!.adminMetricRevenue,
              value: _formatEur(stats.netRevenueCents),
              icon: Icons.euro_outlined,
            ),
            _MetricCard(
              label: S.of(context)!.adminMetricReturns,
              value: '${stats.pendingReturns}',
              icon: Icons.assignment_return_outlined,
            ),
            _MetricCard(
              label: S.of(context)!.adminMetricProducts,
              value: '${stats.activeProducts}',
              icon: Icons.inventory_2_outlined,
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Quick nav ──
        Text(S.of(context)!.adminActions,
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111111),
            )),
        const SizedBox(height: 12),
        _NavTile(
          icon: Icons.inventory_2_outlined,
          label: S.of(context)!.adminNavProducts,
          onTap: () => context.go('/admin-panel/productos'),
        ),
        _NavTile(
          icon: Icons.receipt_long_outlined,
          label: S.of(context)!.adminNavOrders,
          onTap: () => context.go('/admin-panel/pedidos'),
        ),
        _NavTile(
          icon: Icons.assignment_return_outlined,
          label: S.of(context)!.adminNavReturns,
          onTap: () => context.go('/admin-panel/devoluciones'),
        ),
        _NavTile(
          icon: Icons.flash_on_outlined,
          label: S.of(context)!.adminNavFlash,
          onTap: () => context.go('/admin-panel/flash'),
        ),
        _NavTile(
          icon: Icons.settings_outlined,
          label: S.of(context)!.adminNavSettings,
          onTap: () => context.go('/admin-panel/settings'),
        ),
        _NavTile(
          icon: Icons.discount_outlined,
          label: S.of(context)!.adminNavCoupons,
          onTap: () => context.go('/admin-panel/cupones'),
        ),
        _NavTile(
          icon: Icons.local_shipping_outlined,
          label: S.of(context)!.adminNavShipments,
          onTap: () => context.go('/admin-panel/envios'),
        ),
        _NavTile(
          icon: Icons.cancel_outlined,
          label: S.of(context)!.adminNavCancellations,
          onTap: () => context.go('/admin-panel/cancelaciones'),
        ),
        _NavTile(
          icon: Icons.people_outline,
          label: S.of(context)!.adminNavUsers,
          onTap: () => context.go('/admin-panel/usuarios'),
        ),
        _NavTile(
          icon: Icons.headset_mic_outlined,
          label: 'Soporte',
          onTap: () => context.go('/admin-panel/soporte'),
        ),
        const SizedBox(height: 28),

        // ── Recent orders ──
        Text(S.of(context)!.adminRecentOrders,
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111111),
            )),
        const SizedBox(height: 8),
        if (stats.recentOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(S.of(context)!.adminNoOrdersYet,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
          )
        else
          ...stats.recentOrders.map((o) => _RecentOrderTile(order: o)),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9E9E9E)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111111),
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
                color: Color(0xFF9E9E9E),
              )),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF111111)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  )),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final id = (order['id'] ?? '').toString();
    final email = order['email'] as String? ?? '-';
    final status = order['status'] as String? ?? '-';
    final totalCents = (order['total_cents'] as num?)?.toInt() ?? 0;
    final total =
        '${(totalCents / 100).toStringAsFixed(2).replaceAll('.', ',')} \u20ac';

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
                  Text('#${id.length > 8 ? id.substring(0, 8) : id}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                _StatusBadge(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'paid'
            ? const Color(0xFF111111)
            : const Color(0xFFF5F5F5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: status == 'paid' ? Colors.white : const Color(0xFF616161),
        ),
      ),
    );
  }
}
