import 'package:flutter/material.dart';

class LoginViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  /// Simula login (substituir por chamada real à API)
  Future<bool> login() async {
    isLoading.value = true;
    errorMessage.value = null;

    await Future.delayed(const Duration(seconds: 2)); // simula requisição

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    bool success = email == 'teste@email.com' && password == '123456';

    if (!success) {
      errorMessage.value = 'E-mail ou senha inválidos';
    }

    isLoading.value = false;
    return success;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}