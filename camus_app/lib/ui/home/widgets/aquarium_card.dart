import 'package:flutter/material.dart';

class AquariumCard extends StatelessWidget {
  const AquariumCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aquário da Sala',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003459),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '4L · Água doce',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Boa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.set_meal, color: Color(0xFF0070BF), size: 18),
                const SizedBox(width: 8),
                const Text(
                  '8 Tetra Neon',
                  style: TextStyle(fontSize: 14, color: Color(0xFF003459)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.water_drop, color: Color(0xFF0070BF), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Água doce',
                  style: TextStyle(fontSize: 14, color: Color(0xFF003459)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFB8D4E3)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Qualidade geral',
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
                const Text(
                  '92%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.92,
                backgroundColor: Color(0xFFB8D4E3),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
