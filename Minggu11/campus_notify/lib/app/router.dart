import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../features/announcements/presentation/pages/announcements_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../pages/home_page.dart';
import '../routes.dart';

/// Router aplikasi dibuat SATU KALI untuk sepanjang siklus hidup aplikasi.
///
/// Sebelumnya provider ini melakukan `ref.watch(authStateProvider)`, jadi
/// setiap perubahan status auth membuat instance GoRouter baru. Akibatnya
/// seluruh Navigator, stack halaman, dan widget di dalamnya dibangun ulang
/// dari nol setiap kali status auth berubah (termasuk saat token di-refresh).
///
/// Sekarang perubahan status auth hanya mengubah nilai [authListenable],
/// sehingga GoRouter cukup mengevaluasi ulang aturan redirect tanpa
/// membangun ulang stack navigasi.
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<bool>(
    ref.read(authStateProvider).value ?? false,
  );

  ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
    final loggedIn = next.value ?? false;
    if (authListenable.value != loggedIn) {
      authListenable.value = loggedIn;
    }
  });
  ref.onDispose(authListenable.dispose);

  return GoRouter(
    refreshListenable: authListenable,
    redirect: (context, state) {
      final goingLogin = state.matchedLocation == AppRoutes.login;
      if (!authListenable.value && !goingLogin) return AppRoutes.login;
      if (authListenable.value && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (_, _) => const AnnouncementsPage(),
        // Detail adalah sub-route dari daftar, bukan route terpisah.
        // Dengan begitu stack navigasi home > daftar > detail terbentuk
        // dan tombol "back" kembali ke daftar (bukan keluar aplikasi).
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => AnnouncementDetailPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
});
