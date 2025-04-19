import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/api/api_client.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import 'package:zadachok/screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Обязательная инициализация
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации для дат
  await initializeDateFormatting('ru');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(apiClient: ApiClient())),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru'),
      debugShowCheckedModeBanner: false,
      title: 'Zok!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],

      home: const SplashScreen(), // Начальный экран
    );
  }
}