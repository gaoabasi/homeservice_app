import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HomeHelpApp());
}

class HomeHelpApp extends StatelessWidget {
  const HomeHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOMEHELP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
