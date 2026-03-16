import 'package:camus_app/domain/entities/user_entity.dart';

class VerifyCodeResponse {

  final bool ok;
  final LoggedUser user;

  VerifyCodeResponse({
    required this.ok,
    required this.user,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {

    final userJson = json["user"];

    return VerifyCodeResponse(
      ok: json["ok"],
      user: LoggedUser(
        id: userJson["id"],
        name: userJson["nome"],
        email: userJson["email"],
        token: "",
        refreshToken: "",
      ),
    );
  }
}