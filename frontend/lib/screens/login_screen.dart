import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/routes/main_navigation.dart';
import 'package:zadachok/screens/password_recovery_screen.dart';
import 'package:zadachok/screens/register_screen.dart';
import '../api/mock_api_client.dart';
import '../providers/group_provider.dart';

class LoginScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const LoginScreen({
    Key? key,
    this.apiClient = const MockApiClient(),
  }) : super(key: key);

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

  static const _borderRadius = 15.0;
  static const _shadowOffset = Offset(0, 4);
  static const _shadowBlur = 6.0;
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 15);
  static const _buttonWidth = 150.0;
  static const _buttonHeight = 44.0;
  static const _inputWidth = 305.0;
  static const _inputHeight = 41.0;
  static const _colorEnter = Color.fromARGB(100, 110, 68, 255);
  static const _colorEnterButton = Color.fromARGB(100, 147, 125, 243);

  static const _textStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static const _enterStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  void _togglePasswordVisibility() => setState(() => _obscureText = !_obscureText);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.apiClient.login(
        _usernameController.text,
        _passwordController.text,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      groupProvider.setCurrentUser(user.name, isAdmin: user.isAdmin);
      await authProvider.setUser(user);

      if (user.isAdmin && !groupProvider.isInGroup) {
        await groupProvider.createGroup('Администраторы');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                const SizedBox(height: 151),
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
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordRecoveryScreen(apiClient: widget.apiClient),
                      ),
                    ),
                    child: const Text(
                      'Не помню пароль',
                      style: TextStyle(color: Colors.grey),
                    ),
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
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorEnterButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Войти", style: _enterStyle),
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
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(apiClient: widget.apiClient),
                        ),
                      ),
                      child: const Text(
                        "Зарегистрироваться",
                        style: TextStyle(color: _colorEnterButton),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
      width: _inputWidth,
      height: _inputHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
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
          ),
          validator: validator,
        ),
      ),
    );
  }
}