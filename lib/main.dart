import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUMÉ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.shell,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
