import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/fcm_token_service.dart';

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider).refresh,
    onSessionExpired: () => ref.invalidate(authStateProvider),
  );
});

final fcmTokenServiceProvider = Provider<FcmTokenService>((ref) {
  return FcmTokenService(ref.watch(apiClientProvider));
});