import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../app/app_colors.dart';
import '../widgets/settings_header.dart';

class SettingsPage extends StatelessWidget {
  final AppState state;
  const SettingsPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      children: [
        const SettingsHeader(),
        ValueListenableBuilder<bool>(
          valueListenable: state.themeDark,
          builder: (_, val, __) => Card(
            child: SwitchListTile(
              value: val,
              onChanged: (v) => state.setDark(v),
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
            subtitle: ValueListenableBuilder<int>(
              valueListenable: state.counter,
              builder: (_, v, __) => Text('Сейчас: $v'),
            ),
            trailing: Wrap(
              spacing: 6,
              children: [
                IconButton(
                  tooltip: 'Уменьшить',
                  onPressed: state.decCounter,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  tooltip: 'Увеличить',
                  onPressed: state.incCounter,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                ElevatedButton(
                  onPressed: state.resetCounter,
                  child: const Text('Сброс'),
                ),
              ],
            ),
          ),
        ),
        // === новый блок: выход из аккаунта ===
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.primary),
            title: const Text('Выйти из аккаунта'),
            subtitle: const Text('Завершить текущую сессию'),
            trailing: ElevatedButton(
              onPressed: state.logout,
              child: const Text('Выйти'),
            ),
          ),
        ),
      ],
    );
  }
}
