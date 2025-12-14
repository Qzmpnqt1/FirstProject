import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/auth_gate.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';
import '../widgets/settings_header.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки и сервис')),
      body: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.user != current.user,
        listener: (context, state) {
          if (state.user == null) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGate()),
              (_) => false,
            );
          }
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            children: [
          const SettingsHeader(),
          BlocSelector<AppCubit, AppState, bool>(
            selector: (state) => state.settings.themeDark,
            builder: (_, isDark) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                value: isDark,
                onChanged: (value) => context.read<AppCubit>().setDark(value),
                title: const Text('Тёмная тема', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Переключение ThemeMode для всего приложения'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.dark_mode_rounded, color: AppColors.primary, size: 20),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_rounded, color: AppColors.primary),
              title: const Text('Текущее значение счётчика'),
              subtitle: BlocSelector<AppCubit, AppState, int>(
                selector: (state) => state.settings.counter,
                builder: (_, value) => Text('Сейчас: $value'),
              ),
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    tooltip: 'Уменьшить',
                    onPressed: () => context.read<AppCubit>().decCounter(),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Увеличить',
                    onPressed: () => context.read<AppCubit>().incCounter(),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<AppCubit>().resetCounter(),
                    child: const Text('Сброс'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              value: context.select((AppCubit cubit) => cubit.state.settings.notifications),
              onChanged: (value) => context.read<AppCubit>().setNotifications(value),
              title: const Text('Уведомления', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Учебные напоминания и алерты'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              value: context.select((AppCubit cubit) => cubit.state.settings.analytics),
              onChanged: (value) => context.read<AppCubit>().setAnalytics(value),
              title: const Text('Аналитика', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Собирать обезличенную статистику'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              title: const Text('О приложении'),
              subtitle: const Text('Описание практической работы и пасхалка'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
          ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.primary),
                title: const Text('Выйти из аккаунта'),
                subtitle: const Text('Завершить текущую сессию'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await context.read<AppCubit>().logout();
                  },
                  child: const Text('Выйти'),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
