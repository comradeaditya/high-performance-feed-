import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

class PostRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch posts with pagination
  Future<List<Post>> fetchPosts({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await _supabase
          .from('posts_with_likes')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Toggle like for a post
    Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      print('Calling toggle_like with postId: $postId, userId: $userId');
      await _supabase.rpc('toggle_like', params: {
        'p_post_id': postId,
        'p_user_id': userId,
      });
      print('Like toggle successful!');
    } catch (e) {
      print('ERROR toggling like: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Check if user liked a post
  Future<bool> isPostLiked({
    required String postId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('user_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }
}