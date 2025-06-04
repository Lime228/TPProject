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
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('first_launch') ?? true;
    });
  }

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
    'lib/assets/onboarding/dobro.png', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/tasks.png', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/tasks_manage.png', // Заглушка - замените на реальное изображение
    'lib/assets/onboarding/shop.png',
    'lib/assets/onboarding/products.png',
    'lib/assets/onboarding/profile.png',
    'lib/assets/onboarding/goodbye.png',
  ];

  final List<String> _onboardingTitles = [
    'Добро пожаловать!',
    'Задачи',
    'Управление задачами',
    'Магазин',
    'Товары',
    'Профиль',
    'Приятного пользования!'
  ];

  // Описания для каждого экрана
  final List<String> _onboardingDescriptions = [
    'После первой авторизации, вы сможете создать группу или присоединиться к уже существующей по коду группы',
    'Задачи бывают невыполненные, выполненные (оранжевые), подтвержденные (зеленые) и просроченные (красные). Выполнить или подтвердить задачу можно нажав на кружок слева от карточки задачи.',
    'Через кнопку справа снизу на экране задач можно добавить задачу. Нажав на карточку задачи можно посмотреть информацию о ней, или же отредактировать.',
    'После подтверждения администратором задач, участнику начисляются "звездочки", которые можно потратить в магазине. Баланс звёздочек отображается справа сверху. Наполнение магазина а так же цену предметов выставляет администратор.',
    'Редактировать товары администратор может через меню справа сверху на экране "Магазин". Нажав на товар можно посмотреть информацию о нем, а так же участники группы могут купить товар, если им позволяет баланс.',
    'Во вкладке "Настройки" вы можете посмотреть свою статистику, а так же поменять личные данные',
    ' ',
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
    if (!_isFirstLaunch) {
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('В первый раз пропустить ЧаВо нельзя!'),
            backgroundColor: const Color(0xFF937DF3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),)
      );
    }
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: Colors.black,
                              width: MediaQuery.of(context).size.height * 0.001,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(borderRadius),
                            child: Image.asset(
                              _onboardingImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Text(
                          _onboardingTitles[index],
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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