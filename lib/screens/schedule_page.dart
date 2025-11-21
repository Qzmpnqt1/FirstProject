import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_state.dart';
import '../data/study_session.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учебный план по датам'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context),
        icon: const Icon(Icons.event_available_rounded),
        label: const Text('Новая сессия'),
      ),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) => previous.sessions != current.sessions,
          builder: (_, state) {
            final sessions = [...state.sessions]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
            if (sessions.isEmpty) {
              return const Center(child: Text('Расписание пусто. Добавьте первую учебную сессию.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: sessions.length,
              itemBuilder: (_, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: session.completed,
                      onChanged: (value) => context.read<AppCubit>().toggleSession(session.id, value ?? false),
                    ),
                    title: Text(session.title),
                    subtitle: Text(
                      '${_formatDate(context, session.scheduledAt)} • ${session.moduleTitle} • ${session.durationMinutes} мин',
                    ),
                    trailing: IconButton(
                      tooltip: 'Удалить',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => context.read<AppCubit>().deleteSession(session.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final l10n = MaterialLocalizations.of(context);
    final date = l10n.formatFullDate(dateTime);
    final time = l10n.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime), alwaysUse24HourFormat: true);
    return '$date, $time';
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final title = TextEditingController();
    final module = TextEditingController();
    final duration = TextEditingController(text: '60');
    DateTime scheduledAt = DateTime.now().add(const Duration(hours: 2));

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Новая учебная сессия'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Тема занятия'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: module,
                decoration: const InputDecoration(labelText: 'Модуль/дисциплина'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Длительность, мин'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Дата и время'),
                subtitle: Text(_formatDate(context, scheduledAt)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month_rounded),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: scheduledAt,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate == null) return;
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (pickedTime == null) {
                      setState(() => scheduledAt = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            scheduledAt.hour,
                            scheduledAt.minute,
                          ));
                      return;
                    }
                    setState(() {
                      scheduledAt = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                final titleText = title.text.trim();
                final moduleText = module.text.trim().isEmpty ? 'Без модуля' : module.text.trim();
                final durationValue = int.tryParse(duration.text.trim()) ?? 0;
                if (titleText.isEmpty || durationValue <= 0) return;
                await context.read<AppCubit>().addSession(titleText, moduleText, scheduledAt, durationValue);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

