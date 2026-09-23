import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../repositories/post_repository.dart';

const pageSize = 10;

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return DioPostRepository();
});

final postListProvider = NotifierProvider<PostListNotifier, PostListState>(
  PostListNotifier.new,
);

class PostListState {
  const PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorMessage,
  });

  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? errorMessage;

  PostListState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PostListNotifier extends Notifier<PostListState> {
  late final PostRepository _repository;
  int _page = 0;

  @override
  PostListState build() {
    _repository = ref.watch(postRepositoryProvider);
    return const PostListState();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    _page = 1;
    state = const PostListState(isLoading: true);
    try {
      final posts = await _repository.fetchPosts(page: _page, limit: pageSize);
      state = PostListState(posts: posts, hasReachedEnd: posts.length < pageSize);
    } on PostRepositoryException catch (error) {
      state = PostListState(errorMessage: error.message);
    } catch (_) {
      state = const PostListState(errorMessage: 'Could not load posts.');
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = _page + 1;
      final posts = await _repository.fetchPosts(page: nextPage, limit: pageSize);
      _page = nextPage;
      state = state.copyWith(
        posts: [...state.posts, ...posts],
        isLoadingMore: false,
        hasReachedEnd: posts.length < pageSize,
      );
    } on PostRepositoryException catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more posts.',
      );
    }
  }
}