import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '/screens/calendar_screen.dart';
import '/screens/login_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/shop_screen.dart';
import '/screens/tasks_screen.dart';
import 'package:zadachok/api/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with TickerProviderStateMixin {
  static const int DEFAULT_SELECTED_INDEX = 1;
  static const Color NAV_BAR_SHADOW_COLOR = Colors.black12;
  static const double NAV_BAR_SHADOW_BLUR = 8.0;
  static const Offset NAV_BAR_SHADOW_OFFSET = Offset(0, -2);
  static const Color UNSELECTED_ITEM_COLOR = Color(0xFF937DF3);
  static const Color SELECTED_ITEM_COLOR = Color(0xFF6E44FF);
  static const double ICON_SIZE = 35.0;
  static const double ACTIVE_ICON_SIZE = 50.0;
  static const String ICON_PATH = 'lib/assets/';


  int _selectedIndex = DEFAULT_SELECTED_INDEX;

  final PageController _pageController = PageController(initialPage: DEFAULT_SELECTED_INDEX);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationController.forward();
  }

  List<Widget> _getScreens(BuildContext context) {
    final isAuthorized = Provider.of<AuthProvider>(context).isAuthorized;
    final apiClient = ApiClient();

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
        LoginScreen(
          key: const PageStorageKey('login_screen'),
          apiClient: ApiClient(),
        ),
        const SettingsScreen(key: PageStorageKey('settings_screen')),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(bool isAuthorized) {
    return isAuthorized
        ? [
      BottomNavigationBarItem(
        icon: _buildSvgIcon('calendar', false),
        activeIcon: _buildSvgIcon('calendar_active', true),
        label: 'Календарь',
      ),
      BottomNavigationBarItem(
        icon: _buildSvgIcon('shop', false),
        activeIcon: _buildSvgIcon('shop_active', true),
        label: 'Магазин',
      ),
      BottomNavigationBarItem(
        icon: _buildSvgIcon('tasks', false),
        activeIcon: _buildSvgIcon('tasks_active', true),
        label: 'Задачи',
      ),
      BottomNavigationBarItem(
        icon: _buildSvgIcon('settings', false),
        activeIcon: _buildSvgIcon('settings_active', true),
        label: 'Настройки',
      ),
    ]
        : [
      BottomNavigationBarItem(
        icon: _buildSvgIcon('calendar', false),
        activeIcon: _buildSvgIcon('calendar_active', true),
        label: 'Календарь',
      ),
      BottomNavigationBarItem(
        icon: _buildSvgIcon('login', false),
        activeIcon: _buildSvgIcon('login_active', true),
        label: 'Вход',
      ),
      BottomNavigationBarItem(
        icon: _buildSvgIcon('settings', false),
        activeIcon: _buildSvgIcon('settings_active', true),
        label: 'Настройки',
      ),
    ];
  }

  Widget _buildSvgIcon(String iconName, bool isActive) {
    return SvgPicture.asset(
      '$ICON_PATH$iconName.svg',
      width: isActive ? ACTIVE_ICON_SIZE : ICON_SIZE,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthorized = authProvider.isAuthorized;
    final screens = _getScreens(context);
    final navItems = _getNavItems(isAuthorized);

    final adjustedIndex = isAuthorized
        ? _selectedIndex
        : _selectedIndex >= navItems.length
        ? navItems.length - 1
        : _selectedIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: NAV_BAR_SHADOW_COLOR,
              blurRadius: NAV_BAR_SHADOW_BLUR,
              offset: NAV_BAR_SHADOW_OFFSET,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: adjustedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: SELECTED_ITEM_COLOR,
          unselectedItemColor: UNSELECTED_ITEM_COLOR,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}
