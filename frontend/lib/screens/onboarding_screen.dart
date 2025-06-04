import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/main_navigation.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  // Поместите изображения в папку lib/assets/onboarding/
  // и укажите правильные пути (например: 'lib/assets/onboarding/slide1.png')
  final List<String> _onboardingImages = [
    'lib/assets/onboarding/1.jpg', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/2.jpg', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/3.jpg', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/4.jpg',
    'lib/assets/onboarding/5.jpg',
    'lib/assets/onboarding/6.jpg',
    'lib/assets/onboarding/7.jpg',
    'lib/assets/onboarding/8.jpg',
    'lib/assets/onboarding/9.jpg',
    'lib/assets/onboarding/10.jpg',
  ];

  final List<String> _onboardingTitles = [
    'Добро пожаловать!',
    'Управление задачами',
    'Командная работа',
    'Награды и достижения',
    'Статистика прогресса',
    'Кастомизация профиля',
    'Уведомления',
    'Безопасность данных',
    'Кроссплатформенность',
    'Начните прямо сейчас!'
  ];

  // Описания для каждого экрана
  final List<String> _onboardingDescriptions = [
    'Приложение поможет вам организовать работу и личные задачи',
    'Создавайте, редактируйте и отслеживайте выполнение задач',
    'Работайте вместе с коллегами над общими проектами',
    'Получайте награды за выполнение целей',
    'Анализируйте свою продуктивность с помощью статистики',
    'Настройте профиль под свои предпочтения',
    'Будьте в курсе важных событий и дедлайнов',
    'Ваши данные надежно защищены',
    'Доступ к задачам с любого устройства',
    'Зарегистрируйтесь и начните использовать все возможности'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipOnboarding() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = MediaQuery.of(context).size.width * 0.035;
    final shadowOffset = Offset(0, MediaQuery.of(context).size.height * 0.005);
    final shadowBlur = MediaQuery.of(context).size.width * 0.015;
    const colorEnterButton = Color(0xFF937DF3);

    final titleStyle = TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.06,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      color: colorEnterButton,
    );

    final descriptionStyle = TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.04,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Пропустить',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingImages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Изображение онбординга
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Image.asset(
                            _onboardingImages[index],
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                          _onboardingTitles[index],
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Text(
                            _onboardingDescriptions[index],
                            style: descriptionStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Индикаторы страниц
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingImages.length,
                      (index) => Container(
                    width: _currentPage == index ? 20.0 : 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: _currentPage == index
                          ? colorEnterButton
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
            // Кнопка "Далее" или "Начать"
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.05),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingImages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      _completeOnboarding();

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorEnterButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _currentPage < _onboardingImages.length - 1 ? 'Далее' : 'Начать',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}