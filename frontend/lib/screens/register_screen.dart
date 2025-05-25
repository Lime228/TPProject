import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zadachok/api/api_client.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import 'package:zadachok/routes/main_navigation.dart';

const TextStyle _textStyleSemiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600, // SemiBold
);

const TextStyle _textStyleBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700, // Bold
);

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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  // Адаптивные размеры
  double get borderRadius => MediaQuery.of(context).size.width * 0.035;
  double get buttonWidth => MediaQuery.of(context).size.width * 0.6;
  double get buttonHeight => MediaQuery.of(context).size.height * 0.06;
  double get inputWidth => MediaQuery.of(context).size.width * 0.8;
  double get inputHeight => MediaQuery.of(context).size.height * 0.06;
  static const colorEnter = Color.fromARGB(100, 110, 68, 255);
  static const colorEnterButton = Color(0xFF937DF3);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() => setState(() => _obscureText = !_obscureText);

  Future<void> _register() async {
    final apiClient = ApiClient();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    widget.apiClient.register(UserModel(
      password: _passwordController.text,
      email: _emailController.text,
      name: _usernameController.text,
      login: _usernameController.text,
      birthdayDate: DateTime.tryParse('1990-01-01')
    ));

    try {
      await apiClient.register(
        UserModel(
          password: _passwordController.text,
          email: _emailController.text,
          name: '',
          login: _usernameController.text,

        ),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {

      if (e.toString().contains('email') || e.toString().contains('почт')) {
        return;
      } else if (e.toString().contains('парол')) {
        return;
      } else if (e.toString().contains('поля')) {
        return;
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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
          ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  SvgPicture.asset(
                    'lib/assets/logo.svg',
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Text(
                    "Регистрация",
                    style: _textStyleBold.copyWith(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      color: colorEnter,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  _buildInputField(
                    hintText: 'Почта',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Некорректный email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
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
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
                      child: Text(
                        _errorMessage!,
                        style: _textStyleBold.copyWith(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  _buildRegisterButton(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  _buildLoginPrompt(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(height: 0),
            hintStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
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
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorEnterButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? SizedBox(
          width: MediaQuery.of(context).size.width * 0.06,
          height: MediaQuery.of(context).size.width * 0.06,
          child: const CircularProgressIndicator(color: Colors.white),
        )
            : Text(
          "Зарегистрироваться",
          style: _textStyleBold.copyWith(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Уже есть аккаунт? ",
          style: _textStyleSemiBold.copyWith(
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Войти",
            style: _textStyleSemiBold.copyWith(
              color: colorEnterButton,
              fontSize: MediaQuery.of(context).size.width * 0.035,
            ),
          ),
        ),
      ],
    );
  }
}