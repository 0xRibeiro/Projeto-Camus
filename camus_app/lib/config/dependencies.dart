import 'package:auto_injector/auto_injector.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/data/repositories/auth/remote_auth_repository.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:camus_app/data/services/auth/auth_local_storage.dart';
import 'package:camus_app/data/services/auth/client_http.dart';
import 'package:camus_app/data/services/local_storage.dart';

final injector = AutoInjector();

void setupDependencies() {
  // Services
  injector.addSingleton<AuthRepository>(RemoteAuthRepository.new);
  injector.addSingleton(ClientHttp.new);
  injector.addSingleton(LocalStorage.new);
  injector.addSingleton(AuthClientHttp.new);
  injector.addSingleton(AuthLocalStorage.new);
}
