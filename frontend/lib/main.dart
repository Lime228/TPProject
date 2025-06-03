import 'package:appmetrica_plugin/appmetrica_plugin.dart';
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
import 'package:zadachok/services/notification_service.dart';
import 'package:zadachok/services/connectivity_service.dart';
import 'package:zadachok/services/local_storage_service.dart';
import 'package:zadachok/services/local_state_service.dart';

import 'api/endpoints_config_parse.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final prefs = await SharedPreferences.getInstance();
  await EndpointsConfigParse.load();

  final notificationService = NotificationService();
  await notificationService.init();

  // Инициализация сервисов
  final connectivityService = ConnectivityService();
  final localStorageService = LocalStorageService();
  final localStateService = LocalStateService();
  
  await localStorageService.init();
  await localStateService.init();

  await AppMetrica.activate(
    const AppMetricaConfig(
      '2781a5e7-fcdf-4212-a9dc-f0985ae15f9a',
      logs: true,
    ),
  );

  // Создаём провайдеры с новым localStateService
  final groupProvider = GroupProvider(
    authProvider: null,
    localState: localStateService,
  );
  
  final authProvider = AuthProvider(
    groupProvider: groupProvider,
    localState: localStateService,
  );
  
  await authProvider.checkAuth();

  if (authProvider.isAuthorized && authProvider.token != null) {
    notificationService.setAuthToken(authProvider.token);
  }

  groupProvider.setAuthProvider(authProvider);

  final shopProvider = ShopProvider(authProvider: authProvider, prefs: prefs);
  final taskProvider = TaskProvider(
    authProvider: authProvider,
    localStorage: localStorageService,
    connectivity: connectivityService,
  );

  if (authProvider.isAuthorized) {
    await groupProvider.loadGroupData();
    if (groupProvider.isInGroup) {
      await groupProvider.refreshGroupData();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => groupProvider),
        ChangeNotifierProvider(create: (_) => taskProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => shopProvider),
        Provider.value(value: connectivityService),
        Provider.value(value: localStorageService),
        Provider.value(value: localStateService),
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