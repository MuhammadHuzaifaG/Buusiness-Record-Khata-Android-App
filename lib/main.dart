import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'services/local_db_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Hive Database & Local Notifications
  await LocalDbService.init();
  await NotificationService.init();

  runApp(const DigitalKhataApp());
}

class DigitalKhataApp extends StatelessWidget {
  const DigitalKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initializeApp(),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: provider.isUrdu ? 'ڈیجیٹل کھاتہ' : 'Digital Khata',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(provider.isUrdu),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}