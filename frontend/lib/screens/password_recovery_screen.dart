import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';

const TextStyle _textStyleSemiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600, // SemiBold
);

const TextStyle _textStyleBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700, // Bold
);

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
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _isDialogLoading = false;
    String? _dialogErrorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Сброс пароля',
          style: _textStyleBold.copyWith(
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Код отправлен на ${_emailController.text}',
                  style: _textStyleBold.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Код подтверждения',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Введите код' : null,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                      style: _textStyleSemiBold.copyWith(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: _textStyleSemiBold),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                setState(() {
                  _dialogErrorMessage = 'Пароли не совпадают';
                });
                return;
              }

              try {
                setState(() {
                  _isDialogLoading = true;
                  _dialogErrorMessage = null;
                });

                final user = UserModel(
                  login: _loginController.text,
                  email: _emailController.text,
                  name: '',
                );

                final success = await widget.apiClient.resetPassword(
                  user,
                  codeController.text,
                  newPasswordController.text,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Пароль успешно изменен', style: _textStyleSemiBold),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                setState(() {
                  _dialogErrorMessage = e.toString().replaceFirst('Exception: ', '');
                });
              } finally {
                setState(() => _isDialogLoading = false);
              }
            },
            child: _isDialogLoading
                ? const CircularProgressIndicator()
                : const Text('Сохранить', style: _textStyleSemiBold),
          ),
        ],
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
        email: _emailController.text,
        name: '',
      );

      final success = await widget.apiClient.restorePassword(user);

      if (success) {
        await _showResetPasswordDialog();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'lib/assets/logo.svg',
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  "Восстановление пароля",
                  style: _textStyleBold.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    color: const Color.fromARGB(100, 110, 68, 255),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: MediaQuery.of(context).size.width * 0.01,
                        offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _loginController,
                    validator: _validateLogin,
                    decoration: InputDecoration(
                      hintText: 'Логин',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: MediaQuery.of(context).size.width * 0.01,
                        offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      hintText: 'Почта',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: MediaQuery.of(context).size.height * 0.015,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage!,
                      style: _textStyleSemiBold.copyWith(color: Colors.red),
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: MediaQuery.of(context).size.width * 0.01,
                        offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _recoverPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF937DF3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.06),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        :  Text(
                      "Восстановить пароль",
                      style: _textStyleSemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:  Text(
                    "Вернуться к входу",
                    style: _textStyleSemiBold.copyWith(
                      color: Color(0xFF937DF3),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}