import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../main.dart'; // To access Theme/App info

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initially add a greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isBengali = BDLawApp.of(context).isBengali;
      setState(() {
        _messages.add(
          Message(
            text: isBengali 
              ? "নমস্কার! আমি আপনার বিডি ল অ্যাসিস্ট্যান্ট। আমি বাংলাদেশ দণ্ডবিধি এবং অন্যান্য আইন সম্পর্কে আপনাকে সাহায্য করতে পারি। আপনার কি প্রশ্ন আছে?"
              : "Hello! I am your BD Law Assistant. I can help you understand the Bangladesh Penal Code and other legal acts. What is your question?",
            isMe: false,
          ),
        );
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isBengali = BDLawApp.of(context).isBengali;

    setState(() {
      _messages.insert(0, Message(text: text, isMe: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      final res = await ApiService.askLaw(text, isBengali);
      setState(() {
        _messages.insert(0, Message(text: res['answer'] ?? 'No answer provided.', isMe: false));
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, Message(text: 'Error connecting to the server: $e', isMe: false, isError: true));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return ChatBubble(message: msg);
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: BDLawApp.of(context).isBengali ? 'আপনার প্রশ্ন লিখুন...' : 'Ask a legal question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Message {
  final String text;
  final bool isMe;
  final bool isError;

  Message({required this.text, required this.isMe, this.isError = false});
}
