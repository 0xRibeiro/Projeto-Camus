import 'package:flutter/material.dart';
import 'alterar_senha_viewmodel.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key, required this.email});

  final String email;

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final AlterarSenhaViewModel viewModel = AlterarSenhaViewModel();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
        child: ValueListenableBuilder<int>(
          valueListenable: viewModel.step,
          builder: (context, step, _) {
            return Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Alterar Senha',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003459),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepIndicator(step),
                const SizedBox(height: 20),
                _buildStepSubtitle(step),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
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
                      child: ValueListenableBuilder<String?>(
                        valueListenable: viewModel.errorMessage,
                        builder: (context, error, _) {
                          return Column(
                            children: [
                              if (error != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade800.withValues(alpha: 0.80),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    error,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (step == 0) _buildStep0(),
                              if (step == 1) _buildStep1(),
                              if (step == 2) _buildStep2(),
                              if (step == 3) _buildStep3(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentStep || (currentStep == 3 && index == 2);
        final isDone = index < currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 32 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? const Color(0xFF003459)
                    : const Color(0xFFB8D4E3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (index < 2) const SizedBox(width: 6),
          ],
        );
      }),
    );
  }

  Widget _buildStepSubtitle(int step) {
    const subtitles = [
      'Enviaremos um código para o seu e-mail',
      'Digite o código recebido no seu e-mail',
      'Crie uma nova senha segura',
    ];
    final text = step < 3 ? subtitles[step] : 'Senha alterada!';
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      textAlign: TextAlign.center,
    );
  }

  // ── Step 0: Confirmar e-mail ─────────────────────────────────────────────

  Widget _buildStep0() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.email,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.isLoading,
          builder: (context, loading, _) => _buildPrimaryButton(
            label: 'Enviar código',
            isLoading: loading,
            onPressed: () => viewModel.enviarCodigo(widget.email),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ── Step 1: Código de recuperação ─────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      children: [
        TextField(
          controller: viewModel.codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              letterSpacing: 8,
              fontSize: 22,
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.isLoading,
          builder: (context, loading, _) => _buildPrimaryButton(
            label: 'Verificar código',
            isLoading: loading,
            onPressed: viewModel.verificarCodigo,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => viewModel.enviarCodigo(widget.email),
          child: const Text(
            'Reenviar código',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Nova senha ────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      children: [
        _buildPasswordField(
          controller: viewModel.passwordController,
          hint: 'Nova senha',
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: viewModel.confirmController,
          hint: 'Confirmar nova senha',
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 28),
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.isLoading,
          builder: (context, loading, _) => _buildPrimaryButton(
            label: 'Redefinir senha',
            isLoading: loading,
            onPressed: viewModel.redefinirSenha,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // ── Step 3: Sucesso ───────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF4CAF50),
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Senha alterada com sucesso!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Use sua nova senha no próximo login.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Concluir',
          isLoading: false,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3A4A),
          disabledBackgroundColor: const Color(0xFF1A3A4A).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
