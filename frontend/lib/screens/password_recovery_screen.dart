import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import '../routes/main_navigation.dart';
import 'login_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const PasswordRecoveryScreen({
    Key? key,
    required this.apiClient,
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

  Future<void> _showResetPasswordDialog() async {
    final _dialogFormKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool _isDialogLoading = false;
          String? _dialogErrorMessage;

          return AlertDialog(
            title: const Text('Сброс пароля'),
            content: SingleChildScrollView(
              child: Form(
                key: _dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Код отправлен на ${_emailController.text}'),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Код подтверждения',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Введите код' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Новый пароль',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Минимум 6 символов'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Подтвердите пароль',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value != newPasswordController.text
                          ? 'Пароли не совпадают'
                          : null,
                    ),
                    if (_dialogErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _dialogErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isDialogLoading
                    ? null
                    : () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _isDialogLoading
                    ? null
                    : () async {
                  if (!_dialogFormKey.currentState!.validate()) return;

                  setState(() {
                    _isDialogLoading = true;
                    _dialogErrorMessage = null;
                  });

                  try {
                    final user = UserModel(
                      login: _loginController.text,
                      email: _emailController.text, name: '',
                    );

                    final success = await widget.apiClient.resetPassword(
                      user,
                      codeController.text,
                      newPasswordController.text,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Пароль успешно изменен')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    setState(() => _dialogErrorMessage =
                        e.toString().replaceFirst('Exception: ', ''));
                  } finally {
                    if (mounted) {
                      setState(() => _isDialogLoading = false);
                    }
                  }
                },
                child: _isDialogLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = UserModel(
        login: _loginController.text,
        email: _emailController.text, name: '',
      );

      final success = await widget.apiClient.restorePassword(user);

      if (!mounted) return;

      if (success) {
        await _showResetPasswordDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
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
                  SvgPicture.asset('lib/assets/logo.svg', width: 150),
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
            : const Text("Восстановить пароль", style: enterStyle),
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