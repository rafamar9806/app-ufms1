import 'package:flutter/material.dart';
import 'screens/cftv_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CftvApp());
}

class CftvApp extends StatelessWidget {
  const CftvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador CFTV',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const CftvListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
