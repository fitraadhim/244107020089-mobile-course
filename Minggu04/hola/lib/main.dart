import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers/post_provider.dart';

void main() => runApp(const ProviderScope(child: PostsApp()));

class PostsApp extends StatelessWidget {
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PostsPage(),
    );
  }
}

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key});

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postListProvider.notifier).loadInitial();
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      ref.read(postListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Post Explorer')),
      body: _PostsBody(state: state, onRetry: _retry, scrollController: _scrollController),
    );
  }

  Future<void> _retry() => ref.read(postListProvider.notifier).loadInitial();
}

class _PostsBody extends StatelessWidget {
  const _PostsBody({required this.state, required this.onRetry, required this.scrollController});

  final PostListState state;
  final Future<void> Function() onRetry;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.posts.isEmpty) {
      return _MessageState(message: state.errorMessage!, actionLabel: 'Retry', onPressed: onRetry);
    }
    if (state.posts.isEmpty) return const _MessageState(message: 'No posts found.');
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _PostTile(post: state.posts[index]);
        },
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('${post.id}')),
        title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(post.body, maxLines: 3, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.actionLabel, this.onPressed});

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}