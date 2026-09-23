import 'package:dio/dio.dart';

import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  // Repository ini bertugas mengambil data komentar dari JSONPlaceholder.
  // Method fetchComments menerima postId agar data yang diambil sesuai postingan tertentu.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: const Options(
        sendTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      ),
    );

    // response.data bisa null bila server tidak mengirim data; maka kita pakai list kosong.
    final data = response.data ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
