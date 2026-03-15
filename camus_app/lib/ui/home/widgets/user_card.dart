import 'package:flutter/material.dart';
import 'package:camus_app/domain/entities/user_entity.dart';

class UserCard extends StatelessWidget {
  final LoggedUser user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}