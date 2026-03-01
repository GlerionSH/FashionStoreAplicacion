import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/services/supabase_service.dart';

class ConnectivityDiagnosticsScreen extends StatefulWidget {
  const ConnectivityDiagnosticsScreen({super.key});

  @override
  State<ConnectivityDiagnosticsScreen> createState() =>
      _ConnectivityDiagnosticsScreenState();
}

class _ConnectivityDiagnosticsScreenState
    extends State<ConnectivityDiagnosticsScreen> {
  final List<_TestResult> _results = [];
  bool _running = false;

  Future<void> _runAll() async {
    setState(() {
      _results.clear();
      _running = true;
    });

    if (!kIsWeb) {
      await _testInternet();
    }
    await _testSupabaseRest();
    await _testFsProducts();

    setState(() => _running = false);
  }

  // --- Test 1: Internet connectivity (non-web only) ---
  Future<void> _testInternet() async {
    _addRunning('Ping google.com');
    try {
      final resp = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        _update('Ping google.com', _Status.ok, 'Conexion a internet OK');
      } else {
        _update('Ping google.com', _Status.fail,
            'Status ${resp.statusCode}');
      }
    } catch (e) {
      _update('Ping google.com', _Status.fail,
          'Sin conexion a internet: ${_shortError(e)}');
    }
  }

  // --- Test 2: Supabase REST endpoint reachable ---
  Future<void> _testSupabaseRest() async {
    _addRunning('Test Supabase REST');
    try {
      final url = SupabaseService.client.rest.url;
      final headers = SupabaseService.client.rest.headers;

      final resp = await http
          .get(Uri.parse(url.toString()), headers: Map<String, String>.from(headers))
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        _update('Test Supabase REST', _Status.ok,
            'REST endpoint OK (${resp.statusCode})');
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        _update('Test Supabase REST', _Status.fail,
            'Auth/RLS error ${resp.statusCode}. '
            'Verifica SUPABASE_ANON_KEY y RLS policies.');
      } else {
        _update('Test Supabase REST', _Status.fail,
            'Status ${resp.statusCode}: ${resp.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      final isCors = kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('XMLHttpRequest'));
      if (isCors) {
        _update('Test Supabase REST', _Status.fail,
            'CORS bloqueado. Pasos:\n'
            '1) Desactiva extensiones de navegador (ad-blockers)\n'
            '2) En Supabase Dashboard > Settings > API > CORS Allowed Origins, '
            'anade http://localhost:<puerto>\n'
            '3) Prueba en ventana incognito');
      } else {
        _update('Test Supabase REST', _Status.fail,
            'ClientException: ${e.message}');
      }
    } catch (e) {
      _update('Test Supabase REST', _Status.fail, _shortError(e));
    }
  }

  // --- Test 3: SELECT id FROM fs_products LIMIT 1 ---
  Future<void> _testFsProducts() async {
    _addRunning('Test fs_products select');
    try {
      final data = await SupabaseService.client
          .from('fs_products')
          .select('id')
          .limit(1);

      final list = data as List;
      if (list.isNotEmpty) {
        _update('Test fs_products select', _Status.ok,
            'OK — ${list.length} fila(s). id=${list.first['id']}');
      } else {
        _update('Test fs_products select', _Status.warn,
            'Query OK pero 0 filas. '
            'Tabla vacia o RLS bloqueando SELECT para anon.\n'
            'SQL sugerido:\n'
            'CREATE POLICY "anon_select_products" ON fs_products\n'
            '  FOR SELECT TO anon USING (is_active = true);');
      }
    } on PostgrestException catch (e) {
      final code = e.code;
      if (code == '42501' || code == '401' || code == '403') {
        _update('Test fs_products select', _Status.fail,
            'RLS/Permisos (code=$code): ${e.message}\n'
            'SQL sugerido:\n'
            'CREATE POLICY "anon_select_products" ON fs_products\n'
            '  FOR SELECT TO anon USING (is_active = true);');
      } else {
        _update('Test fs_products select', _Status.fail,
            'PostgrestException code=$code: ${e.message}');
      }
    } on http.ClientException catch (e) {
      final isCors = kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('XMLHttpRequest'));
      _update('Test fs_products select', _Status.fail,
          isCors ? 'CORS bloqueado (ver test anterior)' : e.message);
    } catch (e) {
      _update('Test fs_products select', _Status.fail, _shortError(e));
    }
  }

  void _addRunning(String name) {
    setState(() {
      _results.add(_TestResult(name: name, status: _Status.running));
    });
  }

  void _update(String name, _Status status, String detail) {
    setState(() {
      final idx = _results.indexWhere((r) => r.name == name);
      if (idx != -1) {
        _results[idx] = _TestResult(
            name: name, status: status, detail: detail);
      }
    });
  }

  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 200 ? '${s.substring(0, 200)}...' : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosticos de conexion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ejecuta los tests para verificar la conectividad '
            'con Supabase y la tabla fs_products.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _running ? null : _runAll,
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_running ? 'Ejecutando...' : 'Ejecutar todos los tests'),
          ),
          const SizedBox(height: 24),
          for (final r in _results) ...[
            _TestResultTile(result: r),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

enum _Status { running, ok, warn, fail }

class _TestResult {
  final String name;
  final _Status status;
  final String detail;

  const _TestResult({
    required this.name,
    this.status = _Status.running,
    this.detail = '',
  });
}

class _TestResultTile extends StatelessWidget {
  final _TestResult result;

  const _TestResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (result.status) {
      _Status.running => (Icons.hourglass_top, Colors.grey),
      _Status.ok => (Icons.check_circle, Colors.green),
      _Status.warn => (Icons.warning_amber, Colors.orange),
      _Status.fail => (Icons.cancel, Colors.red),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (result.detail.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(
                result.detail,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
