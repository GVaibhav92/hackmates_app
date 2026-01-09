import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hackmates_app/features/auth/data/auth_repository.dart';
import 'package:hackmates_app/features/auth/models/post_model.dart';

class FeedRepository {
  FeedRepository({
    required this.baseUrl,
    required this.authRepository,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final AuthRepository authRepository;
  final http.Client _http;

  /// CREATE POST (multipart)
  Future<int> createPost({
    required String title,
    required String description,
    required String category,
    required List<File> images,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl/posts/');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'title': title,
      'description': description,
      'category': category,
    });

    for (final image in images) {
      final multipartFile = await http.MultipartFile.fromPath(
          'images', image.path);
      request.files.add(multipartFile);
    }

    try {
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final postId = data['post_id'] as int;
        return postId;
      } else {
        throw Exception('Failed to create post: ${resp.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// FETCH GLOBAL FEED
  Future<List<PostModel>> fetchPosts() async {
    final uri = Uri.parse('$baseUrl/feed');

    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final resp = await _http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final postsJson = data['posts'] as List;

      return postsJson
          .map((e) => PostModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }
}