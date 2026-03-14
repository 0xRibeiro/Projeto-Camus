// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
User _$UserFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'default':
          return _UserDefault.fromJson(
            json
          );
                case 'notlogged':
          return NotLoggedUser.fromJson(
            json
          );
                case 'logged':
          return LoggedUser.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'User',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$User {



  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'User()';
}


}

/// @nodoc
class $UserCopyWith<$Res>  {
$UserCopyWith(User _, $Res Function(User) __);
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDefault value)?  $default,{TResult Function( NotLoggedUser value)?  notlogged,TResult Function( LoggedUser value)?  logged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDefault() when $default != null:
return $default(_that);case NotLoggedUser() when notlogged != null:
return notlogged(_that);case LoggedUser() when logged != null:
return logged(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDefault value)  $default,{required TResult Function( NotLoggedUser value)  notlogged,required TResult Function( LoggedUser value)  logged,}){
final _that = this;
switch (_that) {
case _UserDefault():
return $default(_that);case NotLoggedUser():
return notlogged(_that);case LoggedUser():
return logged(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDefault value)?  $default,{TResult? Function( NotLoggedUser value)?  notlogged,TResult? Function( LoggedUser value)?  logged,}){
final _that = this;
switch (_that) {
case _UserDefault() when $default != null:
return $default(_that);case NotLoggedUser() when notlogged != null:
return notlogged(_that);case LoggedUser() when logged != null:
return logged(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String email)?  $default,{TResult Function()?  notlogged,TResult Function( int id,  String name,  String email,  String token,  String refreshToken)?  logged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDefault() when $default != null:
return $default(_that.id,_that.name,_that.email);case NotLoggedUser() when notlogged != null:
return notlogged();case LoggedUser() when logged != null:
return logged(_that.id,_that.name,_that.email,_that.token,_that.refreshToken);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String email)  $default,{required TResult Function()  notlogged,required TResult Function( int id,  String name,  String email,  String token,  String refreshToken)  logged,}) {final _that = this;
switch (_that) {
case _UserDefault():
return $default(_that.id,_that.name,_that.email);case NotLoggedUser():
return notlogged();case LoggedUser():
return logged(_that.id,_that.name,_that.email,_that.token,_that.refreshToken);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String email)?  $default,{TResult? Function()?  notlogged,TResult? Function( int id,  String name,  String email,  String token,  String refreshToken)?  logged,}) {final _that = this;
switch (_that) {
case _UserDefault() when $default != null:
return $default(_that.id,_that.name,_that.email);case NotLoggedUser() when notlogged != null:
return notlogged();case LoggedUser() when logged != null:
return logged(_that.id,_that.name,_that.email,_that.token,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDefault implements User {
  const _UserDefault({required this.id, required this.name, required this.email, final  String? $type}): $type = $type ?? 'default';
  factory _UserDefault.fromJson(Map<String, dynamic> json) => _$UserDefaultFromJson(json);

 final  int id;
 final  String name;
 final  String email;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDefaultCopyWith<_UserDefault> get copyWith => __$UserDefaultCopyWithImpl<_UserDefault>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDefaultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDefault&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email);

@override
String toString() {
  return 'User(id: $id, name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$UserDefaultCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserDefaultCopyWith(_UserDefault value, $Res Function(_UserDefault) _then) = __$UserDefaultCopyWithImpl;
@useResult
$Res call({
 int id, String name, String email
});




}
/// @nodoc
class __$UserDefaultCopyWithImpl<$Res>
    implements _$UserDefaultCopyWith<$Res> {
  __$UserDefaultCopyWithImpl(this._self, this._then);

  final _UserDefault _self;
  final $Res Function(_UserDefault) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,}) {
  return _then(_UserDefault(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class NotLoggedUser implements User {
  const NotLoggedUser({final  String? $type}): $type = $type ?? 'notlogged';
  factory NotLoggedUser.fromJson(Map<String, dynamic> json) => _$NotLoggedUserFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$NotLoggedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotLoggedUser);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'User.notlogged()';
}


}




/// @nodoc
@JsonSerializable()

class LoggedUser implements User {
  const LoggedUser({required this.id, required this.name, required this.email, required this.token, required this.refreshToken, final  String? $type}): $type = $type ?? 'logged';
  factory LoggedUser.fromJson(Map<String, dynamic> json) => _$LoggedUserFromJson(json);

 final  int id;
 final  String name;
 final  String email;
 final  String token;
 final  String refreshToken;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedUserCopyWith<LoggedUser> get copyWith => _$LoggedUserCopyWithImpl<LoggedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoggedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,token,refreshToken);

@override
String toString() {
  return 'User.logged(id: $id, name: $name, email: $email, token: $token, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $LoggedUserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory $LoggedUserCopyWith(LoggedUser value, $Res Function(LoggedUser) _then) = _$LoggedUserCopyWithImpl;
@useResult
$Res call({
 int id, String name, String email, String token, String refreshToken
});




}
/// @nodoc
class _$LoggedUserCopyWithImpl<$Res>
    implements $LoggedUserCopyWith<$Res> {
  _$LoggedUserCopyWithImpl(this._self, this._then);

  final LoggedUser _self;
  final $Res Function(LoggedUser) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? token = null,Object? refreshToken = null,}) {
  return _then(LoggedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
