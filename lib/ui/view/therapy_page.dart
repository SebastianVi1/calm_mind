import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/chat_message.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/ui/widgets/end_drawer.dart';
import 'package:calm_mind/viewmodels/chat_view_model.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _TherapyMainPage(),
        );
      },
    );
  }
}

class _TherapyMainPage extends StatefulWidget {
  @override
  State<_TherapyMainPage> createState() => _TherapyMainPageState();
}

class _TherapyMainPageState extends State<_TherapyMainPage> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Terapia',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.start,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _ChatHistoryPage()),
              );
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => openGlobalEndDrawer(context),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                const Expanded(child: _MessageList()),
                const _MessageInput(),
              ],
            ),
            // Animation overlay
            Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                // Start animation only when AI starts responding (content is not empty)
                if (viewModel.isLoading && viewModel.messages.isNotEmpty && 
                    !viewModel.messages.last.isUser && viewModel.messages.last.content.isNotEmpty) {
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
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light 
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Lottie.asset(
                          'assets/animations/talk.json',
                          frameRate: FrameRate(30),
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                          options: LottieOptions(
                            enableMergePaths: true,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de sesiones',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft02, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChatAdd, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
            onPressed: () async {
              final viewModel = context.read<ChatViewModel>();
              await viewModel.startNewSession();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Start New Chat',
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Borrar historial'),
                  content: const Text('¿Estás seguro de que quieres borrar todo el historial de chat?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<ChatViewModel>().clearChat();
                      },
                      child: const Text('Borrar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      endDrawer: WEndDrawer(),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay sesiones guardadas'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.startNewSession();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Iniciar nueva sesión'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: viewModel.sessions.length,
            itemBuilder: (context, index) {
              final sessionId = viewModel.sessions.keys.elementAt(index);
              final sessionMessages = viewModel.sessions[sessionId]!;

              // Get first and last message
              final firstMessage = sessionMessages.first;


              // Find the first user message
              final userMessages = sessionMessages.where((m) => m.isUser).toList();
              final titleMessage = userMessages.isNotEmpty ? userMessages.first : firstMessage;

              return Card(

                margin: const EdgeInsets.all(8),

                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),

                  ),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      titleMessage.content.length > 50
                        ? '${titleMessage.content.substring(0, 50)}...'
                        : titleMessage.content,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      '${firstMessage.timestamp.day}/${firstMessage.timestamp.month}/${firstMessage.timestamp.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () async {
                        await viewModel.continueSession(sessionId);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      tooltip: 'Continuar esta sesión',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: sessionMessages.map((message) {
                            return ListTile(
                              leading: Icon(
                                message.isUser ? Icons.person : Icons.psychology,
                                color: message.isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              ),
                              title: Text(
                                message.content,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Text(
                                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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

class _MessageList extends StatelessWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.messages.isEmpty) {
          return const Center(
            child: Text('No hay mensajes aun'),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: viewModel.messages.length,
          itemBuilder: (context, index) {
            final message = viewModel.messages[viewModel.messages.length - 1 - index];
            return FadeInUp(
              config: BaseAnimationConfig(child: _MessageBubble(message: message)));
          },
        );
      },
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

    return FadeInUp(
      config: BaseAnimationConfig(
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: isUser ? TextDirection.rtl : TextDirection.ltr,
            children: [
              if (isUser)
                Container(
                  width: MediaQuery.of(context).size.width * .15,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: userViewModel.getProfileImage(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (!isUser)
                Container(
                  width: MediaQuery.of(context).size.width * .09,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedBot,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              enabled: !viewModel.isLoading,
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(viewModel),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: viewModel.isLoading
                ? Text(
                    viewModel.typingAnimation,
                    style: const TextStyle(fontSize: 24),
                  )
                : const Icon(Icons.send_rounded),
            onPressed: viewModel.isLoading ? null : () => _sendMessage(viewModel),
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatViewModel viewModel) {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      viewModel.sendMessage(message);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }
}
