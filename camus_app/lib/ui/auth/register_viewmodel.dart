import 'package:flutter/material.dart';

class RegisterViewModel {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  Future<bool> register() async {
    isLoading.value = true;
    errorMessage.value = null;

    await Future.delayed(const Duration(seconds: 2));

    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String repeatPassword = repeatPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty) {
      errorMessage.value = 'Preencha todos os campos';
      isLoading.value = false;
      return false;
    }

    if (!email.contains('@')) {
      errorMessage.value = 'E-mail inválido';
      isLoading.value = false;
      return false;
    }

    if (password.length < 6) {
      errorMessage.value = 'A senha deve ter pelo menos 6 caracteres';
      isLoading.value = false;
      return false;
    }

    if (password != repeatPassword) {
      errorMessage.value = 'As senhas não coincidem';
      isLoading.value = false;
      return false;
    }

    isLoading.value = false;
    return true;
  }

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
