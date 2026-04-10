import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat"),
        actions: [
          Switch(
            value: context.watch<ChatProvider>().useOpenAI,
            onChanged: (val) {
              context.read<ChatProvider>().toggleApi(val);
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) {
                if (provider.messages.isEmpty && !provider.isTyping) {
                  return Center(
                    child: Lottie.network(
                      "https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json",
                      width: 200,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == provider.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const CircleAvatar(child: Icon(Icons.smart_toy, size: 18)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Typing...",
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final msg = provider.messages[i];
                    return MessageBubble(
                      text: msg['text'],
                      isUser: msg['role'] == 'user',
                      time: msg['time'],
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      context
                          .read<ChatProvider>()
                          .sendMessage(controller.text.trim());
                      controller.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
