// lib/app/auth_gate.dart
import 'package:flutter/material.dart';
import '../data/auth_user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import 'app_scope.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;

    return ValueListenableBuilder<AuthUser?>(
      valueListenable: state.user,
      builder: (_, u, __) {
        if (u == null) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
