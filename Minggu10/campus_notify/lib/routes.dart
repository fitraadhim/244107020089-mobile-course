import 'core/format.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcements = '/pengumuman';
  static const announcement = '/pengumuman/:id';
  static const aiAssistant = '/ai-assistant';

  static String announcementById(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  return parseNotificationRoute(data, fallback: AppRoutes.home);
}
