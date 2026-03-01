import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_session_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final loggedIn = session != null;
    final theme = Theme.of(context);
    final t = S.of(context);
    
    if (t == null) {
      debugPrint('[AccountScreen] ERROR: Localizations not loaded');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final locale = ref.watch(localeProvider);
    
    debugPrint('[AccountScreen] Session: ${session != null ? "logged in (${session.user.email})" : "not logged in"}');

    if (!loggedIn) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            debugPrint('[AccountScreen] Back navigation (not logged in)');
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
              const SizedBox(height: 48),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFF5F5F5),
                      child: Icon(Icons.person_outline,
                          size: 36, color: Color(0xFFBDBDBD)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.accountLogin,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF9E9E9E)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: FilledButton(
                        onPressed: () => context.go('/login'),
                        child: Text(t.accountLoginBtn),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _NewsletterBlock(prefillEmail: null),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _AccountCard(
                icon: Icons.translate_outlined,
                title: t.accountLanguage,
                subtitle: locale.languageCode == 'es'
                    ? t.accountLanguageEs
                    : t.accountLanguageEn,
                trailing: Switch.adaptive(
                  value: locale.languageCode == 'en',
                  activeTrackColor: const Color(0xFF111111),
                  onChanged: (_) =>
                      ref.read(localeProvider.notifier).toggle(),
                ),
                onTap: () => ref.read(localeProvider.notifier).toggle(),
              ),
              const SizedBox(height: 8),
              _AccountCard(
                icon: Icons.headset_mic_outlined,
                title: t.accountSupport,
                subtitle: t.accountSupportSubtitle,
                onTap: () => context.go('/cuenta/soporte'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        ),
      );
    }

    final email = session.user.email ?? '';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('[AccountScreen] Back navigation (logged in)');
        }
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
          // --- Header ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 40,
              24,
              32,
            ),
            color: const Color(0xFFFAFAFA),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF111111),
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.accountTitleUpper,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Menu items ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _AccountCard(
                  icon: Icons.receipt_long_outlined,
                  title: t.accountOrders,
                  subtitle: t.accountOrdersSubtitle,
                  onTap: () => context.go('/cuenta/pedidos'),
                ),
                const SizedBox(height: 8),
                _AccountCard(
                  icon: Icons.local_shipping_outlined,
                  title: t.accountAddress,
                  subtitle: t.accountAddressPlaceholder,
                  enabled: false,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _AccountCard(
                  icon: Icons.translate_outlined,
                  title: t.accountLanguage,
                  subtitle: locale.languageCode == 'es'
                      ? t.accountLanguageEs
                      : t.accountLanguageEn,
                  trailing: Switch.adaptive(
                    value: locale.languageCode == 'en',
                    activeTrackColor: const Color(0xFF111111),
                    onChanged: (_) =>
                        ref.read(localeProvider.notifier).toggle(),
                  ),
                  onTap: () =>
                      ref.read(localeProvider.notifier).toggle(),
                ),
                const SizedBox(height: 8),
                _AccountCard(
                  icon: Icons.headset_mic_outlined,
                  title: t.accountSupport,
                  subtitle: t.accountSupportSubtitle,
                  onTap: () => context.go('/cuenta/soporte'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- Logout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                await ref
                    .read(signInNotifierProvider.notifier)
                    .signOut();
                if (context.mounted) context.go('/');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: Text(t.accountLogout),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final Widget? trailing;

  const _AccountCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: const Color(0xFFFAFAFA),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFF111111)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  const Icon(Icons.chevron_right,
                      size: 18, color: Color(0xFFBDBDBD)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Newsletter subscription block ─────────────────────────────────────────
class _NewsletterBlock extends StatefulWidget {
  final String? prefillEmail;
  const _NewsletterBlock({this.prefillEmail});

  @override
  State<_NewsletterBlock> createState() => _NewsletterBlockState();
}

class _NewsletterBlockState extends State<_NewsletterBlock> {
  late final TextEditingController _emailCtrl;
  bool _loading = false;
  String? _message;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.prefillEmail ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    final t = S.of(context)!;
    setState(() { _loading = true; _message = null; });
    try {
      final resp = await Supabase.instance.client.functions.invoke(
        'newsletter',
        body: {'email': email, 'action': 'subscribe'},
      );
      if (!mounted) return;
      final data = resp.data as Map<String, dynamic>;
      if (data['ok'] == true) {
        setState(() {
          _isSubscribed = true;
          _message = data['already'] == true
              ? t.newsletterAlreadySubscribed
              : t.newsletterSubscribed;
        });
      } else {
        setState(() => _message = t.newsletterError);
      }
    } catch (_) {
      setState(() => _message = S.of(context)!.newsletterError);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _unsubscribe() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() { _loading = true; _message = null; });
    try {
      await Supabase.instance.client.functions.invoke(
        'newsletter',
        body: {'email': email, 'action': 'unsubscribe'},
      );
      setState(() {
        _isSubscribed = false;
        _message = S.of(context)!.newsletterUnsubscribed;
      });
    } catch (_) {
      setState(() => _message = S.of(context)!.newsletterError);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline, size: 20, color: Color(0xFF111111)),
              const SizedBox(width: 10),
              Text(t.newsletterTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.newsletterSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9E9E9E),
                fontSize: 11,
              )),
          const SizedBox(height: 12),
          if (!_isSubscribed)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: t.newsletterEmail,
                      hintStyle: theme.textTheme.bodySmall,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: const OutlineInputBorder(),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FilledButton(
                    onPressed: _loading ? null : _subscribe,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5, color: Colors.white),
                          )
                        : Text(t.newsletterSubscribe,
                            style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              onPressed: _loading ? null : _unsubscribe,
              style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              child: Text(t.newsletterUnsubscribe,
                  style: const TextStyle(fontSize: 11)),
            ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isSubscribed
                      ? Colors.green.shade700
                      : theme.colorScheme.error,
                  fontSize: 11,
                )),
          ],
        ],
      ),
    );
  }
}
