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
  late final TextEditingController groupController;
  late final TextEditingController goalController;
  late final TextEditingController contactsController;

  static const _avatarUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4dd.png';

  @override
  void initState() {
    super.initState();
    final state = context.read<AppCubit>().state;
    nameController = TextEditingController(text: state.name);
    roleController = TextEditingController(text: state.role);
    groupController = TextEditingController(text: state.group);
    goalController = TextEditingController(text: state.goal);
    contactsController = TextEditingController(text: state.contacts);
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
    groupController.dispose();
    goalController.dispose();
    contactsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<AppCubit>();
    await cubit.setName(nameController.text.trim());
    await cubit.setRole(roleController.text.trim());
    await cubit.setGroup(groupController.text.trim());
    await cubit.setGoal(goalController.text.trim());
    await cubit.setContacts(contactsController.text.trim());
    if (!mounted) return;
    setState(() => edit = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль участника')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE0FBFC), Color(0xFFFDFCFB)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (previous, current) =>
                      previous.name != current.name ||
                      previous.role != current.role ||
                      previous.group != current.group ||
                      previous.goal != current.goal ||
                      previous.contacts != current.contacts,
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: AppColors.accentSoft,
                              backgroundImage: CachedNetworkImageProvider(_avatarUrl),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person_rounded, color: AppColors.textPrimary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.name, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text(state.role, style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(edit ? Icons.close_rounded : Icons.edit_rounded),
                              tooltip: edit ? 'Отменить' : 'Редактировать',
                              onPressed: () {
                                setState(() {
                                  edit = !edit;
                                  if (!edit) {
                                    nameController.text = state.name;
                                    roleController.text = state.role;
                                    groupController.text = state.group;
                                    goalController.text = state.goal;
                                    contactsController.text = state.contacts;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (edit)
                          Column(
                            children: [
                              _ProfileInput(controller: nameController, label: 'ФИО'),
                              const SizedBox(height: 10),
                              _ProfileInput(controller: roleController, label: 'Роль'),
                              const SizedBox(height: 10),
                              _ProfileInput(controller: groupController, label: 'Учебная группа'),
                              const SizedBox(height: 10),
                              _ProfileInput(controller: goalController, label: 'Цель обучения'),
                              const SizedBox(height: 10),
                              _ProfileInput(controller: contactsController, label: 'Контакты'),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          edit = false;
                                          nameController.text = state.name;
                                          roleController.text = state.role;
                                          groupController.text = state.group;
                                          goalController.text = state.goal;
                                          contactsController.text = state.contacts;
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
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoTile(icon: Icons.group_rounded, title: 'Учебная группа', value: state.group),
                              _InfoTile(
                                  icon: Icons.flag_rounded, title: 'Цель обучения', value: state.goal),
                              _InfoTile(
                                  icon: Icons.phone_rounded, title: 'Контакты', value: state.contacts),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            ProfileChip(icon: Icons.code_rounded, label: 'Flutter'),
                            SizedBox(width: 10),
                            ProfileChip(icon: Icons.security_rounded, label: 'Dart'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _ProfileInput({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
