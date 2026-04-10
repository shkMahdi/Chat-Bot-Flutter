import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../services/free_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final OpenAIService openAI = OpenAIService();
  final FreeApiService freeApi = FreeApiService();

  bool useOpenAI = true;

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  Future<void> sendMessage(String msg) async {
    messages.add({
      "role": "user",
      "text": msg,
      "time": DateTime.now(),
    });

    isTyping = true;
    notifyListeners();

    try {
      String reply;

      if (useOpenAI) {
        reply = await openAI.sendMessage(msg);
      } else {
        reply = await freeApi.getResponse(msg);
      }

      messages.add({
        "role": "bot",
        "text": reply,
        "time": DateTime.now(),
      });
    } catch (e) {
      messages.add({
        "role": "bot",
        "text": "⚠️ ${e.toString()}",
        "time": DateTime.now(),
      });
    }

    isTyping = false;
    notifyListeners();
  }

  void toggleApi(bool val) {
    useOpenAI = val;
    notifyListeners();
  }
}
