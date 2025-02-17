import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlogTile extends StatelessWidget {
  final String photographer;
  final String title;
  final String? imageUrl; // Nullable for safety

  const BlogTile({
    required this.photographer,
    required this.imageUrl,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image with Loading & Error Handling
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? '', // Ensuring safe null handling
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    // placeholder: (context, url) => Container(
                    //   height: 150,
                    //   width: 150,
                    //   color: Colors.grey[300],
                    //   child: Center(child: CircularProgressIndicator()),
                    // ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      width: 150,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.red, size: 30),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),

                // ✅ Title & Photographer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 7.0),
                      Text(
                        "By $photographer",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
        ),
      ),
    );
  }
}
