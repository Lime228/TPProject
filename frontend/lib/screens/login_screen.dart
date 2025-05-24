import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/api/api_client.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import 'package:zadachok/routes/main_navigation.dart';
import 'package:zadachok/screens/password_recovery_screen.dart';
import 'package:zadachok/screens/register_screen.dart';
import '../api/mock_api_client.dart';
import '../providers/group_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class LoginScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const LoginScreen({Key? key, required this.apiClient}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  // Адаптивные константы
  double get _borderRadius => MediaQuery.of(context).size.width * 0.035;
  Offset get _shadowOffset => Offset(0, MediaQuery.of(context).size.height * 0.005);
  double get _shadowBlur => MediaQuery.of(context).size.width * 0.015;
  EdgeInsets get _contentPadding => EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width * 0.05,
    vertical: MediaQuery.of(context).size.height * 0.02,
  );
  double get _buttonWidth => MediaQuery.of(context).size.width * 0.4;
  double get _buttonHeight => MediaQuery.of(context).size.height * 0.06;
  double get _inputWidth => MediaQuery.of(context).size.width * 0.8;
  double get _inputHeight => MediaQuery.of(context).size.height * 0.06;
  static const _colorEnter = Color.fromARGB(100, 110, 68, 255);
  static const _colorEnterButton = Color(0xFF937DF3);

  TextStyle get _textStyle => TextStyle(
    fontSize: MediaQuery.of(context).size.width * 0.04,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  TextStyle get _enterStyle => TextStyle(
    fontSize: MediaQuery.of(context).size.width * 0.04,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  void _togglePasswordVisibility() =>
      setState(() => _obscureText = !_obscureText);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await widget.apiClient.login(
        UserModel(
          login: _usernameController.text,
          password: _passwordController.text,
          name: '',
          email: '',
          birthdayDate: DateTime.timestamp(),
        ),
      );

      final token = widget.apiClient.getAuthToken();
      debugPrint("Токен получен: ${token}");

      if (token == null) throw Exception('Токен не получен');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);

      await authProvider.setAuthData(user: user, token: token);

      groupProvider.setCurrentUser(user);
      await groupProvider.loadGroupData();
      if (groupProvider.isInGroup) {
        await groupProvider.refreshGroupData();
      }

      if (!mounted) return;

      await authProvider.refreshAll(groupProvider, taskProvider, shopProvider);
      await groupProvider.refreshGroupData();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Ошибка входа: ${e.toString()}");
      if (mounted) {
        setState(
              () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
        );
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
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
                    "Вход",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: _colorEnter,
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
                    hintText: 'Пароль',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PasswordRecoveryScreen(
                            apiClient: widget.apiClient,
                          ),
                        ),
                      ),
                      child: Text(
                        'Не помню пароль',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015,
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Container(
                    width: _buttonWidth,
                    height: _buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: _shadowBlur,
                          offset: _shadowOffset,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorEnterButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.06,
                        height: MediaQuery.of(context).size.width * 0.06,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : Text("Войти", style: _enterStyle),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ещё нет аккаунта? ",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              apiClient: widget.apiClient,
                            ),
                          ),
                        ),
                        child: Text(
                          "Зарегистрироваться",
                          style: TextStyle(
                            color: _colorEnterButton,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
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
      width: _inputWidth,
      height: _inputHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _shadowBlur,
              offset: _shadowOffset,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            contentPadding: _contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            suffixIcon: suffixIcon,
            hintStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.035,
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
}