import 'package:flutter/material.dart';
import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/ui/home/home_viewmodel.dart';
import 'tabs/aquarios_tab.dart';
import 'tabs/adicionar_tab.dart';
import 'tabs/perfil_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;
  int _currentIndex = 0;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AquariosTab(viewModel: viewModel),
          const AdicionarTab(),
          PerfilTab(viewModel: viewModel),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF003459),
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'Aquários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
