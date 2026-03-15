import 'package:flutter/material.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/repeat_password_field.dart';
import 'widgets/username_field.dart';
import 'widgets/login_button.dart';
import 'register_viewmodel.dart';
import 'package:camus_app/ui/auth/login_page.dart';
import 'package:camus_app/ui/home/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel viewModel = RegisterViewModel();

  bool obscurePassword = true;
  bool obscureRepeatPassword = true;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void toggleRepeatPasswordVisibility() {
    setState(() {
      obscureRepeatPassword = !obscureRepeatPassword;
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
              'Register',
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
              'Crie sua conta para acessar o aquário!',
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
                              UsernameField(
                                controller: viewModel.usernameController,
                                errorText: errorText,
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              RepeatPasswordField(
                                controller: viewModel.repeatPasswordController,
                                obscureText: obscureRepeatPassword,
                                onToggleVisibility:
                                    toggleRepeatPasswordVisibility,
                                errorText: errorText,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isLoading,
                        builder: (context, loading, _) {
                          return LoginButton(
                            text: 'Cadastrar',
                            isLoading: loading,
                            onPressed: () async {
                              final bool success = await viewModel.register();
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
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já possui conta? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Entrar!',
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
