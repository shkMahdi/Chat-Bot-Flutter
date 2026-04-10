import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

////////////////////////////////////////////////////////////
/// THEME PROVIDER
////////////////////////////////////////////////////////////
class ThemeProvider extends ChangeNotifier {
  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

////////////////////////////////////////////////////////////
/// AUTH PROVIDER
////////////////////////////////////////////////////////////
class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('login') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
    isLoggedIn = false;
    notifyListeners();
  }
}

////////////////////////////////////////////////////////////
/// OPENAI SERVICE (ENV BASED)
////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////
/// FREE API SERVICE
////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////
/// CHAT PROVIDER
////////////////////////////////////////////////////////////
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
        reply = await freeApi.getResponse();
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

////////////////////////////////////////////////////////////
/// MAIN APP
////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode:
            theme.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const Root(),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ROOT
////////////////////////////////////////////////////////////
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) =>
      auth.isLoggedIn ? const ChatScreen() : const LoginScreen(),
    );
  }
}

////////////////////////////////////////////////////////////
/// LOGIN SCREEN
////////////////////////////////////////////////////////////
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final pass = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: pass,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().login();
              },
              child: const Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CHAT SCREEN
////////////////////////////////////////////////////////////
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
                if (provider.messages.isEmpty) {
                  return Center(
                    child: Lottie.network(
                      "https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json",
                      width: 200,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.messages.length,
                  itemBuilder: (_, i) {
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
          Consumer<ChatProvider>(
            builder: (_, provider, __) => provider.isTyping
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Typing..."),
            )
                : const SizedBox(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context
                        .read<ChatProvider>()
                        .sendMessage(controller.text);
                    controller.clear();
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// MESSAGE BUBBLE
////////////////////////////////////////////////////////////
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