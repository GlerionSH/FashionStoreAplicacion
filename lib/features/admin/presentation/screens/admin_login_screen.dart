import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final failure = await ref.read(signInNotifierProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

    if (!mounted) return;

    if (failure != null) {
      setState(() => _error = failure.message);
    } else {
      context.go('/admin-panel');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInNotifierProvider);
    final isLoading = authState.isLoading;

    final t = S.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.adminTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo placeholder
                  Image.asset(
                    'assets/icon/logo3.png',
                    height: 60,
                    errorBuilder: (_, _, _) => const Text(
                      'FASHION STORE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t.adminPanelTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E9E9E),
                      )),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: t.loginEmail,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? t.loginEmailRequired : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(
                      labelText: t.loginPassword,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) => (v == null || v.isEmpty)
                        ? t.loginPasswordRequired
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(t.loginButton),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
