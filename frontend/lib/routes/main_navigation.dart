import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '/screens/calendar_screen.dart';
import '/screens/login_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/shop_screen.dart';
import '/screens/tasks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1;
  int _previousIndex = 1;

  List<Widget> _getScreens(BuildContext context) {
    final isAuthorized = Provider.of<AuthProvider>(context).isAuthorized;
    if (isAuthorized) {
      return [
        const CalendarScreen(key: PageStorageKey('calendar_screen')),
        const ShopScreen(key: PageStorageKey('shop_screen')),
        const TasksScreen(key: PageStorageKey('tasks_screen')),
        const SettingsScreen(key: PageStorageKey('settings_screen')),
      ];
    } else {
      return [
        const CalendarScreen(key: PageStorageKey('calendar_screen')),
        const LoginScreen(key: PageStorageKey('login_screen')),
        const SettingsScreen(key: PageStorageKey('settings_screen')),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(bool isAuthorized) {
    return isAuthorized
        ? const [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Календарь',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Магазин',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.task_alt),
        label: 'Задачи',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Настройки',
      ),
    ]
        : const [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Календарь',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.login),
        label: 'Вход',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Настройки',
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthorized = authProvider.isAuthorized;
    final screens = _getScreens(context);
    final navItems = _getNavItems(isAuthorized);

    final adjustedIndex = isAuthorized ? _selectedIndex :
    _selectedIndex >= navItems.length ? navItems.length - 1 : _selectedIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: adjustedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: adjustedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}