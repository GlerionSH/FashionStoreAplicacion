import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../../shared/widgets/fs_price_text.dart';
import '../../../checkout/data/datasources/checkout_remote_datasource.dart';
import '../../../checkout/presentation/providers/checkout_providers.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final items = cartState.items;
    final theme = Theme.of(context);
    final t = S.of(context)!;
    
    debugPrint('[CartScreen] Rendering with ${items.length} items');
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('[CartScreen] Back navigation');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(t.cartTitle)),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 48, color: Color(0xFFBDBDBD)),
                    const SizedBox(height: 20),
                    Text(t.cartEmptyTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          letterSpacing: 2.0,
                        )),
                    const SizedBox(height: 8),
                    Text(t.cartEmptySubtitle,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        onPressed: () => context.go('/productos'),
                        child: Text(t.cartViewCatalog),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
              itemBuilder: (context, index) =>
                  _CartItemTile(item: items[index]),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : _CartBottomBar(items: items),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(cartProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          height: 104,
          child: item.imageUrl != null
              ? Image.network(item.imageUrl!, fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image_outlined,
                      color: Color(0xFFBDBDBD)),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  )),
              if (item.size != null) ...[
                const SizedBox(height: 4),
                Text('${S.of(context)!.cartSize}: ${item.size}',
                    style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 6),
              FsPriceText(priceCents: item.priceCents),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () => notifier.updateQuantity(
                      item.uniqueKey,
                      quantity: item.quantity - 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('${item.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF111111),
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () => notifier.updateQuantity(
                      item.uniqueKey,
                      quantity: item.quantity + 1,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => notifier.removeItem(item.uniqueKey),
                    child: const Icon(Icons.close, size: 18,
                        color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF111111)),
      ),
    );
  }
}

// ── Cart bottom bar with coupon field ──────────────────────────────────────
class _CartBottomBar extends ConsumerStatefulWidget {
  final List<CartItem> items;
  const _CartBottomBar({required this.items});

  @override
  ConsumerState<_CartBottomBar> createState() => _CartBottomBarState();
}

class _CartBottomBarState extends ConsumerState<_CartBottomBar> {
  final _couponCtrl = TextEditingController();
  bool _applyingCoupon = false;
  bool _checkingOut = false;
  String? _appliedCoupon;
  int _couponPercent = 0;
  int _discountCents = 0;
  String? _couponError;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(int subtotalCents) async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() { _applyingCoupon = true; _couponError = null; });
    try {
      final resp = await Supabase.instance.client.functions.invoke(
        'validate-coupon',
        body: {'code': code, 'order_cents': subtotalCents},
      );
      final data = resp.data as Map<String, dynamic>;
      if (data['valid'] == true) {
        setState(() {
          _appliedCoupon = data['code'] as String;
          _couponPercent = data['percent_off'] as int;
          _discountCents = data['discount_cents'] as int;
          _couponError = null;
        });
      } else {
        setState(() {
          _couponError = data['message'] as String? ?? S.of(context)!.couponInvalid;
          _appliedCoupon = null;
          _discountCents = 0;
        });
      }
    } catch (_) {
      setState(() { _couponError = S.of(context)!.couponInvalid; });
    } finally {
      setState(() => _applyingCoupon = false);
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponPercent = 0;
      _discountCents = 0;
      _couponError = null;
      _couponCtrl.clear();
    });
  }

  Future<void> _onCheckout(int subtotalCents) async {
    if (_checkingOut) return;
    setState(() => _checkingOut = true);

    final items = widget.items
        .map((ci) => CheckoutItem(
              productId: ci.productId,
              qty: ci.quantity,
              size: ci.size,
            ))
        .toList();

    final result = await ref
        .read(checkoutNotifierProvider.notifier)
        .payWithPaymentSheet(
          items: items,
          couponCode: _appliedCoupon,
        );

    if (!mounted) return;
    setState(() => _checkingOut = false);

    if (result.failure != null) {
      if (result.failure!.message != 'Pago cancelado') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.failure!.message)),
        );
      }
      return;
    }

    final orderId = result.orderId;
    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.cartErrorNoOrder)),
      );
      return;
    }
    context.go('/checkout/success?order_id=$orderId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final cartState = ref.watch(cartProvider);
    final subtotalCents = cartState.totalCents;
    final finalCents = subtotalCents - _discountCents;
    final totalEuros = (finalCents / 100).toStringAsFixed(2).replaceAll('.', ',');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Coupon row
                if (_appliedCoupon == null) ...
                  [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: t.couponCode,
                              hintStyle: theme.textTheme.bodySmall,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: const OutlineInputBorder(),
                            ),
                            style: theme.textTheme.bodySmall,
                            onSubmitted: (_) => _applyCoupon(subtotalCents),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: OutlinedButton(
                            onPressed: _applyingCoupon ? null : () => _applyCoupon(subtotalCents),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            child: _applyingCoupon
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5))
                                : Text(t.couponApply, style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    if (_couponError != null) ...
                      [
                        const SizedBox(height: 4),
                        Text(_couponError!, style: TextStyle(fontSize: 11, color: theme.colorScheme.error)),
                      ],
                    const SizedBox(height: 10),
                  ]
                else ...
                  [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.couponApplied(_couponPercent),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _removeCoupon,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(t.couponRemove, style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.couponDiscount(_couponPercent),
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700)),
                        Text('- ${(_discountCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                // Total row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.cartTotal,
                        style: theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111111),
                        )),
                    Text('$totalEuros €',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 16),
                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _checkingOut ? null : () => _onCheckout(subtotalCents),
                    child: _checkingOut
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                        : Text(t.cartCheckout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
