import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // Infinite scroll listener
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        ref.read(feedProvider.notifier).loadMorePosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    // Initial loading state
    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(feedProvider.notifier).refreshPosts(),
        child: ListView.builder(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount:
              feedState.posts.length + (feedState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Loader at bottom
            if (index == feedState.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final post = feedState.posts[index];

            // Like state (separate provider)
            final likeState = ref.watch(postLikeProvider(post));

            return PostCard(
              post: post,
              isLiked: likeState.isLiked,
              likeCount: likeState.likeCount,

              // Like button action
              onLikeTap: () async {
                try {
                  await ref
                      .read(postLikeProvider(post).notifier)
                      .toggleLike();
                } catch (e) {
                  // Offline revert message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("No internet. Action reverted."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },

              // Navigate to detail screen
              onCardTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(post: post),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}