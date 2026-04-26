import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

final postRepositoryProvider = Provider((ref) => PostRepository());

const String currentUserId = 'user_123';

class PostLikeState {
  final String postId;
  final bool isLiked;
  final int likeCount;

  PostLikeState({
    required this.postId,
    required this.isLiked,
    required this.likeCount,
  });

  PostLikeState copyWith({
    bool? isLiked,
    int? likeCount,
  }) {
    return PostLikeState(
      postId: postId,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

final postLikeProvider =
    StateNotifierProvider.family<PostLikeNotifier, PostLikeState, Post>(
        (ref, post) {
  final repository = ref.watch(postRepositoryProvider);
  return PostLikeNotifier(repository, post);
});

class PostLikeNotifier extends StateNotifier<PostLikeState> {
  final PostRepository _repository;

  PostLikeNotifier(this._repository, Post post)
      : super(PostLikeState(
          postId: post.id,
          isLiked: false,
          likeCount: post.likeCount,
        )) {
    _initializeLikeState();
  }

  Future<void> _initializeLikeState() async {
    final isLiked = await _repository.isPostLiked(
      postId: state.postId,
      userId: currentUserId,
    );
    state = state.copyWith(isLiked: isLiked);
  }

  Future<void> toggleLike() async {
    final previousIsLiked = state.isLiked;
    final previousLikeCount = state.likeCount;

    final newIsLiked = !state.isLiked;
    final newLikeCount =
        newIsLiked ? state.likeCount + 1 : state.likeCount - 1;

    state = state.copyWith(
      isLiked: newIsLiked,
      likeCount: newLikeCount,
    );

    try {
      await _repository.toggleLike(
        postId: state.postId,
        userId: currentUserId,
      );
    } catch (e) {
      state = state.copyWith(
        isLiked: previousIsLiked,
        likeCount: previousLikeCount,
      );
      rethrow;
    }
  }
}

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final int offset;

  FeedState({
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.offset,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    int? offset,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return FeedNotifier(repository);
});

class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _repository;
  static const int pageSize = 10;

  FeedNotifier(this._repository)
      : super(FeedState(
          posts: [],
          isLoading: false,
          hasMore: true,
          offset: 0,
        )) {
    loadMorePosts();
  }

  Future<void> loadMorePosts() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newPosts = await _repository.fetchPosts(
        limit: pageSize,
        offset: state.offset,
      );

      print('Loaded ${newPosts.length} new posts');

      final hasMore = newPosts.length == pageSize;

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        offset: state.offset + pageSize,
        hasMore: hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading posts: $e');
    }
  }

  Future<void> refreshPosts() async {
    state = state.copyWith(
      posts: [],
      offset: 0,
      hasMore: true,
      isLoading: true,
    );

    try {
      final newPosts = await _repository.fetchPosts(
        limit: pageSize,
        offset: 0,
      );

      final hasMore = newPosts.length == pageSize;

      state = state.copyWith(
        posts: newPosts,
        offset: pageSize,
        hasMore: hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error refreshing posts: $e');
    }
  }
}