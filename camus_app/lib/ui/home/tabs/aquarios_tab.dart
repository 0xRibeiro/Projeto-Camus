import 'package:flutter/material.dart';
import '../home_viewmodel.dart';
import '../widgets/aquarium_card.dart';
import '../widgets/sensor_tile.dart';

class AquariosTab extends StatelessWidget {
  const AquariosTab({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final userName = viewModel.user?.name ?? 'Usuário';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Olá, $userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003459),
                  ),
                ),
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF003459),
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Bem-vindo ao Camus',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),
            const AquariumCard(),
            const SizedBox(height: 24),
            const Text(
              'Leituras dos Sensores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF003459),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SensorTile(
                  label: 'Temperatura',
                  value: '25.4',
                  unit: '°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
                SensorTile(
                  label: 'pH',
                  value: '7.2',
                  unit: '',
                  icon: Icons.science,
                  color: Color(0xFF0070BF),
                ),
                SensorTile(
                  label: 'Oxigênio',
                  value: '7.8',
                  unit: 'mg/L',
                  icon: Icons.bubble_chart,
                  color: Colors.green,
                ),
                SensorTile(
                  label: 'Salinidade',
                  value: '0',
                  unit: '‰',
                  icon: Icons.water_drop,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF003459),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _ActionButton(label: 'Detalhes', icon: Icons.info_outline),
                SizedBox(width: 8),
                _ActionButton(label: 'Alimentar', icon: Icons.restaurant),
                SizedBox(width: 8),
                _ActionButton(label: 'Configurar', icon: Icons.settings),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Última leitura: há 2 minutos',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003459),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(fontSize: 11),
          elevation: 0,
        ),
      ),
    );
  }
}
