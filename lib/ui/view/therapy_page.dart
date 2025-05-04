import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/chat_message.dart';
import 'package:re_mind/repositories/chat_messages_repository.dart';
import 'package:re_mind/viewmodels/chat_view_model.dart';

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

class _TherapyMainPage extends StatelessWidget {
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
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Theme.of(context).primaryColor,
        ),
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
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: _MessageList()),
            const _MessageInput(),
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
        title: const Text('Historial de sesiones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final viewModel = context.read<ChatViewModel>();
              await viewModel.startNewSession();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Start New Chat',
          ),
        ],
      ),
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
              final lastMessage = sessionMessages.last;
              
              // Find the first user message
              final userMessages = sessionMessages.where((m) => m.isUser).toList();
              final titleMessage = userMessages.isNotEmpty ? userMessages.first : firstMessage;
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
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
            return _MessageBubble(message: message);
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

    return FadeInUp(
      config: BaseAnimationConfig(
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
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
        )
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
            color: Colors.black.withOpacity(0.1),
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