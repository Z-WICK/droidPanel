import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/screens/home_screen.dart';
import 'package:droid_config_panel/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: DroidConfigPanelApp()));
}

class DroidConfigPanelApp extends StatelessWidget {
  const DroidConfigPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droid Config Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
