import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/api/mock_api_client.dart'; // Импортируем MockApiClient
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import 'package:zadachok/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final prefs = await SharedPreferences.getInstance();

  // Создаем экземпляр MockApiClient один раз
  final mockApiClient = MockApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProxyProvider<GroupProvider, AuthProvider>(
          create: (context) => AuthProvider(
            groupProvider: Provider.of<GroupProvider>(context, listen: false),
          ),
          update: (context, groupProvider, authProvider) =>
          authProvider ?? AuthProvider(groupProvider: groupProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(apiClient: mockApiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        // Исправленная строка - передаем mockApiClient
        ChangeNotifierProvider(
          create: (_) => ShopProvider(
            apiClient: mockApiClient,
            prefs: prefs,
          ),
        ),
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
      home: const SplashScreen(),
    );
  }
}