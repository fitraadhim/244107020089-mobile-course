String formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

String formatDateTime(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${formatDate(date)} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}

String parseNotificationRoute(
  Map<String, dynamic> data, {
  required String fallback,
}) {
  final route = data['route'];
  if (route is! String || route.isEmpty) return fallback;
  return route.startsWith('/') ? route : '/$route';
}