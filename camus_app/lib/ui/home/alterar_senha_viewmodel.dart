import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AlterarSenhaViewModel {
  final AuthClientHttp _client = injector.get<AuthClientHttp>();

  final ValueNotifier<int> step = ValueNotifier(0);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  int? _challengeId;
  String? _recoveryToken;

  Future<void> enviarCodigo(String email) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _client.solicitarRecuperacao(email);

    isLoading.value = false;

    result.fold(
      (challengeId) {
        _challengeId = challengeId;
        step.value = 1;
      },
      (error) {
        errorMessage.value = _extractError(error, 'Erro ao enviar código');
      },
    );
  }

  Future<void> verificarCodigo() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _client.verificarCodigoRecuperacao(
      _challengeId!,
      codeController.text.trim(),
    );

    isLoading.value = false;

    result.fold(
      (token) {
        _recoveryToken = token;
        step.value = 2;
      },
      (error) {
        errorMessage.value = _extractError(error, 'Código inválido ou expirado');
      },
    );
  }

  Future<void> redefinirSenha() async {
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (password != confirm) {
      errorMessage.value = 'As senhas não coincidem';
      return;
    }

    if (password.length < 8) {
      errorMessage.value = 'A senha deve ter ao menos 8 caracteres';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _client.redefinirSenha(_recoveryToken!, password);

    isLoading.value = false;

    result.fold(
      (_) => step.value = 3,
      (error) {
        errorMessage.value = _extractError(error, 'Erro ao redefinir senha');
      },
    );
  }

  String _extractError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
    }
    return fallback;
  }

  void dispose() {
    step.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }
}
