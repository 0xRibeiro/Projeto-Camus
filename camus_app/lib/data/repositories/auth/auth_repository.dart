// interface de autenticacao

import 'package:camus_app/domain/dtos/auth_challenge.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_response.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';

abstract interface class AuthRepository {
  AsyncResult<Unit> logout();
  AsyncResult<LoggedUser> getUser();
  Stream<User> userObservable();
  AsyncResult<AuthChallenge> register(RegisterDTO registerDTO);
  AsyncResult<AuthChallenge> login(Credentials credentials);
  AsyncResult<VerifyCodeResponse> verifyCode(VerifyCodeDTO dto);

  void dispose();
}
