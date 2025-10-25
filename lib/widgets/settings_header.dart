import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/app_colors.dart';

class SettingsHeader extends StatefulWidget {
  const SettingsHeader({super.key});

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  // Плоская иконка «уровни/слайдеры»
  static const _settingsUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f39a.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_settingsUrl), context);
      } catch (_) {}
    });
  }

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
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          const Expanded(
              child: Text('Настройки приложения',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: CachedNetworkImage(
                imageUrl: _settingsUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(color: Color(0xFFE2E8F0)),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFFEE2E2),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_rounded, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
