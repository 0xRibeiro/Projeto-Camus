import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class HomeViewModel extends ChangeNotifier {
  LoggedUser? user;

  Future<void> logout() async {
    user = null;
    notifyListeners();
  }
}