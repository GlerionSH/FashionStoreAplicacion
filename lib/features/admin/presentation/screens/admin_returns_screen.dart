import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../returns/presentation/providers/admin_returns_providers.dart';

class AdminReturnsScreen extends ConsumerWidget {
  const AdminReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAv = ref.watch(adminReturnsListProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminReturnsTitle),
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
        ),
      body: RefreshIndicator(
        color: const Color(0xFF000000),
        onRefresh: () async => ref.invalidate(adminReturnsListProvider),
        child: returnsAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: theme.textTheme.bodySmall),
          ),
          data: (returns) {
            if (returns.isEmpty) {
              return Center(
                child: Text(t.adminReturnsEmpty,
                    style: theme.textTheme.bodySmall),
              );
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: returns.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) =>
                  _ReturnTile(returnData: returns[i]),
            );
          },
        ),
      ),
      ),
    );
  }
}

class _ReturnTile extends ConsumerWidget {
  final Map<String, dynamic> returnData;
  const _ReturnTile({required this.returnData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = (returnData['id'] ?? '').toString();
    final orderId = returnData['order_id'] as String? ?? '-';
    final reason = returnData['reason'] as String? ?? '-';
    final status = returnData['status'] as String? ?? '-';
    final requestedAt = returnData['requested_at'] as String? ?? '';
    final dateStr =
        requestedAt.length >= 10 ? requestedAt.substring(0, 10) : '';
    final isRequested = status == 'requested';
    final requestType = returnData['request_type'] as String? ?? 'cancellation';
    final order = returnData['order'] as Map<String, dynamic>?;
    final email = order?['email'] as String? ?? '';

    return InkWell(
      onTap: () => context.go('/admin-panel/devoluciones/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${S.of(context)!.adminReturnOrder}: #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: requestType == 'return'
                                ? const Color(0xFFE3F2FD)
                                : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            requestType == 'return' ? 'DEV' : 'CANCEL',
                            style: TextStyle(
                              fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.5,
                              color: requestType == 'return'
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFF57F17),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    ],
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: isRequested
                    ? const Color(0xFFFFF3E0)
                    : status == 'refunded'
                        ? const Color(0xFFE8F5E9)
                        : status == 'rejected'
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFF5F5F5),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: isRequested
                        ? const Color(0xFFE65100)
                        : status == 'refunded'
                            ? const Color(0xFF2E7D32)
                            : status == 'rejected'
                                ? const Color(0xFFC62828)
                                : const Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty && reason != '-') ...[
            const SizedBox(height: 6),
            Text('${S.of(context)!.adminReturnReason}: $reason',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF616161)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade600),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
