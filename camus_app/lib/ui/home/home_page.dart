import 'package:flutter/material.dart';
import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/ui/home/home_viewmodel.dart';
import 'widgets/logout_button.dart';
import 'widgets/user_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = injector.get<HomeViewModel>();
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = viewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (user != null) UserCard(user: user),
            const SizedBox(height: 16),
            LogoutButton(
              onPressed: () async {
                await viewModel.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}