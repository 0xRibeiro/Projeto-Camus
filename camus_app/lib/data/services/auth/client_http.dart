import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class ClientHttp {
      final Dio _dio;

    ClientHttp(this._dio);

  AsyncResult get(String url) async {
    try {
      final response = await _dio.get(url);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult post(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(url, data: data);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult put(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(url, data: data);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult patch(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(url, data: data);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }
}
