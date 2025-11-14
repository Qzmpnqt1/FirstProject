import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';

import '../app/app_colors.dart';
import '../app/app_scope.dart';
import '../widgets/multi_listenable_builder.dart';
import '../widgets/profile_chip.dart';
import '../app/app_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool edit = false;

  late final TextEditingController name;
  late final TextEditingController role;

  static const _avatarUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4dd.png';

  @override
  void initState() {
    super.initState();
    final state = GetIt.I<AppState>(); // DI-способ
    name = TextEditingController(text: state.name.value);
    role = TextEditingController(text: state.role.value);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(const CachedNetworkImageProvider(_avatarUrl), context);
      } catch (_) {}
    });
  }

  Future<void> _save() async {
    final state = context.appState; // InheritedWidget-способ

    await state.setName(name.text.trim());
    await state.setRole(role.text.trim());
    setState(() => edit = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль сохранён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;

    return Center(
      child: Card(
        elevation: 3,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE0FBFC), Color(0xFFFDFCFB)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.accentSoft,
                backgroundImage: const CachedNetworkImageProvider(_avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder2<String, String>(
                listenableA: state.name,
                listenableB: state.role,
                builder: (_, n, r, __) => edit
                    ? Column(
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'ФИО',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: role,
                      decoration: const InputDecoration(
                        labelText: 'Роль',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Сохранить'),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Text(
                      n,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          setState(() => edit = true),
                      child: const Text('Редактировать'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ProfileChip(icon: Icons.code_rounded, label: 'Flutter'),
                  SizedBox(width: 10),
                  ProfileChip(icon: Icons.security_rounded, label: 'Dart'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
