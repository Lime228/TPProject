import 'package:flutter/material.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import 'package:zadachok/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const RegisterScreen({
    Key? key,
    required this.apiClient,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Константы дизайна
  static const double BORDER_RADIUS = 15.0;
  static const Offset SHADOW_OFFSET = Offset(0, 4);
  static const double SHADOW_BLUR = 6.0;
  static const EdgeInsets CONTENT_PADDING = EdgeInsets.symmetric(horizontal: 20, vertical: 15);
  static const double BUTTON_WIDTH = 200.0;
  static const double BUTTON_HEIGHT = 44.0;
  static const double INPUT_WIDTH = 305.0;
  static const double INPUT_HEIGHT = 41.0;
  static const Color COLOR_ENTER = Color.fromARGB(100, 110, 68, 255);
  static const Color COLOR_ENTER_BUTTON = Color.fromARGB(100, 147, 125, 243);

  // Стили текста
  static const TextStyle TEXT_STYLE = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle ENTER_STYLE = TextStyle(
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
          name: '', // Можно добавить поле для имени, если нужно
          login: _usernameController.text,
          birthdayDate: DateTime.parse('1990-01-01'), // Дефолтная дата
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Успешная регистрация! ID: ${user.id}'),
          duration: const Duration(seconds: 3),
        ),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(apiClient: widget.apiClient),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Ошибка регистрации';
      if (e.toString().contains('email') || e.toString().contains('почт')) {
        errorMessage = 'Некорректный email';
      } else if (e.toString().contains('парол')) {
        errorMessage = 'Пароль должен содержать минимум 6 символов';
      } else if (e.toString().contains('поля')) {
        errorMessage = 'Заполните все поля';
      }

      setState(() => _errorMessage = errorMessage);
    } finally {
      widget.apiClient.dispose();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    color: COLOR_ENTER,
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
                Container(
                  width: BUTTON_WIDTH,
                  height: BUTTON_HEIGHT,
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
                      backgroundColor: COLOR_ENTER_BUTTON,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Зарегистрироваться", style: ENTER_STYLE),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Уже есть аккаунт? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Войти",
                        style: TextStyle(color: COLOR_ENTER_BUTTON),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
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
      width: INPUT_WIDTH,
      height: INPUT_HEIGHT,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: SHADOW_BLUR,
              offset: SHADOW_OFFSET,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TEXT_STYLE,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(BORDER_RADIUS)),
              borderSide: BorderSide.none,
            ),
            contentPadding: CONTENT_PADDING,
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(height: 0),
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}