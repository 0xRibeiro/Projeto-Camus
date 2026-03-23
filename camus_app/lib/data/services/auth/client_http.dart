import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class ClientHttp {
  final Dio _dio;

  ClientHttp(this._dio);

  AsyncResult get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult post(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult put(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult patch(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }
}