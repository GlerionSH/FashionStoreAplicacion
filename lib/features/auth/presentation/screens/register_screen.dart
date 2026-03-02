import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      
      final response = await client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      // Check if email confirmation is required
      if (response.user != null && response.session == null) {
        // Email confirmation required
        setState(() {
          _success = true;
          _isLoading = false;
        });
      } else if (response.user != null && response.session != null) {
        // Auto-logged in (no email confirmation)
        if (mounted) {
          context.go('/');
        }
      } else {
        setState(() {
          _error = 'Error al crear la cuenta';
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error inesperado: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          debugPrint('[RegisterScreen] Back navigation');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear cuenta'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _success
                  ? _buildSuccessView(theme)
                  : _buildForm(t, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Cuenta creada!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Revisa tu correo electrónico para confirmar tu cuenta.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('IR A INICIAR SESIÓN'),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(S t, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Image.asset(
            'assets/icon/logo3.png',
            height: 50,
            errorBuilder: (_, __, ___) => const Text(
              'FASHION STORE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 4.0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Email
          TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: t.loginEmail,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              if (v == null || v.isEmpty) {
                return t.loginEmailRequired;
              }
              if (!v.contains('@') || !v.contains('.')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password
          TextFormField(
            controller: _passCtrl,
            decoration: InputDecoration(
              labelText: t.loginPassword,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) {
              if (v == null || v.isEmpty) {
                return t.loginPasswordRequired;
              }
              if (v.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Confirm Password
          TextFormField(
            controller: _confirmPassCtrl,
            decoration: const InputDecoration(
              labelText: 'Repetir contraseña',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (v != _passCtrl.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Create Account Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('CREAR CUENTA'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Already have account button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF111111)),
              ),
              child: const Text(
                'YA TENGO CUENTA',
                style: TextStyle(color: Color(0xFF111111)),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
