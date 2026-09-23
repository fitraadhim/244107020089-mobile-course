import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'paged_posts.dart';
import 'providers.dart';

Post? _findPostById(List<Post> posts, int id) {
  for (final post in posts) {
    if (post.id == id) return post;
  }
  return null;
}

final postDetailProvider = FutureProvider.family<Post?, int>((ref, postId) async {
  final listState = ref.watch(postListProvider);
  final cachedFromList = listState.maybeWhen(
    data: (posts) => posts,
    orElse: () => const <Post>[],
  );
  final cachedFromListResult = _findPostById(cachedFromList, postId);
  if (cachedFromListResult != null) return cachedFromListResult;

  final cachedFromPaged = ref.watch(pagedPostsProvider).items;
  final cachedFromPagedResult = _findPostById(cachedFromPaged, postId);
  if (cachedFromPagedResult != null) return cachedFromPagedResult;

  final repository = ref.read(postRepositoryProvider);
  final fetchedPosts = await repository.fetchPosts();
  return _findPostById(fetchedPosts, postId);
});
