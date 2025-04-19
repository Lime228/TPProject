import 'package:flutter/material.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/user/user_model.dart';


//TODO: поправить поля ввода чтобы они корректно перематывались при большой длинне
//TODO: добавьте вывод ошибок человеческий

//*
// RegisterScreen теперь не создается как константа, и всегда требует в себя ApiClient
// В login_screen есть пример использования
//*

class RegisterScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const RegisterScreen({
    Key? key,
    required this.apiClient
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  static const _borderRadius = 15.0;
  static const _shadowOffset = Offset(0, 4);
  static const _shadowBlur = 6.0;
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 15);

  // Размеры
  static const _buttonWidth = 200.0;
  static const _buttonHeight = 44.0;
  static const _inputWidth = 305.0;
  static const _inputHeight = 41.0;

  // Цвета
  static const _colorEnter = Color.fromARGB(100, 110, 68, 255);
  static const _colorEnterButton = Color.fromARGB(100, 147, 125, 243);

  // Стили текста
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
          login: _usernameController.text, birthdayDate: DateTime.parse('1990-01-01'),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Успешная регистрация! ID: ${user.id}')),
      );

      // Можно добавить автоматический переход на экран входа после регистрации
      // Navigator.pop(context);

    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      widget.apiClient.dispose();
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
      // ОЧЕНЬ ВАЖНО ЗАКРЫВАТЬ АПИШКУ В try() finally{} ИНАЧЕ БУДУТ ВИСЕТЬ КОННЕКТЫ//
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
      setState(() => _isLoading = false);
    }
  }


  //TODO: размер подровнять с экраном логина
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
                "Регистрация",
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
              ),
              const SizedBox(height: 10),
              _buildInputField(
                hintText: 'Почта',
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                hintText: 'Пароль',
                controller: _passwordController,
                isPassword: true,
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
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorEnterButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Зарегистрироваться", style: _enterStyle),
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
                      style: TextStyle(color: _colorEnterButton),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    bool isPassword = false,
    Widget? suffixIcon,
    required TextEditingController controller,
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
              blurRadius: _shadowBlur,
              offset: _shadowOffset,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: _textStyle,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              borderSide: BorderSide.none,
            ),
            contentPadding: _contentPadding,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}