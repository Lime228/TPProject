import 'package:flutter/material.dart';
import 'register_screen.dart';





//TODO: Связать экран с заглушками api.

//TODO: Поменять png на svg и доработать первые базовые экраны входа и регистрации.






class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _borderRadius = 15.0;
  static const _shadowOffset = Offset(0, 4);
  static const _shadowBlur = 6.0;
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 15);

  // Размеры
  static const _buttonWidth = 150.0;
  static const _buttonHeight = 44.0;
  static const _inputWidth = 305.0;
  static const _inputHeight = 41.0;

  // Цвета
  static const _colorEnter = const Color.fromARGB(100, 110, 68, 255);
  static const _colorEnterButton = const Color.fromARGB(	100, 147, 125, 243);

  // Стили текста
  static const _textStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static const _enterStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    color: Colors.white
  );

  bool _obscureText = true;

  void _togglePasswordVisibility() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/logo.png', width: 150),
            const SizedBox(height: 30),
            const Text(
              "Вход",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _colorEnter,
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(hintText: 'Логин'),
            const SizedBox(height: 10),
            _buildInputField(
              hintText: 'Пароль',
              isPassword: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Не помню пароль',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: _buttonWidth,
              height: _buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorEnterButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  shadowColor: Colors.transparent,
                ),
                child: const Text("Войти", style: _enterStyle),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Ещё нет аккаунта? "),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    "Зарегистрироваться",
                    style: TextStyle(color: _colorEnterButton),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        items: const [
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
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      width: _inputWidth,
      height: _inputHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _shadowBlur,
              offset: _shadowOffset,
            ),
          ],
        ),
        child: TextField(
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: _textStyle,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              borderSide: BorderSide.none,
            ),
            contentPadding: _contentPadding,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}