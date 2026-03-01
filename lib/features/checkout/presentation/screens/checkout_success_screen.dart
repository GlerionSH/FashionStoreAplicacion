import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/files/pdf_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_providers.dart';

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String? orderId;

  const CheckoutSuccessScreen({super.key, this.sessionId, this.orderId});

  @override
  ConsumerState<CheckoutSuccessScreen> createState() =>
      _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen> {
  bool _isPaid = false;
  String? _statusKey;
  int _tries = 0;
  static const _maxTries = 20;
  Timer? _timer;

  bool _finalized = false;
  bool _timedOut = false;
  int? _totalCents;
  DateTime? _paidAt;
  DateTime? _createdAt;
  String? _invoiceToken;
  bool _invoiceLoading = false;

  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    debugPrint('[CheckoutSuccess] initState orderId=${widget.orderId} sessionId=${widget.sessionId}');
    if (widget.orderId != null) {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _tries = 0;
    _timedOut = false;
    setState(() => _statusKey = 'verifying');
    _poll();
  }

  void _retryPolling() {
    debugPrint('[CheckoutSuccess] User triggered retry polling');
    _startPolling();
  }

  Future<void> _poll() async {
    if (!mounted || widget.orderId == null) return;
    _tries++;
    debugPrint('[CheckoutSuccess] Poll #$_tries for order ${widget.orderId}');

    try {
      final order = await Supabase.instance.client
          .from('fs_orders')
          .select('status,total_cents,paid_at,created_at,invoice_token')
          .eq('id', widget.orderId!)
          .maybeSingle();

      if (!mounted) return;

      if (order != null) {
        final status = order['status'] as String?;
        final totalCents = (order['total_cents'] as num?)?.toInt();
        final paidAtRaw = order['paid_at'] as String?;
        final createdAtRaw = order['created_at'] as String?;
        final invoiceToken = order['invoice_token'] as String?;

        debugPrint('[CheckoutSuccess] Poll #$_tries status=$status invoiceToken=${invoiceToken != null}');

        setState(() {
          _totalCents = totalCents ?? _totalCents;
          _invoiceToken = invoiceToken ?? _invoiceToken;
          _paidAt = paidAtRaw != null ? DateTime.tryParse(paidAtRaw) : _paidAt;
          _createdAt = createdAtRaw != null
              ? DateTime.tryParse(createdAtRaw)
              : _createdAt;
        });

        if (status == 'paid') {
          debugPrint('[CheckoutSuccess] Order ${widget.orderId} is PAID');
          _timer?.cancel();

          if (!_finalized) {
            _finalized = true;
            try {
              await ref.read(cartProvider.notifier).clear();
            } catch (_) {}
            ref.invalidate(cartProvider);
            ref.invalidate(ordersProvider);

            try {
              final items = await Supabase.instance.client
                  .from('fs_order_items')
                  .select('name,qty,size,line_total_cents')
                  .eq('order_id', widget.orderId!)
                  .order('created_at', ascending: true);
              _items = (items as List).cast<Map<String, dynamic>>();
            } catch (_) {}
          }

          setState(() {
            _isPaid = true;
            _statusKey = null;
            _timedOut = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('[CheckoutSuccess] Poll error: $e');
    }

    if (!mounted) return;

    if (_tries < _maxTries) {
      _timer = Timer(const Duration(seconds: 2), _poll);
    } else {
      debugPrint('[CheckoutSuccess] Polling timed out after $_maxTries tries');
      setState(() {
        _timedOut = true;
        _statusKey = 'timeout';
      });
    }
  }

  Future<void> _openInvoice() async {
    if (_invoiceToken == null || widget.orderId == null) return;
    if (_invoiceLoading) return;
    final t = S.of(context)!;

    setState(() => _invoiceLoading = true);
    try {
      await PdfService.downloadAndOpenInvoice(
        orderId: widget.orderId!,
        invoiceToken: _invoiceToken!,
      );
    } on PdfDownloadException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'no_session' => t.ordersInvoiceLoginRequired,
        'session_expired' => t.ordersInvoiceSessionExpired,
        'not_found' => t.ordersInvoiceNotFound,
        _ => t.ordersInvoiceError,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (kDebugMode) debugPrint('[CheckoutSuccess] Invoice error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.ordersInvoiceError)),
      );
    } finally {
      if (mounted) setState(() => _invoiceLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;

    final orderShort = widget.orderId == null
        ? null
        : (widget.orderId!.length > 8
            ? widget.orderId!.substring(0, 8)
            : widget.orderId!);

    final totalText = _totalCents == null
        ? null
        : '${(_totalCents! / 100).toStringAsFixed(2)} \u20ac';

    final dt = _isPaid ? _paidAt : _createdAt;
    final dateText = dt == null
        ? null
        : '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year} '
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';

    final statusText = switch (_statusKey) {
      'verifying' => t.checkoutVerifying,
      'timeout' => t.checkoutTimeoutMsg,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(t.checkoutOrderConfirmed),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              _isPaid ? Icons.check_circle : Icons.hourglass_top,
              size: 48,
              color: _isPaid
                  ? const Color(0xFF111111)
                  : const Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 24),
            Text(
              _isPaid ? t.checkoutConfirmed : t.checkoutThanks,
              style: theme.textTheme.titleMedium?.copyWith(
                letterSpacing: 2.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _isPaid ? t.checkoutConfirmedMsg : t.checkoutVerifyingMsg,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),

            if (widget.orderId != null) ...[
              const SizedBox(height: 20),
              Text(
                '${t.checkoutOrder}: $orderShort',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFBDBDBD),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (totalText != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${t.checkoutTotal}: $totalText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (dateText != null) ...[
                const SizedBox(height: 6),
                Text(
                  _isPaid
                      ? '${t.checkoutConfirmedAt}: $dateText'
                      : '${t.checkoutCreatedAt}: $dateText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],

            // Status / polling indicator
            if (statusText != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isPaid && !_timedOut)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      statusText,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF9E9E9E)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],

            // Timeout: retry + contact CTAs
            if (_timedOut && !_isPaid) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _retryPolling,
                child: Text(t.checkoutRetryVerification),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse('mailto:soporte@fashionstore.com?subject=Pedido%20${widget.orderId ?? ""}'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Text(t.checkoutContactSupport),
              ),
            ],

            const SizedBox(height: 40),
            if (_isPaid && _invoiceToken != null && _invoiceToken!.isNotEmpty)
              OutlinedButton.icon(
                onPressed: _invoiceLoading ? null : _openInvoice,
                icon: _invoiceLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(t.checkoutViewInvoice),
              ),
            if (_isPaid && _items.isNotEmpty) ...[
              const SizedBox(height: 18),
              ..._items.take(6).map((m) {
                final name = (m['name'] as String? ?? '').trim();
                final qty = (m['qty'] as num?)?.toInt() ?? 1;
                final size = m['size'] as String?;
                final line = (m['line_total_cents'] as num?)?.toInt() ?? 0;
                final lineText = '${(line / 100).toStringAsFixed(2)} \u20ac';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${name.isEmpty ? t.checkoutArticle : name}${size != null ? ' ($size)' : ''} x$qty',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(lineText, style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.invalidate(ordersProvider);
                context.go('/cuenta/pedidos');
              },
              child: Text(t.checkoutMyOrders),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                ref.invalidate(ordersProvider);
                context.go('/');
              },
              child: Text(t.checkoutBackHome),
            ),
          ],
        ),
      ),
    );
  }
}
