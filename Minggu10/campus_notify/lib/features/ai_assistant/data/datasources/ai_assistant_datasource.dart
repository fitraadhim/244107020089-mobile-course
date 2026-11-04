import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiAssistantDataSource {
  AiAssistantDataSource({required this._client, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _apiKeyName = 'ai_api_key';
  static const _configuredApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-3.8-flash:generateContent';
  static const systemPrompt = '''
Kamu adalah Campus Assistant yang ramah. Jawab dalam Bahasa Indonesia,
maksimal tiga kalimat, hanya berdasarkan informasi yang diberikan pengguna.
Jangan meminta atau mengungkap password, token, NIM, alamat, atau data pribadi.
Jika tidak tahu, katakan bahwa informasi belum tersedia.
''';

  final Dio _client;
  final FlutterSecureStorage _storage;

  Future<String?> readApiKey() async {
    if (_configuredApiKey.isNotEmpty) return _configuredApiKey;
    return _storage.read(key: _apiKeyName);
  }

  Future<void> saveApiKey(String apiKey) async {
    final normalizedKey = apiKey.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError('API key tidak boleh kosong.');
    }
    await _storage.write(key: _apiKeyName, value: normalizedKey);
  }

  Future<String> ask(String question, String apiKey) async {
    final response = await _client.post<Object?>(
      '$_endpoint?key=$apiKey',
      options: Options(
        headers: const {'Content-Type': 'application/json'},
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 10),
      ),
      data: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': question},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 180},
      }),
    );

    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respons Gemini tidak valid.');
    }
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const FormatException('Respons AI kosong atau tidak valid.');
    }
    return text.trim();
  }
}
