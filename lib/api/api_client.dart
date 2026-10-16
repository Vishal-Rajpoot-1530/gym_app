import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();
  static final i = ApiClient._();

  Future<String?> _token() async =>
      (await SharedPreferences.getInstance()).getString('api_token');

  Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final token = await _token();
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _requestLog(String method, String path) =>
      debugPrint('[API] --> $method ${ApiConfig.baseUrl}$path');

  void _responseLog(String method, String path, int code, int ms) =>
      debugPrint('[API] <-- $method $path [$code] ${ms}ms');

  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  Future<dynamic> request(String method, String path, {Object? body}) async {
    final stopwatch = Stopwatch()..start();
    _requestLog(method, path);
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = await _headers();
      final encodedBody = body == null ? null : jsonEncode(body);
      late http.Response response;
      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method $method');
      }
      _responseLog(
        method,
        path,
        response.statusCode,
        stopwatch.elapsedMilliseconds,
      );
      return _decode(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (error) {
      debugPrint('[API] !! $method $path NO NETWORK: $error');
      throw const ApiException(
        'Internet connection required. Please connect and try again.',
        networkError: true,
      );
    } on TimeoutException catch (error) {
      debugPrint('[API] !! $method $path TIMEOUT: $error');
      throw const ApiException(
        'Server is not responding. Please try again.',
        networkError: true,
      );
    } on http.ClientException catch (error) {
      debugPrint('[API] !! $method $path CLIENT: $error');
      throw const ApiException(
        'Cannot connect to the server. Please check your connection.',
        networkError: true,
      );
    } catch (error) {
      debugPrint('[API] !! $method $path ERROR: $error');
      rethrow;
    }
  }

  Future<dynamic> get(String path) => request('GET', path);
  Future<dynamic> post(String path, [Object? body]) =>
      request('POST', path, body: body);
  Future<dynamic> put(String path, [Object? body]) =>
      request('PUT', path, body: body);
  Future<dynamic> patch(String path, [Object? body]) =>
      request('PATCH', path, body: body);
  Future<dynamic> delete(String path, [Object? body]) =>
      request('DELETE', path, body: body);

  Future<dynamic> uploadBytes(
    String path,
    String field,
    Uint8List bytes, {
    String filename = 'upload.jpg',
  }) async {
    final stopwatch = Stopwatch()..start();
    _requestLog('UPLOAD', path);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$path'),
      );
      final token = await _token();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        http.MultipartFile.fromBytes(field, bytes, filename: filename),
      );
      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      _responseLog(
        'UPLOAD',
        path,
        response.statusCode,
        stopwatch.elapsedMilliseconds,
      );
      return _decode(response);
    } on SocketException {
      throw const ApiException(
        'Internet connection required. Please connect and try again.',
        networkError: true,
      );
    } on TimeoutException {
      throw const ApiException(
        'Server is not responding. Please try again.',
        networkError: true,
      );
    }
  }
}
