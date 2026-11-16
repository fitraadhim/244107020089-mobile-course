import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../features/announcements/presentation/pages/announcements_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../pages/home_page.dart';
import '../routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final loggedIn = authAsync.value ?? false;

  return GoRouter(
    redirect: (context, state) {
      final goingLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (_, _) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (_, state) => AnnouncementDetailPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
});