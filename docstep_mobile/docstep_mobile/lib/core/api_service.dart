import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access host's localhost.
  // Set to local host address if testing on physical device.
  static String baseUrl = 'http://10.0.2.2:3000';
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _cookie;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cookie = prefs.getString('session_cookie');
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_cookie != null) {
      headers['cookie'] = _cookie!;
    }
    return headers;
  }

  void _updateCookie(http.Response response) async {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Keep only the actual session identifier part
      int index = rawCookie.indexOf(';');
      _cookie = index != -1 ? rawCookie.substring(0, index) : rawCookie;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', _cookie!);
    }
  }

  Future<void> clearCookie() async {
    _cookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: _getHeaders());
    _updateCookie(response);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    _updateCookie(response);
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    _updateCookie(response);
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: _getHeaders());
    _updateCookie(response);
    return response;
  }

  // File Upload Helper
  Future<http.StreamedResponse> uploadFile(
    String endpoint, 
    String filePath, 
    String fieldName, 
    {Map<String, String>? fields}
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    
    // Add cookie to headers
    if (_cookie != null) {
      request.headers['cookie'] = _cookie!;
    }
    request.headers['Accept'] = 'application/json';

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    return streamedResponse;
  }
}
