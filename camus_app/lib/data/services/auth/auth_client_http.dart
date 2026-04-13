import 'package:camus_app/data/services/auth/client_http.dart';
import 'package:camus_app/domain/dtos/auth_challenge.dart';
import 'package:camus_app/domain/dtos/credentials.dart';
import 'package:camus_app/domain/dtos/register_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_dto.dart';
import 'package:camus_app/domain/dtos/verify_code_response.dart';
import 'package:camus_app/domain/entities/user_entity.dart';
import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class AuthClientHttp {
  final ClientHttp _clientHttp;

  AuthClientHttp(this._clientHttp);

  AsyncResult<AuthChallenge> register(RegisterDTO dto) async {
    final response = await _clientHttp.post("/cadastrar", dto.toJson());

    return response.map((response) {
      final httpResponse = response as Response;
      return AuthChallenge.fromJson(httpResponse.data);
    });
  }

  AsyncResult<AuthChallenge> login(Credentials credentials) async {
    final response = await _clientHttp.post("/login", {
      "email": credentials.email,
      "senha": credentials.password,
    });

    return response.map((response) {
      final httpResponse = response as Response;
      return AuthChallenge.fromJson(httpResponse.data);
    });
  }

  AsyncResult<VerifyCodeResponse> verifyCode(VerifyCodeDTO dto) async {
    final response = await _clientHttp.post("/verificar-codigo", dto.toJson());

    return response.map((response) {
      final httpResponse = response as Response;
      return VerifyCodeResponse.fromJson(httpResponse.data);
    });
  }

  AsyncResult<LoggedUser> getMe(String token) async {
    final response = await _clientHttp.get(
      "/me",
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.map((response) {
      final httpResponse = response as Response;
      final json = httpResponse.data as Map<String, dynamic>;

      return LoggedUser(
        id: json["id"],
        name: json["nome"],
        email: json["email"],
        token: token,
        refreshToken: "",
      );
    });
  }

  AsyncResult<Unit> logout(String token) async {
    final response = await _clientHttp.post(
      "/logout",
      {},
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.map((_) => unit);
  }

  AsyncResult<int> solicitarRecuperacao(String email) async {
    final response = await _clientHttp.post('/recuperar-senha', {'email': email});

    return response.map((response) {
      final httpResponse = response as Response;
      return httpResponse.data['challenge_id'] as int;
    });
  }

  AsyncResult<String> verificarCodigoRecuperacao(int challengeId, String codigo) async {
    final response = await _clientHttp.post('/verificar-codigo-recuperacao', {
      'challenge_id': challengeId,
      'codigo': codigo,
    });

    return response.map((response) {
      final httpResponse = response as Response;
      return httpResponse.data['token'] as String;
    });
  }

  AsyncResult<Unit> redefinirSenha(String token, String novaSenha) async {
    final response = await _clientHttp.post('/redefinir-senha', {
      'token': token,
      'nova_senha': novaSenha,
    });

    return response.map((_) => unit);
  }
}