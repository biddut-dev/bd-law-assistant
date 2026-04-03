import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../screens/chat_screen.dart'; // For Message class

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isMe 
              ? theme.colorScheme.primary 
              : (message.isError ? theme.colorScheme.errorContainer : theme.colorScheme.surfaceContainer),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: isMe || message.isError
            ? Text(
                message.text,
                style: TextStyle(
                  color: isMe 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onErrorContainer,
                  fontSize: 16,
                ),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                  listBullet: TextStyle(color: theme.colorScheme.onSurface),
                  h1: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                  h2: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
