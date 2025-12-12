import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.user != current.user,
      builder: (context, state) {
        if (state.user == null) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
