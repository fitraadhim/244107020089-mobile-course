import '../../domain/entities/auth_session.dart';

class AuthRemoteDataSource {
  Future<AuthSession> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!email.contains('@') || password.length < 6) {
      throw const FormatException('Email atau kata sandi tidak valid');
    }

    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}