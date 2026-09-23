class Post {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return Post(
      id: _asInt(data['id']),
      title: _asString(data['title'], fallback: 'Untitled post'),
      body: _asString(data['body'], fallback: 'No content available.'),
    );
  }

  static int _asInt(Object? value) => value is num ? value.toInt() : 0;

  static String _asString(Object? value, {required String fallback}) {
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }
}