import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for tickets list
final adminTicketsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, filter) async {
  final client = Supabase.instance.client;
  
  final response = filter == 'all'
      ? await client
          .from('fs_support_tickets')
          .select('*')
          .order('last_message_at', ascending: false)
      : await client
          .from('fs_support_tickets')
          .select('*')
          .eq('status', filter)
          .order('last_message_at', ascending: false);

  return (response as List).cast<Map<String, dynamic>>();
});

class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(adminTicketsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOPORTE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin-panel'),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFAFAFA),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Abiertos',
                  selected: _filter == 'open',
                  onTap: () => setState(() => _filter = 'open'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pendientes',
                  selected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cerrados',
                  selected: _filter == 'closed',
                  onTap: () => setState(() => _filter = 'closed'),
                ),
              ],
            ),
          ),

          // Tickets list
          Expanded(
            child: ticketsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay tickets',
                      style: TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminTicketsProvider(_filter)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final ticket = tickets[i];
                      return _TicketTile(ticket: ticket);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111111) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF111111) : const Color(0xFFE5E5E5),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _TicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = ticket['id'] as String? ?? '';
    final email = ticket['email'] as String? ?? '';
    final subject = ticket['subject'] as String? ?? '';
    final status = ticket['status'] as String? ?? 'open';
    final createdAt = ticket['created_at'] as String? ?? '';

    final statusLabel = switch (status) {
      'open' => 'Abierto',
      'pending' => 'Pendiente',
      'closed' => 'Cerrado',
      _ => status,
    };

    final statusColor = switch (status) {
      'open' => Colors.orange.shade700,
      'pending' => Colors.blue.shade700,
      'closed' => Colors.grey.shade600,
      _ => Colors.grey.shade600,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade400,
              fontSize: 10,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusLabel,
          style: TextStyle(
            fontSize: 11,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdminTicketDetailScreen(ticketId: id),
        ),
      ),
    );
  }
}

// ============================================================================
// ADMIN TICKET DETAIL SCREEN
// ============================================================================

final adminTicketDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, ticketId) async {
  final client = Supabase.instance.client;

  final ticket = await client
      .from('fs_support_tickets')
      .select('*')
      .eq('id', ticketId)
      .single();

  final replies = await client
      .from('fs_support_replies')
      .select('*')
      .eq('ticket_id', ticketId)
      .order('created_at', ascending: true);

  return {
    'ticket': ticket,
    'replies': replies,
  };
});

class AdminTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const AdminTicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<AdminTicketDetailScreen> createState() => _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends ConsumerState<AdminTicketDetailScreen> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
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

  Future<void> _sendReply() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;

    setState(() => _sending = true);

    try {
      final client = Supabase.instance.client;

      final response = await client.functions.invoke(
        'support',
        body: {
          'action': 'send_message',
          'ticket_id': widget.ticketId,
          'author': 'admin',
          'body': body,
        },
      );

      if (response.data == null || response.data['ok'] != true) {
        throw Exception('Failed to send reply');
      }

      _replyCtrl.clear();
      ref.invalidate(adminTicketDetailProvider(widget.ticketId));
      _scrollToBottom();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta enviada')),
        );
      }
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

  Future<void> _closeTicket() async {
    try {
      final client = Supabase.instance.client;

      final response = await client.functions.invoke(
        'support',
        body: {
          'action': 'close_ticket',
          'ticket_id': widget.ticketId,
        },
      );

      if (response.data == null || response.data['ok'] != true) {
        throw Exception('Failed to close ticket');
      }

      ref.invalidate(adminTicketDetailProvider(widget.ticketId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket cerrado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(adminTicketDetailProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE TICKET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _closeTicket,
            tooltip: 'Cerrar ticket',
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final ticket = data['ticket'] as Map<String, dynamic>?;
          final replies = (data['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          if (ticket == null) {
            return const Center(child: Text('Ticket no encontrado'));
          }

          final status = ticket['status'] as String? ?? 'open';
          final isClosed = status == 'closed';

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              // Ticket info header
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFAFAFA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket['subject'] as String? ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFF666666)),
                        const SizedBox(width: 4),
                        Text(
                          ticket['name'] as String? ?? 'Sin nombre',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF666666),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.email_outlined, size: 14, color: Color(0xFF666666)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket['email'] as String? ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.ticketId.substring(0, 8)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF999999),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Conversation
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminTicketDetailProvider(widget.ticketId)),
                  child: ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Original message
                      _MessageBubble(
                        author: 'user',
                        body: ticket['message'] as String? ?? '',
                        createdAt: ticket['created_at'] as String? ?? '',
                      ),

                      // Replies
                      for (final reply in replies) ...[
                        const SizedBox(height: 12),
                        _MessageBubble(
                          author: reply['author'] as String? ?? 'admin',
                          body: reply['reply_text'] as String? ?? '',
                          createdAt: reply['created_at'] as String? ?? '',
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Reply input
              if (!isClosed)
                Container(
                  padding: const EdgeInsets.all(16),
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
                          controller: _replyCtrl,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu respuesta...',
                            hintStyle: theme.textTheme.bodySmall,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          style: theme.textTheme.bodySmall,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendReply(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sending ? null : _sendReply,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
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

class _MessageBubble extends StatelessWidget {
  final String author;
  final String body;
  final String createdAt;

  const _MessageBubble({
    required this.author,
    required this.body,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = author == 'admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFE3F2FD) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAdmin ? const Color(0xFF90CAF9) : const Color(0xFFE0E0E0),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isAdmin ? 'ADMIN' : 'USUARIO',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: isAdmin ? const Color(0xFF1976D2) : const Color(0xFF9E9E9E),
                ),
              ),
              const Spacer(),
              Text(
                createdAt.length >= 16
                    ? createdAt.substring(0, 16).replaceAll('T', ' ')
                    : createdAt,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
