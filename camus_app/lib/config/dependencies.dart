import 'package:auto_injector/auto_injector.dart';
import 'package:camus_app/data/repositories/auth/auth_repository.dart';
import 'package:camus_app/data/repositories/auth/remote_auth_repository.dart';
import 'package:camus_app/data/services/auth/auth_client_http.dart';
import 'package:camus_app/data/services/auth/auth_local_storage.dart';
import 'package:camus_app/data/services/auth/client_http.dart';
import 'package:camus_app/data/services/local_storage.dart';
import 'package:camus_app/ui/home/home_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

String get HTTPS_SERVER_URL => dotenv.env['HTTPS_SERVER_URL'] ?? 'URL não encontrada';


final injector = AutoInjector();

void setupDependencies() {
  // repositories
  injector.addSingleton<AuthRepository>(RemoteAuthRepository.new);

  // services
  injector.addSingleton(ClientHttp.new);
  injector.addSingleton(LocalStorage.new);
  injector.addSingleton(AuthClientHttp.new);
  injector.addSingleton(AuthLocalStorage.new);

  // viewmodels
  injector.addSingleton(HomeViewModel.new);

  // https server
  injector.addSingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: HTTPS_SERVER_URL,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.httpClientAdapter = NativeAdapter();
    return dio;
  });
}
