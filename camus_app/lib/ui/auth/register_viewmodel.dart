import 'package:flutter/material.dart';
import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';

class RegisterViewModel {
  final AuthRepository _authRepository = injector.get<AuthRepository>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  Future<int?> register() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        repeatPasswordController.text.trim().isEmpty) {
      errorMessage.value = "Preencha todos os campos";
      isLoading.value = false;
      return null;
    }

    if (passwordController.text != repeatPasswordController.text) {
      errorMessage.value = "As senhas não coincidem";
      isLoading.value = false;
      return null;
    }

    final dto = RegisterDTO(
      nome: usernameController.text.trim(),
      email: emailController.text.trim(),
      senha: passwordController.text.trim(),
    );

    final result = await _authRepository.register(dto);

    isLoading.value = false;

    return result.fold((success) => success.challengeId, (error) {
      const debug = bool.fromEnvironment('DEBUG_ERRORS', defaultValue: false);
      errorMessage.value = debug
          ? "Erro: ${error.toString()}"
          : "Erro ao cadastrar. Tente novamente.";
      return null;
    });
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
