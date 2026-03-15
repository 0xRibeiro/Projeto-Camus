import 'package:flutter/material.dart';

class TwoFactorViewModel {
  final TextEditingController codeController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isResendingCode = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<String?> successMessage = ValueNotifier(null);

  Future<bool> verifyCode() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    await Future.delayed(const Duration(seconds: 1));

    final String code = codeController.text.trim();

    if (code.isEmpty) {
      errorMessage.value = 'Digite o código enviado no e-mail';
      isLoading.value = false;
      return false;
    }

    if (code.length != 6) {
      errorMessage.value = 'O código deve ter 6 dígitos';
      isLoading.value = false;
      return false;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      errorMessage.value = 'Digite apenas números';
      isLoading.value = false;
      return false;
    }

    const String fakeValidCode = '123456';

    final bool success = code == fakeValidCode;

    if (!success) {
      errorMessage.value = 'Código inválido';
    }

    isLoading.value = false;
    return success;
  }

  Future<void> resendCode() async {
    isResendingCode.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    await Future.delayed(const Duration(seconds: 1));

    successMessage.value = 'Um novo código foi enviado para o e-mail';
    isResendingCode.value = false;
  }

  void dispose() {
    codeController.dispose();
    isLoading.dispose();
    isResendingCode.dispose();
    errorMessage.dispose();
    successMessage.dispose();
  }
}
