import 'package:flutter/material.dart';
import 'app_colors.dart';

class ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const ProfileChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600))
      ]),
    );
  }
}