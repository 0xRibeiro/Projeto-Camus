class VerifyCodeDTO {
  final int challengeId;
  final String codigo;

  VerifyCodeDTO({
    required this.challengeId,
    required this.codigo,
  });

  Map<String, dynamic> toJson() {
    return {
      "challenge_id": challengeId,
      "codigo": codigo,
    };
  }
}