import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/app_state.dart';
import '../widgets/profile_chip.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool edit = false;
  late final TextEditingController nameController;
  late final TextEditingController roleController;

  static const _avatarUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4dd.png';

  @override
  void initState() {
    super.initState();
    final state = context.read<AppCubit>().state;
    nameController = TextEditingController(text: state.name);
    roleController = TextEditingController(text: state.role);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_avatarUrl), context);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<AppCubit>();
    await cubit.setName(nameController.text.trim());
    await cubit.setRole(roleController.text.trim());
    if (!mounted) return;
    setState(() => edit = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 3,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE0FBFC), Color(0xFFFDFCFB)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.accentSoft,
                backgroundImage: CachedNetworkImageProvider(_avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person_rounded, color: AppColors.textPrimary, size: 28),
              ),
              const SizedBox(height: 12),
              BlocBuilder<AppCubit, AppState>(
                buildWhen: (previous, current) =>
                    previous.name != current.name || previous.role != current.role,
                builder: (context, state) {
                  if (edit) {
                    return Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: roleController,
                          decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    edit = false;
                                    nameController.text = state.name;
                                    roleController.text = state.role;
                                  });
                                },
                                child: const Text('Отмена'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _save,
                                child: const Text('Сохранить'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Text(state.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(state.role, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => edit = true),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Редактировать'),
                      ),
                    ],
                  );
                },
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
