class Post {
  final String id;
  final String mediaThumbUrl;
  final String mediaMobileUrl;
  final String mediaRawUrl;
  final int likeCount;
  final DateTime createdAt;
  final bool isLiked; // ✅ ADDED

  Post({
    required this.id,
    required this.mediaThumbUrl,
    required this.mediaMobileUrl,
    required this.mediaRawUrl,
    required this.likeCount,
    required this.createdAt,
    required this.isLiked, // ✅ ADDED
  });

  // Convert Supabase JSON to Post object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      mediaThumbUrl: json['media_thumb_url'] as String? ?? '',
      mediaMobileUrl: json['media_mobile_url'] as String? ?? '',
      mediaRawUrl: json['media_raw_url'] as String? ?? '',
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isLiked: json['is_liked'] as bool? ?? false, // ✅ ADDED
    );
  }

  // Convert Post to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_thumb_url': mediaThumbUrl,
      'media_mobile_url': mediaMobileUrl,
      'media_raw_url': mediaRawUrl,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      // ❌ DO NOT send isLiked to DB (it's computed)
    };
  }
}