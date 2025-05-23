import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import 'package:zadachok/routes/main_navigation.dart';
import 'package:zadachok/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const RegisterScreen({
    Key? key,
    required this.apiClient,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  static const double borderRadius = 15.0;
  static const Offset shadowOffset = Offset(0, 4);
  static const double shadowBlur = 6.0;
  static const EdgeInsets contentPadding =
  EdgeInsets.symmetric(horizontal: 20, vertical: 15);
  static const double buttonWidth = 200.0;
  static const double buttonHeight = 44.0;
  static const double inputWidth = 305.0;
  static const double inputHeight = 41.0;
  static const Color colorEnter = Color.fromARGB(100, 110, 68, 255);
  static const Color colorEnterButton = Color(0xFF937DF3);


  static const TextStyle textStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle enterStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() => setState(() => _obscureText = !_obscureText);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.apiClient.register(
        UserModel(
          password: _passwordController.text,
          email: _emailController.text,
          name: '',
          login: _usernameController.text,
          birthdayDate: DateTime.parse('1990-01-01'),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Успешная регистрация! ID: ${user.id}'),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {
      String errorMessage = 'Ошибка регистрации';
      if (e.toString().contains('email') || e.toString().contains('почт')) {
        errorMessage = 'Некорректный email';
      } else if (e.toString().contains('парол')) {
        errorMessage = 'Пароль должен содержать минимум 6 символов';
      } else if (e.toString().contains('поля')) {
        errorMessage = 'Заполните все поля';
      }

      if (mounted) {
        setState(() => _errorMessage = errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset('lib/assets/logo.png', width: 150),
                  const SizedBox(height: 30),
                  const Text(
                    "Регистрация",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorEnter,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    hintText: 'Логин',
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите логин';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    hintText: 'Почта',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      if (!value.contains('@')) {
                        return 'Некорректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    hintText: 'Пароль',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      if (value.length < 6) {
                        return 'Пароль должен быть не менее 6 символов';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginPrompt(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: inputWidth,
      height: inputHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textStyle,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              borderSide: BorderSide.none,
            ),
            contentPadding: contentPadding,
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(height: 0),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: buttonWidth,
      height: buttonHeight,
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
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorEnterButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Зарегистрироваться", style: enterStyle),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Уже есть аккаунт? "),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Войти",
            style: TextStyle(color: colorEnterButton),
          ),
        ),
      ],
    );
  }
}