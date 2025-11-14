import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/app_colors.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Счётчик',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<int>(
                valueListenable: state.counter,
                builder: (_, v, __) => Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$v',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: state.decCounter,
                    icon: const Icon(Icons.remove_circle_rounded),
                    color: AppColors.primaryDark,
                    iconSize: 34,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: state.incCounter,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Увеличить'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: state.resetCounter,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Сброс'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
