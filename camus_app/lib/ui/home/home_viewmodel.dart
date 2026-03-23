import 'package:camus_app/config/dependencies.dart';
import 'package:camus_app/config/session.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = injector.get<AuthRepository>();

  LoggedUser? user = currentUser;

  void setUser(LoggedUser newUser) {
    user = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    final token = currentToken;

    if (token != null) {
      await _authRepository.logout(token);
    }

    currentToken = null;
    currentUser = null;
    user = null;
    notifyListeners();
  }
}