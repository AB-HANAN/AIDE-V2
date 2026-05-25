import 'package:flutter/material.dart';
import '../models/app_role.dart';
import '../services/robot_api.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    required this.api,
    required this.role,
    required this.displayName,
    this.isDemoMode = false,
  });

  final RobotApi api;
  final AppRole role;
  final String displayName;
  final bool isDemoMode;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _messages;

  bool _sending = false;
  bool _checkingHealth = true;
  bool _backendAvailable = false;
  String _status = '';

  @override
  void initState() {
    super.initState();

    final name =
        widget.displayName.trim().isEmpty ? 'Operator' : widget.displayName;

    _messages = [
      {
        'user': false,
        'text': 'Hello, $name. How may I assist you today?',
      }
    ];

    _checkBackend();
  }

  Future<void> _checkBackend() async {
    if (widget.isDemoMode) {
      if (!mounted) return;
      setState(() {
        _checkingHealth = false;
        _backendAvailable = false;
        _status = 'Demo mode active';
      });
      return;
    }

    try {
      await widget.api.aiHealth();
      if (!mounted) return;
      setState(() {
        _checkingHealth = false;
        _backendAvailable = true;
        _status = 'AI backend connected';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingHealth = false;
        _backendAvailable = false;
        _status = 'AI backend unavailable';
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add({'user': true, 'text': text});
      _controller.clear();
      _sending = true;
    });

    _scrollToBottom();

    if (widget.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _messages.add({
          'user': false,
          'text':
              'Demo mode reply: your message was captured, but no real AI backend is connected in preview mode.',
        });
        _sending = false;
      });
      _scrollToBottom();
      return;
    }

    if (!_backendAvailable) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'user': false,
          'text':
              'The AI backend is currently unavailable. Please check the Jetson server and try again.',
        });
        _sending = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final reply = await widget.api.aiSend(message: text);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'user': false,
          'text': reply.isEmpty
              ? 'The AI backend returned an empty reply.'
              : reply,
        });
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'user': false,
          'text': 'Failed to get AI reply: $e',
        });
        _sending = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    if (_sending) return;

    if (widget.isDemoMode) {
      final name =
          widget.displayName.trim().isEmpty ? 'Operator' : widget.displayName;

      setState(() {
        _messages = [
          {
            'user': false,
            'text': 'Hello, $name. How may I assist you today?',
          }
        ];
        _status = 'Demo chat cleared';
      });
      return;
    }

    try {
      await widget.api.aiClear();

      if (!mounted) return;

      final name =
          widget.displayName.trim().isEmpty ? 'Operator' : widget.displayName;

      setState(() {
        _messages = [
          {
            'user': false,
            'text': 'Hello, $name. How may I assist you today?',
          }
        ];
        _status = 'Chat memory cleared';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Failed to clear chat: $e';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _messageBubble(Map<String, dynamic> message) {
    final isUser = message['user'] == true;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUser
              ? AideColors.primary
              : (isLight
                  ? Colors.black.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUser
                ? Colors.transparent
                : (isLight
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Text(
          message['text'].toString(),
          style: TextStyle(
            color: isUser ? Colors.white : (isLight ? Colors.black87 : Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AideShell(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset('assets/images/robot_hero.png'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chat AI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _clearChat,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Clear chat',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_checkingHealth)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _backendAvailable || widget.isDemoMode
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    size: 18,
                    color: _backendAvailable || widget.isDemoMode
                        ? Colors.greenAccent
                        : AideColors.primarySoft,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black54
                          : AideColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _messages.length + (_sending ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (_sending && index == _messages.length) {
                    final isLight = Theme.of(context).brightness == Brightness.light;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isLight
                              ? Colors.black.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isLight
                                ? Colors.black.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Text(
                          'Thinking...',
                          style: TextStyle(
                            color: isLight ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  return _messageBubble(_messages[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            AidePanel(
              radius: 22,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.92)
                  : AideColors.panel.withValues(alpha: 0.94),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _sending
                            ? AideColors.primary.withValues(alpha: 0.5)
                            : AideColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}