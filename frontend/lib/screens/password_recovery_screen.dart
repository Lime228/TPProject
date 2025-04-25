import 'package:flutter/material.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/api/mock_api_client.dart';
import '../api/api_client.dart';
import '../routes/main_navigation.dart';
import 'login_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const PasswordRecoveryScreen({
    Key? key,
    this.apiClient = const MockApiClient(),
  }) : super(key: key);

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  // Константы дизайна
  static const double BORDER_RADIUS = 15.0;
  static const Offset SHADOW_OFFSET = Offset(0, 4);
  static const double SHADOW_BLUR = 6.0;
  static const EdgeInsets CONTENT_PADDING =
  EdgeInsets.symmetric(horizontal: 20, vertical: 15);
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
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.apiClient.recoverPassword(
        email: _emailController.text,
        login: _loginController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новый пароль отправлен на вашу почту')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(apiClient: ApiClient()),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите логин';
    }
    if (value.length < 4) {
      return 'Логин должен содержать минимум 4 символа';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/logo.png', width: 150),
              const SizedBox(height: 30),
              const Text(
                "Восстановление пароля",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: COLOR_ENTER,
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                hintText: 'Логин',
                controller: _loginController,
                validator: _validateLogin,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                hintText: 'Почта',
                controller: _emailController,
                validator: _validateEmail,
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
              _buildActionButton(),
              const SizedBox(height: 20),
              _buildBackToLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: INPUT_WIDTH,
      height: INPUT_HEIGHT,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
          boxShadow: const [BoxShadow(
            color: Colors.black26,
            blurRadius: SHADOW_BLUR,
            offset: SHADOW_OFFSET,
          )],
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
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
            errorStyle: const TextStyle(height: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: BUTTON_WIDTH,
      height: BUTTON_HEIGHT,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 4),
        )],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _recoverPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: COLOR_ENTER_BUTTON,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Сменить пароль", style: ENTER_STYLE),
      ),
    );
  }

  Widget _buildBackToLoginPrompt() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Text(
        "Вернуться к входу",
        style: TextStyle(color: COLOR_ENTER_BUTTON),
      ),
    );
  }
}