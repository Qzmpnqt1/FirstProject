import 'package:flutter/material.dart';
import '../../app/app_state.dart';

class RegisterScreen extends StatefulWidget {
  final AppState state;
  const RegisterScreen({super.key, required this.state});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final repeat = TextEditingController();
  bool loading = false;

  Future<void> _register() async {
    final em = email.text.trim();
    final pw = password.text;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(em)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректный email')));
      return;
    }
    if (pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароль от 6 символов')));
      return;
    }
    if (pw != repeat.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароли не совпадают')));
      return;
    }
    setState(() => loading = true);
    final ok = await widget.state.register(fullName.text.trim(), em, pw);
    setState(() => loading = false);
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Регистрация выполнена, войдите')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Этот email уже зарегистрирован')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: repeat,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Повтор пароля', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: loading ? null : _register, child: Text(loading ? 'Создаём...' : 'Создать аккаунт')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
