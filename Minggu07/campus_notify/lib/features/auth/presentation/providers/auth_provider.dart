import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_store.dart';
import '../../../../data/api_errors.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  String? errorMessage;

  @override
  Future<bool> build() async {
    errorMessage = null;
    try {
      return await ref.watch(tokenStoreProvider).readAccess() != null;
    } on Exception catch (error) {
      errorMessage = apiErrorMessage(error);
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    errorMessage = null;
    state = const AsyncLoading();
    try {
      final session = await ref.read(loginProvider).call(
            email: email,
            password: password,
          );
      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
          );
      state = const AsyncData(true);
    } on DioException catch (error) {
      errorMessage = apiErrorMessage(error);
      state = const AsyncData(false);
    } on Exception catch (error) {
      errorMessage = apiErrorMessage(error);
      state = const AsyncData(false);
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    errorMessage = null;
    ref.invalidateSelf();
  }
}