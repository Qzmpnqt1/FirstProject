import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/app_state.dart';
import '../app/auth_gate.dart';
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
            selector: (state) => state.themeDark,
            builder: (_, isDark) => Card(
              child: SwitchListTile(
                value: isDark,
                onChanged: (value) => context.read<AppCubit>().setDark(value),
                title: const Text('Тёмная тема'),
                subtitle: const Text('Переключение ThemeMode для всего приложения'),
                secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_rounded, color: AppColors.primary),
              title: const Text('Текущее значение счётчика'),
              subtitle: BlocSelector<AppCubit, AppState, int>(
                selector: (state) => state.counter,
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
            child: SwitchListTile(
              value: context.select((AppCubit cubit) => cubit.state.notifications),
              onChanged: (value) => context.read<AppCubit>().setNotifications(value),
              title: const Text('Уведомления'),
              subtitle: const Text('Учебные напоминания и алерты'),
              secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: context.select((AppCubit cubit) => cubit.state.analytics),
              onChanged: (value) => context.read<AppCubit>().setAnalytics(value),
              title: const Text('Аналитика'),
              subtitle: const Text('Собирать обезличенную статистику'),
              secondary: const Icon(Icons.analytics_rounded, color: AppColors.primary),
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
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthGate()),
                      (_) => false,
                    );
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
