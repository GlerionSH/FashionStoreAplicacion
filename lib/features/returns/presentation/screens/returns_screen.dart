import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/return_entity.dart';
import '../providers/returns_providers.dart';

class ReturnsScreen extends ConsumerWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAv = ref.watch(myReturnsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis devoluciones')),
      body: returnsAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (either) => either.fold(
          (failure) => Center(child: Text(failure.message)),
          (returns) => returns.isEmpty
              ? Center(
                  child: Text(
                    'No tienes devoluciones',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: returns.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) =>
                      _ReturnTile(ret: returns[index]),
                ),
        ),
      ),
    );
  }
}

class _ReturnTile extends StatelessWidget {
  final ReturnEntity ret;

  const _ReturnTile({required this.ret});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final refund = (ret.refundTotalCents / 100).toStringAsFixed(2);
    final date = _formatDate(ret.requestedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedido ${ret.orderId.substring(0, 8)}...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _StatusChip(status: ret.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(date,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600)),
              const Spacer(),
              Text('$refund \u20ac',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          if (ret.reason != null && ret.reason!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ret.reason!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (ret.items.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${ret.items.length} artículo(s)',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style:
            TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w500),
      ),
    );
  }

  String get _label => switch (status) {
        'requested' => 'Solicitada',
        'approved' => 'Aprobada',
        'rejected' => 'Rechazada',
        'refunded' => 'Reembolsada',
        'cancelled' => 'Cancelada',
        _ => status,
      };

  Color get _color => switch (status) {
        'requested' => Colors.orange.shade700,
        'approved' => Colors.blue.shade700,
        'rejected' => Colors.red.shade700,
        'refunded' => Colors.green.shade700,
        'cancelled' => Colors.grey.shade600,
        _ => Colors.grey.shade600,
      };
}
