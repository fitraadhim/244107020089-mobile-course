import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return _remote.login(email: email, password: password);
  }

  @override
  Future<String> refresh(String refreshToken) {
    return _remote.refresh(refreshToken);
  }
}