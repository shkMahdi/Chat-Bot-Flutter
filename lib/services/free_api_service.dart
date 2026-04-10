import 'dart:convert';
import 'package:http/http.dart' as http;

class FreeApiService {
  Future<String> getResponse() async {
    final res =
    await http.get(Uri.parse("https://api.quotable.io/random"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['content'];
    } else {
      throw Exception("Free API error");
    }
  }
}
