// implementacao da interface de autenticacao

import 'dart:async';

import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:camus_app/data/services/auth/auth_local_storage.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:camus_app/domain/validators/credentials_validator.dart';
import 'package:camus_app/utils/validation/lucid_validator_extension.dart';
import 'package:result_dart/result_dart.dart';

class RemoteAuthRepository implements AuthRepository {
  final _StreamController = StreamController<User>.broadcast();
  final AuthLocalStorage _authLocalStorage;
  final AuthClientHttp _authClientHttp;

  RemoteAuthRepository(this._authLocalStorage, this._authClientHttp);

  @override
  AsyncResult<LoggedUser> login(Credentials credentials) {
    final validator = CredentialsValidator();
    return validator//
      .validateResult(credentials)
      .flatMap(_authClientHttp.login)
      .flatMap(_authLocalStorage.saveUser)
      .onSuccess(_StreamController.add);
  }

  @override
  AsyncResult<Unit> logout() {
    return _authLocalStorage.removeUser().onSuccess(
      (_) => _StreamController.add(const NotLoggedUser()),
    );
  }

  @override
  AsyncResult<LoggedUser> getUser() {
    // TODO: implement getUser
    return _authLocalStorage.getUser();
  }

  @override
  Stream<User> userObservable() {
    // TODO: implement userObservable
    return _StreamController.stream;
  }

  @override
  void dispose() {
    // TODO: implement dispose]
    _StreamController.close();
  }
}
