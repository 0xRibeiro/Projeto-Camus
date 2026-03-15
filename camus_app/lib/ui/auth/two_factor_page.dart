import 'package:camus_app/ui/auth/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:camus_app/ui/auth/two_factor_viewmodel.dart';
import 'package:camus_app/ui/auth/widgets/two_factor_code_field.dart';
import 'package:camus_app/ui/home/home_page.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final TwoFactorViewModel viewModel = TwoFactorViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Verificação',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003459),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8D4E3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: Color(0xFF003459),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Digite o código de 6 dígitos enviado para o seu e-mail cadastrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF003459),
                      Color(0xFF0070BF),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: viewModel.errorMessage,
                        builder: (context, errorText, _) {
                          return TwoFactorCodeField(
                            controller: viewModel.codeController,
                            errorText: errorText,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<String?>(
                        valueListenable: viewModel.successMessage,
                        builder: (context, successText, _) {
                          if (successText == null) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              successText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isLoading,
                        builder: (context, loading, _) {
                          return LoginButton(
                            text: 'Verificar',
                            isLoading: loading,
                            onPressed: () async {
                              final bool success = await viewModel.verifyCode();

                              if (success && mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isResendingCode,
                        builder: (context, resending, _) {
                          return TextButton(
                            onPressed: resending
                                ? null
                                : () async {
                                    await viewModel.resendCode();
                                  },
                            child: Text(
                              resending
                                  ? 'Reenviando código...'
                                  : 'Reenviar código',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFFFF9800),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Código fake para teste: 123456',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
