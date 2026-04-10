import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String apiKey =
  String.fromEnvironment("OPENAI_API_KEY");

  Future<String> sendMessage(String message) async {
    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": message}
        ]
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception(res.body);
    }
  }
}
