import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

// Provider untuk instance Dio yang digunakan di seluruh aplikasi.
final dioProvider = Provider<Dio>((ref) => createDio());

// Repository disediakan melalui Riverpod agar mudah diakses dan di-test.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// AsyncNotifierProvider untuk state data komentar.
// State ini bisa berupa loading, data, atau error sesuai status request.
class CommentNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(1);
  }

  // Method ini digunakan untuk memuat ulang data dengan state loading dulu.
  Future<void> loadComments(int postId) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      // Error otomatis dibungkus ke AsyncError oleh Riverpod.
      state = AsyncError(e, st);
    }
  }
}

final commentProvider = AsyncNotifierProvider<CommentNotifier, List<Comment>>(
  CommentNotifier.new,
);

// Fungsi ini membuat pesan yang ramah bagi pengguna berdasarkan tipe error Dio.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis. Periksa jaringan Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Cek koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (404).';
        }
        if (statusCode == 500) {
          return 'Server sedang bermasalah (500). Coba lagi sebentar lagi.';
        }
        return 'Permintaan gagal (${statusCode ?? 'tidak diketahui'}).';
      default:
        return 'Terjadi kesalahan jaringan. Mohon coba lagi.';
    }
  }

  return 'Terjadi kesalahan yang tidak terduga.';
}
