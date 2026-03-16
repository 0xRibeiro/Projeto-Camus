// implementacao da interface de autenticacao

import 'dart:async';

import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:camus_app/data/services/auth/auth_local_storage.dart';
import 'package:camus_app/domain/dtos/auth_challenge.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_response.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';

class RemoteAuthRepository implements AuthRepository {
  final _StreamController = StreamController<User>.broadcast();
  final AuthLocalStorage _authLocalStorage;
  final AuthClientHttp _authClientHttp;

  RemoteAuthRepository(this._authLocalStorage, this._authClientHttp);

  @override
  AsyncResult<AuthChallenge> register(RegisterDTO registerDTO) {
    return _authClientHttp.register(registerDTO);
  }

  @override
  AsyncResult<AuthChallenge> login(Credentials credentials) {
    return _authClientHttp.login(credentials);
  }

  AsyncResult<VerifyCodeResponse> verifyCode(VerifyCodeDTO dto) {
    return _authClientHttp.verifyCode(dto);
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
