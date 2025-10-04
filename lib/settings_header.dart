import 'package:flutter/material.dart';
import 'app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFD1FAE5), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Expanded(
              child: Text('Настройки приложения',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}