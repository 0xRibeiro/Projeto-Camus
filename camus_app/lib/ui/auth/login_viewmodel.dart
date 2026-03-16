import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:flutter/material.dart';
import 'package:camus_app/config/session.dart';

class LoginViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final AuthRepository _authRepository = injector.get<AuthRepository>();

  /// Simula login (substituir por chamada real à API)
  Future<int?> login() async {
    isLoading.value = true;
    errorMessage.value = null;

    final credentials = Credentials(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final result = await _authRepository.login(credentials);

    isLoading.value = false;

    return result.fold((success) => success.challengeId, (error) {
      errorMessage.value = "Login inválido";
      return null;
    });
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
