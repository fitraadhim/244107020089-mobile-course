import 'package:dio/dio.dart';

import '../core/network/api_client.dart' as core;
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  void Function()? onSessionExpired,
  HttpClientAdapter? httpClientAdapter,
}) {
  return core.buildApiClient(
    store,
    auth.refresh,
    onSessionExpired: onSessionExpired,
    httpClientAdapter: httpClientAdapter,
  );
}
