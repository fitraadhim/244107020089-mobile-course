import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/ai_reply.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/ai_assistant_datasource.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  const AiAssistantRepositoryImpl(this._dataSource);

  final AiAssistantDataSource _dataSource;

  @override
  Future<AiReply> ask(String question) async {
    final apiKey = await _dataSource.readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return AiReply(text: _offlineReply(question), fromFallback: true);
    }

    try {
      return AiReply(
        text: await _dataSource.ask(question, apiKey),
        fromFallback: false,
      );
    } on DioException catch (error) {
      final failure = NetworkFailure(_dioFailureMessage(error));
      return AiReply(
        text: '${failure.message}\nMode offline digunakan sebagai gantinya.',
        fromFallback: true,
      );
    } on FormatException catch (error) {
      return AiReply(
        text: '${error.message}\nMode offline digunakan sebagai gantinya.',
        fromFallback: true,
      );
    }
  }

  String _dioFailureMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return 'API key Gemini tidak valid atau belum diizinkan.';
    }
    if (statusCode == 404) {
      return 'Model Gemini tidak tersedia pada endpoint ini.';
    }
    if (statusCode == 429) {
      return 'Batas penggunaan Gemini tercapai. Coba lagi nanti.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke layanan Gemini. Periksa internet.';
    }
    return 'Layanan Gemini sedang tidak tersedia.';
  }

  String _offlineReply(String question) {
    final normalized = question.toLowerCase();
    if (normalized.contains('jadwal')) {
      return 'Mode offline: cek menu pengumuman untuk informasi jadwal kampus.';
    }
    if (normalized.contains('pengumuman')) {
      return 'Mode offline: daftar pengumuman tersedia di halaman Pengumuman.';
    }
    return 'Mode offline aktif. Atur API key AI untuk mendapatkan jawaban '
        'yang lebih lengkap.';
  }
}
