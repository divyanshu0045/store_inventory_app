import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://127.0.0.1:8000', // Point to the local FastAPI server
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  // Example GET request
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // Example POST request
  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  // Example PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  // Example DELETE request
  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}