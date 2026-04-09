import 'package:flutter/material.dart';

enum _ConnectionState { idle, connecting, connected }

class AdicionarTab extends StatefulWidget {
  const AdicionarTab({super.key});

  @override
  State<AdicionarTab> createState() => _AdicionarTabState();
}

class _AdicionarTabState extends State<AdicionarTab> {
  _ConnectionState _connState = _ConnectionState.idle;

  final _nomeController = TextEditingController();
  final _volumeController = TextEditingController();
  final _especieController = TextEditingController();
  final _numPeixesController = TextEditingController();
  final _temperaturaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _volumeController.dispose();
    _especieController.dispose();
    _numPeixesController.dispose();
    _temperaturaController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _connState = _ConnectionState.connecting);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _connState = _ConnectionState.connected);
    });
  }

  void _handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aquário adicionado com sucesso!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar Aquário',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003459),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Conecte seu ESP32 e configure o aquário',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 24),
                _buildConnectionSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
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
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  children: [
                    _buildPillField(
                      _nomeController,
                      'Nome do aquário',
                      Icons.water,
                    ),
                    const SizedBox(height: 16),
                    _buildPillField(
                      _volumeController,
                      'Volume em litros',
                      Icons.straighten,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildPillField(
                      _especieController,
                      'Espécie dos peixes',
                      Icons.set_meal,
                    ),
                    const SizedBox(height: 16),
                    _buildPillField(
                      _numPeixesController,
                      'Número de peixes',
                      Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildPillField(
                      _temperaturaController,
                      'Temperatura desejada (°C)',
                      Icons.thermostat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A4A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Adicionar Aquário',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: switch (_connState) {
        _ConnectionState.idle => Column(
            children: [
              const Icon(
                Icons.bluetooth_searching,
                color: Color(0xFF003459),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhum ESP32 conectado',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _startSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003459),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buscar dispositivos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        _ConnectionState.connecting => const Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF003459)),
              SizedBox(height: 12),
              Text(
                'Procurando ESP32...',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
        _ConnectionState.connected => const Column(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
              SizedBox(height: 8),
              Text(
                'ESP32 encontrado!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Camus-ESP32-A4F3',
                style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
            ],
          ),
      },
    );
  }

  Widget _buildPillField(
    TextEditingController controller,
    String hint,
    IconData prefixIcon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
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
}
