import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../settings/presentation/providers/admin_settings_providers.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAv = ref.watch(adminSettingsProvider);
    final theme = Theme.of(context);

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminSettingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel'),
        ),
      ),
      body: settingsAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: theme.textTheme.bodySmall),
        ),
        data: (settings) {
          final flashEnabled =
              settings?['flash_offers_enabled'] == true;

          return ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Text(t.adminSettingsGeneral,
                  style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(t.adminFlashEnabled,
                    style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                    t.adminFlashEnabledSubtitle,
                    style: const
                        TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                value: flashEnabled,
                activeTrackColor: const Color(0xFF111111),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) async {
                  await ref
                      .read(adminSettingsDatasourceProvider)
                      .updateFlashEnabled(enabled: val);
                  ref.invalidate(adminSettingsProvider);
                },
              ),
              const Divider(height: 32),
              Text(t.adminSettingsInfo,
                  style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              if (settings != null)
                ...settings.entries
                    .where((e) => e.key != 'flash_offers_enabled')
                    .map((e) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E))),
                              Flexible(
                                child: Text('${e.value}',
                                    style:
                                        const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        )),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
