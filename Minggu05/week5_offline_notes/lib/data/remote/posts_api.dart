import 'dart:convert';

import 'package:http/http.dart' as http;

import '../local/note.dart';

class PostsApi {
  PostsApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Post>> fetchPosts() async {
    final response = await _client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil posts (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
