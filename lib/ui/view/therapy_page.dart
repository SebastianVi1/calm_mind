import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/chat_message.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/ui/widgets/end_drawer.dart';
import 'package:calm_mind/viewmodels/chat_view_model.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';
import 'package:calm_mind/ui/constants/animation_constants.dart';
import 'package:intl/intl.dart';

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const _TherapyMainPage(),
        );
      },
    );
  }
}

class _TherapyMainPage extends StatefulWidget {
  const _TherapyMainPage();

  @override
  State<_TherapyMainPage> createState() => _TherapyMainPageState();
}

class _TherapyMainPageState extends State<_TherapyMainPage> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Terapia',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const _ChatHistoryPage()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.history, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Expanded(child: _MessageList()),
                      const _MessageInput(),
                    ],
                  ),
                  Consumer<ChatViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading &&
                          viewModel.messages.isNotEmpty &&
                          !viewModel.messages.last.isUser &&
                          viewModel.messages.last.content.isNotEmpty) {
                        _isAnimating = true;
                      } else {
                        _isAnimating = false;
                      }

                      return _isAnimating
                          ? Positioned(
                              key: const ValueKey('loading'),
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Lottie.asset(
                                        'assets/animations/talk.json',
                                        frameRate: const FrameRate(30),
                                        fit: BoxFit.contain,
                                        repeat: true,
                                        animate: true,
                                        options: LottieOptions(
                                          enableMergePaths: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Numa está escribiendo...',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
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

class _ChatHistoryPage extends StatelessWidget {
  const _ChatHistoryPage();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 7) return 'Hace $difference días';
    if (difference < 30) return 'Hace ${(difference / 7).floor()} semanas';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de sesiones'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final viewModel = context.read<ChatViewModel>();
              await viewModel.startNewSession();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nueva sesión',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      const Text('Borrar historial'),
                    ],
                  ),
                  content: const Text('¿Estás seguro de que quieres borrar todo el historial de chat?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<ChatViewModel>().clearChat();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Borrar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar historial',
          ),
        ],
      ),
      endDrawer: WEndDrawer(),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay sesiones guardadas',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comienza tu primera sesión de terapia',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await viewModel.startNewSession();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Iniciar nueva sesión'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.sessions.length,
            itemBuilder: (context, index) {
              final sessionId = viewModel.sessions.keys.elementAt(index);
              final sessionMessages = viewModel.sessions[sessionId]!;
              final firstMessage = sessionMessages.first;
              final lastMessage = sessionMessages.last;
              final userMessages = sessionMessages.where((m) => m.isUser).toList();
              final titleMessage =
                  userMessages.isNotEmpty ? userMessages.first : firstMessage;

              return FadeInUp(
                config: BaseAnimationConfig(
                  delay: (index * 50).ms,
                  child: _SessionCard(
                    title: titleMessage.content,
                    subtitle: '${sessionMessages.length} mensajes',
                    date: _formatDate(firstMessage.timestamp),
                    lastMessageTime: DateFormat('HH:mm').format(lastMessage.timestamp),
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await viewModel.continueSession(sessionId);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String lastMessageTime;
  final VoidCallback onTap;

  const _SessionCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.chat_bubble,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.length > 40 ? '${title.substring(0, 40)}...' : title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(' • ', style: theme.textTheme.bodySmall),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    lastMessageTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.messages.isEmpty) {
          return _EmptyChatState();
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: viewModel.messages.length,
          itemBuilder: (context, index) {
            final message =
                viewModel.messages[viewModel.messages.length - 1 - index];
            return FadeInUp(
              config: BaseAnimationConfig(
                child: _MessageBubble(message: message),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Comienza tu sesión de terapia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Numa está aquí para escucharte y ayudarte',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickQuestionChip('¿Cómo puedo relajarme?', Icons.spa),
                _QuickQuestionChip('Me siento ansioso', Icons.favorite),
                _QuickQuestionChip('Necesito motivación', Icons.lightbulb),
                _QuickQuestionChip('No puedo dormir', Icons.bedtime),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickQuestionChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _QuickQuestionChip(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(text),
      onPressed: () {
        HapticFeedback.lightImpact();
        context.read<ChatViewModel>().sendMessage(text);
      },
      backgroundColor: theme.colorScheme.surfaceVariant,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.colorScheme.primary.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.psychology,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    color: isUser ? null : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser
                                ? theme.colorScheme.primary
                                : Colors.transparent)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: userViewModel.getProfileImage(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput();

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();
    final theme = Theme.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      tooltip: 'Adjuntar',
                    ),
                  ),
                  enabled: !viewModel.isLoading,
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) => _sendMessage(viewModel),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: AppAnimations.micro,
              curve: AppAnimations.smooth,
              child: IconButton(
                icon: hasText || viewModel.isLoading
                    ? Icon(
                        viewModel.isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      )
                    : Icon(Icons.mic, color: theme.colorScheme.primary),
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        if (hasText) {
                          _sendMessage(viewModel);
                        } else {
                          HapticFeedback.lightImpact();
                        }
                      },
                tooltip: hasText ? 'Enviar mensaje' : 'Usar voz',
                style: IconButton.styleFrom(
                  backgroundColor: hasText || viewModel.isLoading
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.15),
                  foregroundColor: hasText || viewModel.isLoading
                      ? Colors.white
                      : theme.colorScheme.primary,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatViewModel viewModel) {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      HapticFeedback.mediumImpact();
      viewModel.sendMessage(message);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }
}
