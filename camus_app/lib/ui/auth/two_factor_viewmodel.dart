import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/config/session.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';

class TwoFactorViewModel {
  final TextEditingController codeController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isResendingCode = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<String?> successMessage = ValueNotifier(null);

  final AuthRepository _authRepository = injector.get<AuthRepository>();

  Future<bool> verifyCode(int challengeId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final dto = VerifyCodeDTO(
      challengeId: challengeId,
      codigo: codeController.text.trim(),
    );

    final verifyResult = await _authRepository.verifyCode(dto);

    return await verifyResult.fold(
      (success) async {
        currentToken = success.token;

        final meResult = await _authRepository.getMe(success.token);

        isLoading.value = false;

        return meResult.fold(
          (user) {
            currentUser = user;

            final homeVM = injector.get<HomeViewModel>();
            homeVM.setUser(user);

            return true;
          },
          (error) {
            errorMessage.value = error.toString();
            return false;
          },
        );
      },
      (error) {
        isLoading.value = false;
        errorMessage.value = "Código inválido";
        return false;
      },
    );
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