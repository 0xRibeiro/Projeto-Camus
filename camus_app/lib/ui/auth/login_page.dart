import 'package:camus_app/main.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/login_button.dart';
import 'login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginViewModel viewModel = LoginViewModel();
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

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
              'Log In',
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
              child: ClipOval(
                child: Image.asset(
                  'assets/images/image_login_camus.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Entre para ver o seu aquário!',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
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
                    colors: [Color(0xFF003459), Color(0xFF0070BF)],
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
                          return Column(
                            children: [
                              EmailField(
                                controller: viewModel.emailController,
                                errorText: errorText,
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                controller: viewModel.passwordController,
                                obscureText: obscurePassword,
                                onToggleVisibility: togglePasswordVisibility,
                                errorText: errorText,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // aqui navegar para esqueci senha
                          },
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isLoading,
                        builder: (context, loading, _) {
                          return LoginButton(
                            text: 'Entrar',
                            onPressed: () async {
                              bool success = await viewModel.login();
                              if (success && mounted) {
                                Routefly.push(routePaths.auth.twoFactor);
                              }
                            },
                            isLoading: loading,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Routefly.push(routePaths.auth.register);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não possui conta? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Routefly.push(routePaths.auth.register);
                            },
                            child: const Text(
                              'Cadastre-se!',
                              style: TextStyle(
                                color: Color(0xFFFF9800),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
