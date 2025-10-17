import 'package:flutter/material.dart';
import '../data/auth_user.dart';
import 'app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  final AppState state;
  const AuthGate({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: state.user,
      builder: (_, u, __) {
        if (u == null) {
          return LoginScreen(state: state);
        }
        return HomeScreen(state: state);
      },
    );
  }
}
