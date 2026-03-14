// interface de autenticacao

import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class AuthRepository {
  AsyncResult<LoggedUser> login(Credentials credentials);
  AsyncResult<Unit> logout();
  AsyncResult<LoggedUser> getUser();
  Stream<User> userObservable();

  void dispose();
}
