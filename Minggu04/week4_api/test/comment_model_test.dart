import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson should handle missing fields safely', () {
    final comment = Comment.fromJson({
      'id': 7,
      // postId, name, email, body intentionally missing
    });

    expect(comment.postId, 0);
    expect(comment.id, 7);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
