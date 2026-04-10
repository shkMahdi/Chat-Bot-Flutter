import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';

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
