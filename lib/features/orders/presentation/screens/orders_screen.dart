import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/files/pdf_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAv = ref.watch(ordersProvider);
    final theme = Theme.of(context);
    final t = S.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.ordersTitle)),
      body: ordersAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e', style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: Text(t.ordersRetry),
              ),
            ],
          ),
        ),
        data: (either) => either.fold(
          (failure) => Center(child: Text(failure.message)),
          (orders) => orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.ordersEmpty,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go('/productos'),
                        child: Text(t.ordersViewProducts),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersProvider),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, index) =>
                        _OrderTile(order: orders[index]),
                  ),
                ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatefulWidget {
  final OrderEntity order;

  const _OrderTile({required this.order});

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  bool _invoiceLoading = false;

  Future<void> _openInvoice() async {
    if (_invoiceLoading) return;
    final t = S.of(context)!;

    setState(() => _invoiceLoading = true);
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
      if (kDebugMode) debugPrint('[OrderTile] Invoice error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.ordersInvoiceError)));
    } finally {
      if (mounted) setState(() => _invoiceLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final price = (widget.order.totalCents / 100).toStringAsFixed(2);
    final date = _formatDate(widget.order.createdAt);
    final canInvoice =
        widget.order.status == 'paid' && widget.order.invoiceToken != null;

    return InkWell(
      onTap: () => context.push('/cuenta/pedidos/${widget.order.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.order.id.substring(0, 8)}...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(date,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$price \u20ac',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    _StatusChip(status: widget.order.status),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20),
              ],
            ),
            // Email status + invoice row
            if (widget.order.emailSentAt != null ||
                widget.order.emailLastError != null ||
                canInvoice)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (widget.order.emailSentAt != null)
                      _MiniLabel(
                        icon: Icons.mark_email_read_outlined,
                        text: t.ordersEmailSent,
                        color: Colors.green.shade700,
                      )
                    else if (widget.order.emailLastError != null)
                      Flexible(
                        child: _MiniLabel(
                          icon: Icons.error_outline,
                          text:
                              '${t.ordersEmailError}: ${widget.order.emailLastError!.length > 30 ? '${widget.order.emailLastError!.substring(0, 30)}...' : widget.order.emailLastError!}',
                          color: Colors.red.shade600,
                        ),
                      ),
                    const Spacer(),
                    if (canInvoice)
                      GestureDetector(
                        onTap: _openInvoice,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _invoiceLoading
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : Icon(Icons.picture_as_pdf_outlined,
                                    size: 14,
                                    color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              t.ordersViewInvoice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _MiniLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniLabel({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: color),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label(t),
        style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _label(S t) => switch (status) {
        'paid' => t.checkoutPaid,
        'pending' => t.checkoutPending,
        'cancelled' => t.checkoutCancelled,
        'refunded' => t.checkoutRefunded,
        'shipped' => t.checkoutShipped,
        'test' => t.checkoutTest,
        _ => status,
      };

  Color get _color => switch (status) {
        'paid' => Colors.green.shade700,
        'pending' => Colors.orange.shade700,
        'cancelled' => Colors.red.shade700,
        'refunded' => Colors.blue.shade700,
        'shipped' => Colors.teal.shade700,
        _ => Colors.grey.shade600,
      };
}
