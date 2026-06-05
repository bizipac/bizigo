import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:icici_bank/core/util/app_preference.dart';

class ApiClient {
  late Dio _dio;

  ApiClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            headers: {"Content-Type": "application/json"},
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

    _dio.interceptors.addAll([_AuthInterceptor(), _LoggingInterceptor()]);
  }

  // POST
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    log('in POst URL: ${url.toString()}');
    log('in POst body: ${body.toString()}');
    try {
      final response = await _dio.post(url, data: body);
      log('in response : ${response.toString()}');
      log('in response data : ${response.data.toString()}');
      return response.data;
    } on DioException catch (e) {
      log('Dio Error: ${e.toString()}');
      // throw Exception(_handleError(e));
      // ✅ IMPORTANT: return response body instead of throwing
      if (e.response != null && e.response!.data != null) {
        return e.response!.data;
      }
      // only throw when there is NO response at all (network error)
      rethrow;
    }
  }
  Future<dynamic> postXml(String url, String xmlBody, String token) async {
    try {
      log("========== XML API REQUEST ==========");
      log("URL: $url");
      log("Headers:");
      log("Authorization: Bearer $token");
      log("Content-Type: application/xml");
      log("Request Body (XML):");
      log(xmlBody);
      log("=====================================");

      final response = await _dio.post(
        url,
        data: xmlBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/xml",
          },
          responseType: ResponseType.plain, // important for XML/Raw response
        ),
      );

      log("========== XML API RESPONSE ==========");
      log("Status Code: ${response.statusCode}");
      log("Response Data:");
      log(response.data.toString());
      log("======================================");

      return response.data;

    } on DioException catch (e) {
      log("========== XML API ERROR ==========");
      log("Error Message: ${e.message}");

      if (e.response != null) {
        log("Error Status Code: ${e.response?.statusCode}");
        log("Error Response Data:");
        log(e.response?.data.toString() ?? "No response body");
        return e.response?.data;
      }

      log("No response received (Network issue)");
      log("===================================");

      rethrow;
    }
  }



  // GET
  Future<dynamic> get(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // PUT
  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(url, data: body);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // DELETE
  Future<dynamic> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return "Error: ${error.response?.data}";
    } else {
      return "Network Error: ${error.message}";
    }
  }
}

// ------------------ Interceptors ------------------

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final token = await TokenManager.getToken();
    final token = AppPreference.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log("📤 [REQUEST] ${options.method} → ${options.uri}");
    log("Headers: ${options.headers}");
    log("Body: ${options.data}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      "📥 [RESPONSE] ${response.statusCode} ← ${response.requestOptions.uri}",
    );
    log("Response Data: ${response.data}");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("❌ [ERROR] ${err.requestOptions.uri}");
    log("Message: ${err.message}");
    if (err.response != null) {
      log("Response: ${err.response?.data}");
    }
    handler.next(err);
  }
}
