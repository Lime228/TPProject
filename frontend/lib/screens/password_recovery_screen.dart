import 'package:flutter/material.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/api/mock_api_client.dart';
import '../routes/main_navigation.dart';
import 'login_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const PasswordRecoveryScreen({
    Key? key,
    this.apiClient = const MockApiClient(),
  }) : super(key: key);

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {

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
  static const Color colorEnterButton = Color.fromARGB(100, 147, 125, 243);


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
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _loginController.dispose();
    super.dispose();
  }

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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новый пароль отправлен на вашу почту')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  Image.asset('lib/assets/logo.png', width: 150),
                  const SizedBox(height: 30),
                  const Text(
                    "Восстановление пароля",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorEnter,
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
            )
          ],
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
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
            errorStyle: const TextStyle(height: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
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
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _recoverPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorEnterButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Сменить пароль", style: enterStyle),
      ),
    );
  }

  Widget _buildBackToLoginPrompt() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Text(
        "Вернуться к входу",
        style: TextStyle(color: colorEnterButton),
      ),
    );
  }
}