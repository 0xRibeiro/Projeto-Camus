import 'package:result_dart/result_dart.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/dtos/auth_challenge.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_response.dart';
import 'package:camus_app/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  AsyncResult<AuthChallenge> register(RegisterDTO registerDTO);

  AsyncResult<AuthChallenge> login(Credentials credentials);

  AsyncResult<VerifyCodeResponse> verifyCode(VerifyCodeDTO dto);

  AsyncResult<LoggedUser> getMe(String token);

  AsyncResult<Unit> logout(String token);
}