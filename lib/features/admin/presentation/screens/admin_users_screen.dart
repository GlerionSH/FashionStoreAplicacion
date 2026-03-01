import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/supabase_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await SupabaseService.client.functions.invoke(
        'admin-users',
        method: HttpMethod.get,
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _users = (data['users'] as List? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _patchUser(Map<String, dynamic> user, {String? role, bool? disabled}) async {
    final t = S.of(context)!;
    try {
      await SupabaseService.client.functions.invoke(
        'admin-users',
        method: HttpMethod.patch,
        body: {
          'user_id': user['id'],
          if (role != null) 'role': role,
          if (disabled != null) 'disabled': disabled,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.adminUserSaved)));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminUsersTitle),
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
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
        ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!), const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: Text(t.adminRetry)),
                ]))
              : _users.isEmpty
                  ? Center(child: Text(t.adminUserNoData))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      separatorBuilder: (_, i) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final user = _users[i];
                        final email = user['email'] as String? ?? '';
                        final role = user['role'] as String? ?? 'user';
                        final isActive = user['is_active'] as bool? ?? true;
                        final isAdmin = role == 'admin';
                        final lastLogin = user['last_sign_in_at'] as String?;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(email,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                decoration: isActive ? null : TextDecoration.lineThrough,
                                                color: isActive ? null : Colors.grey,
                                              )),
                                          Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(top: 4),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                color: isAdmin ? Colors.purple.shade100 : Colors.grey.shade200,
                                                child: Text(
                                                  role.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isAdmin ? Colors.purple.shade800 : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                              if (!isActive) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  margin: const EdgeInsets.only(top: 4),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  color: Colors.red.shade100,
                                                  child: Text(
                                                    t.adminUserDisabled.toUpperCase(),
                                                    style: TextStyle(fontSize: 10, color: Colors.red.shade800),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (lastLogin != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                '${t.adminUserLastLogin}: ${_formatDate(lastLogin)}',
                                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (action) {
                                        switch (action) {
                                          case 'toggle_admin':
                                            _patchUser(user, role: isAdmin ? 'user' : 'admin');
                                          case 'toggle_active':
                                            _patchUser(user, disabled: isActive);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'toggle_admin',
                                          child: Text(isAdmin ? t.adminUserMakeUser : t.adminUserMakeAdmin),
                                        ),
                                        PopupMenuItem(
                                          value: 'toggle_active',
                                          child: Text(isActive ? t.adminUserDisableBtn : t.adminUserEnableBtn),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
