import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Логин')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(hintText: 'Почта')),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Пароль'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: const Text("Создать аккаунт"),
            ),
          ],
        ),
      ),
    );
  }
}
