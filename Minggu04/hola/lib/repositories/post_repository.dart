import 'package:dio/dio.dart';

import '../models/post.dart';
import '../services/api_client.dart';

class PostRepositoryException implements Exception {
  const PostRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class PostRepository {
  Future<List<Post>> fetchPosts({required int page, required int limit});
}

class DioPostRepository implements PostRepository {
  DioPostRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<Post>> fetchPosts({required int page, required int limit}) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );
      final data = response.data ?? const <dynamic>[];
      return data
          .map((item) => Post.fromJson(item is Map<String, dynamic> ? item : null))
          .toList();
    } on DioException catch (error) {
      throw PostRepositoryException(_messageFor(error));
    } catch (_) {
      throw const PostRepositoryException('Unexpected server response.');
    }
  }

  String _messageFor(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Check your connection.';
    }
    if (error.response?.statusCode != null) {
      return 'Server error (${error.response!.statusCode}).';
    }
    return 'Could not connect to the server.';
  }
}