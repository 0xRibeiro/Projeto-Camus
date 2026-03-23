import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:camus_app/domain/dtos/auth_challenge.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_response.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

class RemoteAuthRepository implements AuthRepository {
  final AuthClientHttp _authClientHttp;

  RemoteAuthRepository(this._authClientHttp);

  @override
  AsyncResult<AuthChallenge> register(RegisterDTO registerDTO) {
    return _authClientHttp.register(registerDTO);
  }

  @override
  AsyncResult<AuthChallenge> login(Credentials credentials) {
    return _authClientHttp.login(credentials);
  }

  @override
  AsyncResult<VerifyCodeResponse> verifyCode(VerifyCodeDTO dto) {
    return _authClientHttp.verifyCode(dto);
  }

  @override
  AsyncResult<LoggedUser> getMe(String token) {
    return _authClientHttp.getMe(token);
  }

  @override
  AsyncResult<Unit> logout(String token) {
    return _authClientHttp.logout(token);
  }
}