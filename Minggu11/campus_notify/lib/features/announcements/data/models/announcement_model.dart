import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;

  factory AnnouncementModel.fromMap(Map<String, Object?> map) {
    return AnnouncementModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      publishedAt: DateTime.tryParse(map['published_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        publishedAt: publishedAt,
      );
}