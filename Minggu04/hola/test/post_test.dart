import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hola/models/post.dart';
import 'package:hola/providers/post_provider.dart';
import 'package:hola/repositories/post_repository.dart';

class FakePostRepository implements PostRepository {
  FakePostRepository(this.pages);

  final Map<int, List<Post>> pages;
  final requestedPages = <int>[];

  @override
  Future<List<Post>> fetchPosts({required int page, required int limit}) async {
    requestedPages.add(page);
    return pages[page] ?? const [];
  }
}

void main() {
  test('Post.fromJson safely maps null and malformed fields', () {
    final post = Post.fromJson({'id': null, 'title': null, 'body': 42});

    expect(post.id, 0);
    expect(post.title, 'Untitled post');
    expect(post.body, 'No content available.');
  });

  test('provider loads pages and ignores duplicate pagination requests', () async {
    final firstPage = List.generate(
      pageSize,
      (index) => Post(id: index + 1, title: 'Post $index', body: 'Body'),
    );
    final fake = FakePostRepository({
      1: firstPage,
      2: [const Post(id: 11, title: 'Next', body: 'Body')],
    });
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(postListProvider.notifier);

    await notifier.loadInitial();
    await Future.wait([notifier.loadNextPage(), notifier.loadNextPage()]);

    expect(container.read(postListProvider).posts, hasLength(11));
    expect(fake.requestedPages, [1, 2]);
  });
}