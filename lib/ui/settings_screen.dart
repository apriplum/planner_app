import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;
  bool _vibrationEnabled = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? false;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Уведомления'),
          SwitchListTile(
            title: const Text('Локальные напоминания'),
            subtitle: const Text(
              'Напоминания работают без интернета',
            ),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _save('notifications_enabled', value);

              if (value) {
                await NotificationService.instance.requestPermission();
              }
            },
          ),
          SwitchListTile(
            title: const Text('Звук уведомлений'),
            subtitle: const Text('Только для критических напоминаний'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _save('sound_enabled', value);
            },
          ),
          SwitchListTile(
            title: const Text('Вибрация'),
            subtitle: const Text('Тактильный отклик при действиях'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _save('vibration_enabled', value);
            },
          ),
          const SizedBox(height: 16),
          _SectionTitle('Оформление'),
          SwitchListTile(
            title: const Text('Тёмная тема'),
            subtitle: const Text('Использовать системную тему'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              _save('dark_mode', value);
            },
          ),
          const SizedBox(height: 16),
          _SectionTitle('О приложении'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Планировщик'),
              subtitle: Text(
                'Локальный офлайн-режим.\n'
                'Данные хранятся только на устройстве.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Конфиденциальность'),
              subtitle: Text(
                'Напоминания формируются локально. '
                'Содержимое задач и привычек не передаётся внешним сервисам.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}