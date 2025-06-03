import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import 'package:zadachok/screens/tasks_screen.dart';

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

  // Перенесенные переменные из диалога
  bool _isDialogLoading = false;
  String? _dialogErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  Future<void> _safeReportEvent(String eventName, {Map<String, dynamic>? attributes}) async {
    try {
      await AppMetrica.reportEvent(eventName);
    } catch (e) {
      debugPrint('Ошибка отправки события в AppMetrica: $e');
      await _reportErrorToAppMetrica(
        message: 'Failed to report event: $eventName',
        error: e,
      );
    }
  }

  Future<void> _reportErrorToAppMetrica({
    required dynamic error,
    String? message,
  }) async {
    try {
      await AppMetrica.reportError(
        message: message ?? 'Error occurred in PasswordRecoveryScreen',
        errorDescription: AppMetricaErrorDescription(
          (error is Exception ? error : Exception(error.toString())) as StackTrace,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка отправки ошибки в AppMetrica: $e');
    }
  }

  Future<void> _showResetPasswordDialog() async {
    await _safeReportEvent('show_reset_password_dialog');

    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool _obscureNewPassword = true;
        bool _obscureConfirmPassword = true;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Сброс пароля',
                      style: _textStyleBold.copyWith(
                        fontSize: 22,
                        color: TaskScreenStyles.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Код отправлен на ${_emailController.text}',
                      style: _textStyleSemiBold.copyWith(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Поле для кода подтверждения
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: codeController,
                        decoration: InputDecoration(
                          labelText: 'Код подтверждения',
                          labelStyle: _textStyleSemiBold.copyWith(
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: _textStyleSemiBold,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Введите код' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Поле для нового пароля
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Новый пароль',
                          labelStyle: _textStyleSemiBold.copyWith(
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: TaskScreenStyles.primaryColor,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        style: _textStyleSemiBold,
                        validator: (value) => (value?.length ?? 0) < 6
                            ? 'Минимум 6 символов'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Поле для подтверждения пароля
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Подтвердите пароль',
                          labelStyle: _textStyleSemiBold.copyWith(
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: TaskScreenStyles.primaryColor,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: _textStyleSemiBold,
                        validator: (value) => value != newPasswordController.text
                            ? 'Пароли не совпадают'
                            : null,
                      ),
                    ),

                    if (_dialogErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _dialogErrorMessage!,
                          style: _textStyleSemiBold.copyWith(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Кнопки действий
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _safeReportEvent('reset_password_cancel');
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Отмена',
                            style: _textStyleSemiBold.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (newPasswordController.text !=
                                confirmPasswordController.text) {
                              setDialogState(() {
                                _dialogErrorMessage = 'Пароли не совпадают';
                              });
                              return;
                            }

                            try {
                              await _safeReportEvent('reset_password_attempt');
                              setDialogState(() {
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
                                await _safeReportEvent('reset_password_success');
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Пароль успешно изменен',
                                      style: _textStyleSemiBold,
                                    ),
                                    backgroundColor: TaskScreenStyles.primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                await _safeReportEvent(
                                    'password_changed_successfully');
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              await _reportErrorToAppMetrica(
                                error: e,
                                message:
                                'Password reset error for user: ${_loginController.text}',
                              );
                              setDialogState(() {
                                _dialogErrorMessage =
                                    e.toString().replaceFirst('Exception: ', '');
                              });
                            } finally {
                              setDialogState(() => _isDialogLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TaskScreenStyles.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: _isDialogLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            'Сохранить',
                            style: _textStyleSemiBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _safeReportEvent('password_recovery_attempt');

      final user = UserModel(
        login: _loginController.text,
        email: _emailController.text,
        name: '',
      );

      final success = await widget.apiClient.restorePassword(user);

      if (success) {
        await _safeReportEvent('password_recovery_code_sent');
        await _showResetPasswordDialog();
      }
    } catch (e) {
      await _reportErrorToAppMetrica(
        error: e,
        message: 'Password recovery error for user: ${_loginController.text}',
      );
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToLogin() async {
    await _safeReportEvent('navigate_to_login');
    Navigator.pop(context);
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
                        : Text(
                      "Восстановить пароль",
                      style: _textStyleSemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
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