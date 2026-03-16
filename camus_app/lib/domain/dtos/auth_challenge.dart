class AuthChallenge {
  final bool requires2fa;
  final int challengeId;
  final String message;

  AuthChallenge({
    required this.requires2fa,
    required this.challengeId,
    required this.message,
  });

  factory AuthChallenge.fromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      requires2fa: json["requires_2fa"],
      challengeId: json["challenge_id"],
      message: json["message"],
    );
  }
}