import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/api/api_client.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import 'package:zadachok/screens/splash_screen.dart';

import 'api/endpoints_config_parse.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final prefs = await SharedPreferences.getInstance();
  await EndpointsConfigParse.load();

  final apiClient = ApiClient();

  // Загружаем начальные данные
  final authProvider = AuthProvider(groupProvider: GroupProvider(authProvider: null));
  await authProvider.checkAuth();

  if (authProvider.isAuthorized) {
    final groupProvider = GroupProvider(authProvider: authProvider);
    await groupProvider.loadGroupData();
    if (groupProvider.isInGroup) {
      await groupProvider.refreshGroupData();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProxyProvider<AuthProvider, GroupProvider>(
          create: (context) => GroupProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, groupProvider) =>
          groupProvider ?? GroupProvider(authProvider: authProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(authProvider: authProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(
            prefs: prefs, authProvider: authProvider, 
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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