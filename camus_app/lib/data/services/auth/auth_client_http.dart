import 'package:camus_app/data/services/auth/client_http.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';
import 'package:dio/dio.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';

class AuthClientHttp {
  final ClientHttp _clientHttp;

  AuthClientHttp(this._clientHttp);

  AsyncResult<LoggedUser> login(Credentials credentials) async {
    final response = await _clientHttp.post('/login', {
      'email': credentials.email,
      'password': credentials.password,
    });

    return response.map((response) {
      final httpResponse = response as Response;
      return LoggedUser.fromJson(httpResponse.data);
    });
  }

  AsyncResult<User> register(RegisterDTO registerDTO) async {
    final response = await _clientHttp.post('/cadastrar', registerDTO.toJson());

    return response.map((response) {
      final httpResponse = response as Response;
      return User.fromJson(httpResponse.data);
    });
  }
}
