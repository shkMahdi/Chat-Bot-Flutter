import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FreeApiService {
  String get apiKey => dotenv.env['MISTRAL_API_KEY'] ?? "";

  Future<String> getResponse(String message) async {
    final res = await http.post(
      Uri.parse("https://api.mistral.ai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "open-mistral-7b",
        "messages": [
          {"role": "user", "content": message}
        ]
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["choices"][0]["message"]["content"];
    } else {
      try {
        final quoteRes = await http.get(Uri.parse("https://api.quotable.io/random"));
        if (quoteRes.statusCode == 200) {
          final data = jsonDecode(quoteRes.body);
          return "Mistral Error (${res.statusCode}): ${data['content']} (Fallback Quote)";
        }
      } catch (_) {}
      throw Exception("Mistral API error: ${res.body}");
    }
  }
}
