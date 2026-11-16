import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../messaging/push_service.dart';

class FcmTokenService {
  const FcmTokenService(this._dio);

  final Dio _dio;

  Future<void> register(String token) async {
    fcmTokenNotifier.value = token.length > 12
        ? '${token.substring(0, 12)}...'
        : token;

    try {
      await _dio.post(
        '/devices',
        data: {
          'fcm_token': token,
          'platform': _platformName(),
        },
      );
    } on DioException catch (error) {
      debugPrint(
        'FCM token registration failed '
        '(type: ${error.type}, status: ${error.response?.statusCode ?? 'none'}).',
      );
    }
  }

  String _platformName() => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        _ => 'unknown',
      };
}