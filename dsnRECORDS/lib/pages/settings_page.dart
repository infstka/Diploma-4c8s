import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки вашего приложения',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Добавьте здесь виджеты для настроек, например:
            ListTile(
              title: Text('Тема приложения'),
              subtitle: Text('Выберите светлую или темную тему'),
              onTap: () {
                // Реализуйте логику изменения темы
              },
            ),
            Divider(),
            ListTile(
              title: Text('Язык приложения'),
              subtitle: Text('Выберите предпочитаемый язык'),
              onTap: () {
                // Реализуйте логику изменения языка
              },
            ),
            // Добавьте другие виджеты настроек по необходимости
          ],
        ),
      ),
    );
  }
}
