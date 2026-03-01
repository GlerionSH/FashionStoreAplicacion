import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../l10n/app_localizations.dart';
import '../../flash/presentation/providers/admin_flash_providers.dart';

class AdminFlashScreen extends ConsumerWidget {
  const AdminFlashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashAv = ref.watch(adminFlashListProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminFlashTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF000000),
        onRefresh: () async => ref.invalidate(adminFlashListProvider),
        child: flashAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: theme.textTheme.bodySmall),
          ),
          data: (offers) {
            if (offers.isEmpty) {
              return Center(
                child: Text(t.adminFlashNoOffers,
                    style: theme.textTheme.bodySmall),
              );
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: offers.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) =>
                  _FlashOfferTile(offer: offers[i]),
            );
          },
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final discountCtrl = TextEditingController(text: '20');
    final titleCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    final t = S.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.adminFlashNewOffer,
            style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: discountCtrl,
                decoration: InputDecoration(
                  labelText: t.adminFlashDiscount,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: t.adminFlashPopupTitle,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                decoration: InputDecoration(
                  labelText: t.adminFlashPopupText,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.adminCancel),
          ),
          FilledButton(
            onPressed: () async {
              final newId = const Uuid().v4();
              final ds = ref.read(adminFlashDatasourceProvider);
              // Astro rule: disable others before enabling the new one
              await ds.disableAllExcept(newId);
              final data = {
                'id': newId,
                'discount_percent':
                    int.tryParse(discountCtrl.text) ?? 20,
                'is_enabled': true,
                'show_popup': titleCtrl.text.trim().isNotEmpty,
                'popup_title': titleCtrl.text.trim().isEmpty
                    ? null
                    : titleCtrl.text.trim(),
                'popup_text': textCtrl.text.trim().isEmpty
                    ? null
                    : textCtrl.text.trim(),
                'starts_at': DateTime.now().toIso8601String(),
                'ends_at': DateTime.now()
                    .add(const Duration(days: 7))
                    .toIso8601String(),
              };
              await ds.upsertFlashOffer(data);
              ref.invalidate(adminFlashListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(t.adminCreate),
          ),
        ],
      ),
    );
  }
}

class _FlashOfferTile extends ConsumerWidget {
  final Map<String, dynamic> offer;
  const _FlashOfferTile({required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = (offer['id'] ?? '').toString();
    final discount = (offer['discount_percent'] as num?)?.toInt() ?? 0;
    final enabled = offer['is_enabled'] == true;
    final startsAt = offer['starts_at'] as String? ?? '';
    final endsAt = offer['ends_at'] as String? ?? '';
    final showPopup = offer['show_popup'] == true;
    final popupTitle = offer['popup_title'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('-$discount%',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                if (popupTitle.isNotEmpty)
                  Text(popupTitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF616161))),
                Text(
                  '${startsAt.length >= 10 ? startsAt.substring(0, 10) : ''} → ${endsAt.length >= 10 ? endsAt.substring(0, 10) : ''}',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9E9E9E)),
                ),
                if (showPopup)
                  Text(S.of(context)!.adminFlashPopupActive,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeTrackColor: const Color(0xFF111111),
            onChanged: (val) async {
              await ref
                  .read(adminFlashDatasourceProvider)
                  .toggleEnabled(id, enabled: val);
              ref.invalidate(adminFlashListProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Color(0xFF9E9E9E)),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text(
                    S.of(context)!.adminProductDeleteMsg,
                    style: const TextStyle(fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(S.of(context)!.adminCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(S.of(context)!.adminProductDeleteBtn),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(adminFlashDatasourceProvider)
                    .deleteFlashOffer(id);
                ref.invalidate(adminFlashListProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}
