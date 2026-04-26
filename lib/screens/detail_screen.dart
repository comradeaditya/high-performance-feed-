import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isHdLoaded = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    // Start loading HD image in background
    _loadHdImage();
  }

  Future<void> _loadHdImage() async {
    final image = CachedNetworkImageProvider(widget.post.mediaMobileUrl);

    await precacheImage(image, context);

    if (mounted) {
      setState(() {
        isHdLoaded = true;
      });
    }
  }

  Future<void> _downloadHighRes() async {
    setState(() => isDownloading = true);

    try {
      // Simulate download (you can replace with actual download logic)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("High-resolution image downloaded"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download failed"),
        ),
      );
    }

    if (mounted) {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (1080 * devicePixelRatio).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: Column(
        children: [
          // 🔥 HERO + TIERED LOADING
          Hero(
            tag: widget.post.id, // MUST match PostCard
            child: Stack(
              children: [
                // 🟡 Thumbnail (instant display)
                CachedNetworkImage(
                  imageUrl: widget.post.mediaThumbUrl,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheSize ~/ 4, // smaller for thumb
                ),

                // 🟢 HD Image (fade in)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isHdLoaded ? 1 : 0,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.mediaMobileUrl,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    memCacheWidth: cacheSize,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔽 DOWNLOAD BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: isDownloading ? null : _downloadHighRes,
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                isDownloading
                    ? "Downloading..."
                    : "Download High-Res",
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 📝 POST INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Posted on ${widget.post.createdAt.toString().split('.')[0]}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}