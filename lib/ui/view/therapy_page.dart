import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/chat_message.dart';
import 'package:re_mind/viewmodels/chat_view_model.dart';

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text('Terapia',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.start,
        ),
        backgroundColor: Colors.transparent,
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Theme.of(context).primaryColor,
        ) ,
        actions: [
          IconButton(
            onPressed: () {},
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
            onPressed: viewModel.isLoading ? null : (){
              
              _sendMessage(viewModel);
              
            },
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