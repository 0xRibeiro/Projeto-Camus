
import 'package:freezed_annotation/freezed_annotation.dart';


part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
sealed class User with _$User {
  const factory User ({
    required int id,
    required String name,
    required String email
  }) = _UserDefault;


  const factory User.notlogged() = NotLoggedUser;

  const factory User.logged(
    {
      required int id,
      required String name,
      required String email,
      required String token,
      required String refreshToken
    }
  ) = LoggedUser;


  factory User.fromJson(Map<String, Object?> json) 
  => _$UserFromJson(json);



}
