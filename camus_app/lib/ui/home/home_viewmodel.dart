import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class HomeViewModel extends ChangeNotifier {
  LoggedUser? user;

  HomeViewModel() {
    loadUser();
  }

  void loadUser() {
  user = const LoggedUser(
    id: 1,
    name: 'Usuário de teste',
    email: 'teste@email.com',
    token: 'token',
    refreshToken: 'refresh-token',
  );
  notifyListeners();
}

  Future<void> logout() async {
    user = null;
    notifyListeners();
  }
}