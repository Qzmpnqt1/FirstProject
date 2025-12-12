import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/app_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final repeat = TextEditingController();
  final group = TextEditingController();
  final goal = TextEditingController();
  final contacts = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    password.dispose();
    repeat.dispose();
    group.dispose();
    goal.dispose();
    contacts.dispose();
    super.dispose();
  }

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
    if (group.text.trim().isEmpty || goal.text.trim().isEmpty || contacts.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Заполните группу, цель и контакты')));
      return;
    }
    setState(() => loading = true);
    final ok = await context.read<AppCubit>().register(
          fullName.text.trim(),
          em,
          pw,
          group: group.text.trim(),
          goal: goal.text.trim(),
          contacts: contacts.text.trim(),
        );
    if (!mounted) return;
    setState(() => loading = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Регистрация выполнена, войдите')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Этот email уже зарегистрирован')));
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
                    decoration:
                        const InputDecoration(labelText: 'Повтор пароля', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: group,
                    decoration:
                        const InputDecoration(labelText: 'Учебная группа', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: goal,
                    decoration:
                        const InputDecoration(labelText: 'Цель обучения', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contacts,
                    decoration:
                        const InputDecoration(labelText: 'Контакты', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loading ? null : _register,
                    child: Text(loading ? 'Создаём...' : 'Создать аккаунт'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
