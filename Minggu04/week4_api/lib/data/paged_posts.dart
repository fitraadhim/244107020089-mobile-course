import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/post.dart';
import 'providers.dart';

const _maxPostsToLoad = 100;

class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    final repository = ref.read(postRepositoryProvider);
    try {
      final items = await repository.fetchPostsPage(
        page: 1,
        limit: _maxPostsToLoad,
      );
      state = PagedPostsState(
        items: items,
        page: 1,
        hasMore: items.length >= _maxPostsToLoad,
      );
    } catch (e) {
      state = PagedPostsState(error: e);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    if (state.items.length >= _maxPostsToLoad) {
      state = PagedPostsState(
        items: state.items,
        page: state.page,
        hasMore: false,
      );
      return;
    }

    final repo = ref.read(postRepositoryProvider);
    final currentItems = state.items;
    final currentPage = state.page;
    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );
    try {
      final next = currentPage + 1;
      final remaining = _maxPostsToLoad - currentItems.length;
      final items = await repo.fetchPostsPage(
        page: next,
        limit: remaining,
      );
      final merged = [...currentItems, ...items];
      state = PagedPostsState(
        items: merged,
        page: next,
        hasMore: merged.length < _maxPostsToLoad && items.isNotEmpty,
      );
    } catch (e) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        error: e,
      );
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
        PagedPostsNotifier.new);