import 'package:camus_app/domain/entities/user_entity.dart';

class VerifyCodeResponse {
  final bool ok;
  final String message;
  final String token;
  final String expiresAt;

  VerifyCodeResponse({
    required this.ok,
    required this.message,
    required this.token,
    required this.expiresAt,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      ok: json["ok"],
      message: json["message"],
      token: json["token"],
      expiresAt: json["expires_at"],
    );
  }
}