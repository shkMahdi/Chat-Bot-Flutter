import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('hh:mm a').format(time);

    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) const CircleAvatar(child: Icon(Icons.smart_toy)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(text,
                  style: const TextStyle(color: Colors.white)),
            ),
            Text(formatted, style: const TextStyle(fontSize: 10))
          ],
        ),
        const SizedBox(width: 6),
        if (isUser) const CircleAvatar(child: Icon(Icons.person)),
      ],
    );
  }
}
