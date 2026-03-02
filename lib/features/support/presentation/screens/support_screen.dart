import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../providers/support_providers.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final session = ref.watch(authSessionProvider);
    final loggedIn = session != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.supportTitle),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: t.supportNewTicket),
            Tab(text: t.supportMyTickets),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _NewTicketForm(
            userEmail: session?.user.email,
            onCreated: () {
              if (loggedIn) ref.invalidate(myTicketsProvider);
              _tabCtrl.animateTo(1);
            },
          ),
          loggedIn
              ? const _TicketListTab()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t.supportLoginToSeeTickets,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFF9E9E9E)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New ticket form
// ---------------------------------------------------------------------------
class _NewTicketForm extends ConsumerStatefulWidget {
  final String? userEmail;
  final VoidCallback onCreated;

  const _NewTicketForm({required this.userEmail, required this.onCreated});

  @override
  ConsumerState<_NewTicketForm> createState() => _NewTicketFormState();
}

class _NewTicketFormState extends ConsumerState<_NewTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.userEmail != null) _emailCtrl.text = widget.userEmail!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = S.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      // Call Edge Function to create ticket + send emails
      final response = await client.functions.invoke(
        'support',
        body: {
          'action': 'create_ticket',
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
          'user_id': userId,
        },
      );

      if (kDebugMode) debugPrint('[Support] Response: ${response.data}');

      if (response.data == null || response.data['ok'] != true) {
        throw Exception('Failed to create ticket');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.supportTicketCreated)),
      );
      _nameCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
      widget.onCreated();
    } catch (e) {
      debugPrint('[Support] Error creating ticket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.supportErrorSending)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: t.supportName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.supportRequiredField : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: t.supportEmail),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return t.supportRequiredField;
                if (!v.contains('@')) return t.supportInvalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectCtrl,
              decoration: InputDecoration(labelText: t.supportSubject),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.supportRequiredField : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageCtrl,
              decoration: InputDecoration(
                labelText: t.supportMessage,
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.supportRequiredField : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? t.supportSending : t.supportSend),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My tickets list
// ---------------------------------------------------------------------------
class _TicketListTab extends ConsumerWidget {
  const _TicketListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final ticketsAv = ref.watch(myTicketsProvider);

    return ticketsAv.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Text(t.supportNoTickets,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFF9E9E9E))),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myTicketsProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, i) {
              final tk = tickets[i];
              return _TicketTile(ticket: tk);
            },
          ),
        );
      },
    );
  }
}

class _TicketTile extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _TicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final status = ticket['status'] as String? ?? 'open';
    final subject = ticket['subject'] as String? ?? '';
    final createdAt = ticket['created_at'] as String? ?? '';
    final id = ticket['id'] as String? ?? '';

    final statusLabel = switch (status) {
      'open' => t.supportOpen,
      'answered' => t.supportAnswered,
      'closed' => t.supportClosed,
      _ => status,
    };
    final statusColor = switch (status) {
      'open' => Colors.orange.shade700,
      'answered' => Colors.green.shade700,
      'closed' => Colors.grey.shade600,
      _ => Colors.grey.shade600,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(
        createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: Colors.grey.shade500, fontSize: 11),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(statusLabel,
            style: TextStyle(
                fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _TicketDetailPage(ticketId: id),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ticket detail page (chat conversation)
// ---------------------------------------------------------------------------
class _TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;

  const _TicketDetailPage({required this.ticketId});

  @override
  ConsumerState<_TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<_TicketDetailPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageCtrl.text.trim();
    if (body.isEmpty) return;

    setState(() => _sending = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      final response = await client.functions.invoke(
        'support',
        body: {
          'action': 'send_message',
          'ticket_id': widget.ticketId,
          'author': 'user',
          'body': body,
          'user_id': userId,
        },
      );

      if (response.data == null || response.data['ok'] != true) {
        throw Exception('Failed to send message');
      }

      _messageCtrl.clear();
      ref.invalidate(ticketDetailProvider(widget.ticketId));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final detailAv = ref.watch(ticketDetailProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(title: Text(t.supportTicketDetail)),
      body: detailAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final ticket = data['ticket'] as Map<String, dynamic>?;
          final replies =
              (data['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          if (ticket == null) {
            return const Center(child: Text('Not found'));
          }

          final status = ticket['status'] as String? ?? 'open';
          final isClosed = status == 'closed';

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(ticketDetailProvider(widget.ticketId)),
                  child: ListView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Original ticket
                      Text(
                        ticket['subject'] as String? ?? '',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.supportYou,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: const Color(0xFF9E9E9E),
                                )),
                            const SizedBox(height: 4),
                            Text(ticket['message'] as String? ?? '',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(height: 1.5)),
                          ],
                        ),
                      ),

                      // Replies
                      for (final reply in replies) ...[
                        const SizedBox(height: 12),
                        _ReplyBubble(reply: reply),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              if (!isClosed)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).padding.bottom + 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageCtrl,
                          decoration: InputDecoration(
                            hintText: t.supportMessage,
                            hintStyle: theme.textTheme.bodySmall,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: const OutlineInputBorder(),
                          ),
                          style: theme.textTheme.bodySmall,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sending ? null : _sendMessage,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Text(
                    'Este ticket está cerrado',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final Map<String, dynamic> reply;

  const _ReplyBubble({required this.reply});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final author = reply['author'] as String? ?? 'admin';
    final isAdmin = author == 'admin';
    final body = reply['reply_text'] as String? ?? '';
    final createdAt = reply['created_at'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFF0F0F0) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(6),
        border: isAdmin
            ? Border.all(color: const Color(0xFFE0E0E0), width: 0.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isAdmin ? t.supportAdmin : t.supportYou,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: isAdmin
                      ? const Color(0xFF111111)
                      : const Color(0xFF9E9E9E),
                ),
              ),
              const Spacer(),
              Text(
                createdAt.length >= 16
                    ? createdAt.substring(0, 16).replaceAll('T', ' ')
                    : createdAt,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontSize: 9, color: const Color(0xFFBDBDBD)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
