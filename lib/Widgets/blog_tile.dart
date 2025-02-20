import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlogTile extends StatefulWidget {
  final String photographer;
  final String imageUrl;
  final String title;

  const BlogTile({required this.photographer, required this.imageUrl, required this.title, Key? key}) : super(key: key);

  @override
  _BlogTileState createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Do not persist images
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required when using KeepAlive
    return VisibilityDetector(
      key: ValueKey(widget.imageUrl),
      onVisibilityChanged: (info) {
        if (mounted) {
          bool isNowVisible = info.visibleFraction > 0.1;
          if (isNowVisible != _isVisible) {
            setState(() {
              _isVisible = isNowVisible;
            });
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 150,
                width: 140,
                child: _isVisible
                    ? CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  memCacheHeight: 2000, // Adjusted for better memory handling
                )
                    : Container(color: Colors.grey[300]), // Empty placeholder when out of view
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 7.0),
                  Text(
                    "By ${widget.photographer}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

