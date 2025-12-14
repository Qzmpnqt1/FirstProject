import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_colors.dart';
import '../../presentation/bloc/app_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final repeat = TextEditingController();
  final group = TextEditingController();
  final goal = TextEditingController();
  final contacts = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  bool _obscureRepeat = true;

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
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => loading = true);
    final ok = await context.read<AppCubit>().register(
          fullName.text.trim(),
          email.text.trim(),
          password.text,
          group: group.text.trim(),
          goal: goal.text.trim(),
          contacts: contacts.text.trim(),
        );
    if (!mounted) return;
    setState(() => loading = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Регистрация выполнена, войдите'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Этот email уже зарегистрирован'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Некорректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  String? _validateRepeat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Повторите пароль';
    }
    if (value != password.text) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Создать аккаунт',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: fullName,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'ФИО',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: (v) => _validateRequired(v, 'ФИО'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: password,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: repeat,
                            obscureText: _obscureRepeat,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Повтор пароля',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureRepeat ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() => _obscureRepeat = !_obscureRepeat),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: _validateRepeat,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: group,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Учебная группа',
                              prefixIcon: const Icon(Icons.group_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: (v) => _validateRequired(v, 'группу'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: goal,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Цель обучения',
                              prefixIcon: const Icon(Icons.flag_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: (v) => _validateRequired(v, 'цель'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: contacts,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Контакты',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            validator: (v) => _validateRequired(v, 'контакты'),
                            onFieldSubmitted: (_) => _register(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Создать аккаунт', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
