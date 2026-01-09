import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hackmates_app/features/auth/models/user_model.dart';

class AuthRepository {
  AuthRepository({
    required this.baseUrl,
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _http = httpClient ?? http.Client();

  final String baseUrl;
  final FlutterSecureStorage _storage;
  final http.Client _http;

  ///  TOKEN MANAGEMENT
  static const _tokenKey = 'jwt';
  static const _userKey = 'user';

  /// Persist token in secure storage
  Future<void> persistToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve JWT - check if user is logged in ? null
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Clear JWT - logout/expiration/account deletion
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// USER STORAGE

  /// Store user data
  Future<void> persistUser(UserModel user) async {
    await _storage.write(key: _userKey, value: user.toJson());
  }

  /// Retrieve user data
  Future<UserModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
    } catch (e) {
      throw Exception('Failed to read user data: $e');
    }
    return null;
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  /// AUTHENTICATION API METHODS 

  /// Email / password login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final resp = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': email,
        'password': password,
      },
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
    }
  }
  ///Forgot Password-Reset Password Link
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/forgot-password');

    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body);
    } else {
      throw Exception('Failed to send reset password email');
    }
  }

  /// ==================== OTP-BASED REGISTRATION FLOW ====================

  ///Register basic info and send OTP to email**
  Future<Map<String, dynamic>> registerAndSendOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    //  use JSON request
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data;
    } else {
      try {
        final error = json.decode(resp.body);
        throw Exception(error['message'] ?? 'Registration failed');
      } catch (_) {
        throw Exception('Register failed: ${resp.statusCode}');
      }
    }
  }
  /// Verify OTP and get JWT
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-otp');
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'otp': otp,
      }
      ),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else {
      try {
        final error = json.decode(resp.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      } catch (_) {
        throw Exception('OTP verification failed: ${resp.statusCode}');
      }
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/resend-otp');
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to resend OTP');
    }
  }

  /// Complete profile with interests and bio (after OTP verification)
  /// Requires JWT token from OTP verification
  Future<void> completeProfile({
    required String token,
    required List<String> interests,
    String? bio,
    File? profilePhoto,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/complete-profile');

    // No photo -> JSON
    if (profilePhoto == null) {
      final body = {
        'interests': interests,
        'bio': bio ?? '',
      };

      final resp = await _http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception('Failed to complete profile');
      }
      return;
    }

    // Photo present -> multipart
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['interests'] = json.encode(interests);
    request.fields['bio'] = bio ?? '';

    final bytes = await profilePhoto.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'profilePhoto',
        bytes,
        filename: 'profile.jpg',
      ),
    );

    final streamed = await request.send();

    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to complete profile');
    }
  }

  ///OAUTH

  /// Retrieve JWT from backend using the Redis key obtained after oauth redirect
  Future<Map<String, dynamic>> fetchJwtByKey({required String key}) async {
    final uri = Uri.parse('$baseUrl/auth/get-jwt?key=$key');
    final resp = await _http.get(
        uri,
        headers: {'Content-Type': 'application/json'}
    );
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to retrieve jwt by key: ${resp.statusCode} ${resp.body}');
    }
  }

  /// HELPER METHODS

  /// Helper to convert backend auth response into token + user model
  Future<Map<String, dynamic>> parseAuthResponse(Map<String, dynamic> resp) async {
    final token = resp['token'] as String?;
    final userMap = resp['user'] as Map<String, dynamic>?;
    if (token == null || userMap == null) {
      throw Exception('Malformed auth response');
    }
    final user = UserModel.fromMap(userMap);
    await persistToken(token);
    await persistUser(user);
    return {'token': token, 'user': user};
  }

  /// Get current user from backend (validates token)
  Future<UserModel> getCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('No token');

    final uri = Uri.parse('$baseUrl/auth/me');
    final resp = await _http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final userData = data['user'] ?? data;
      final user = UserModel.fromMap(userData);
      await persistUser(user);
      return user;
    } else if (resp.statusCode == 401) {
      await deleteToken();
      await deleteUser();
      throw Exception('Token expired');
    } else {
      throw Exception('Failed to get user: ${resp.statusCode} ${resp.body}');
    }
  }

  ///LOGOUT

  /// Complete logout - clears both token and user data
  Future<void> logout() async {
    await deleteToken();
    await deleteUser();
  }

  /// TOKEN VALIDATION

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored user if available (offline access)
  Future<UserModel?> getStoredUser() async {
    return await getUser();
  }
}