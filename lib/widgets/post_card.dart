import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCardTap;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeTap,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (300 * devicePixelRatio).toInt();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onCardTap, // 🔥 full card clickable
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25, // 🔥 heavier for GPU test
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 HERO IMAGE
              Hero(
                tag: post.id, // ✅ FIXED TAG
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: post.mediaThumbUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,

                    // 🔥 PERFECT MEMORY MATCH
                    memCacheWidth: cacheSize,
                    memCacheHeight: cacheSize,

                    placeholder: (context, url) => Container(
                      height: 300,
                      color: Colors.grey,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),

              // 🔥 INFO SECTION
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIKE BUTTON
                    GestureDetector(
                      onTap: onLikeTap,
                      child: Row(
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                isLiked ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$likeCount likes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // TIMESTAMP
                    Text(
                      'Posted ${post.createdAt.toString().split('.')[0]}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}