import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class BlogTile extends StatefulWidget {
  final String photographer;
  final String title;
  final String imageUrl;

  const BlogTile({
    required this.photographer,
    required this.imageUrl,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  _BlogTileState createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Do not keep items loaded when offscreen

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
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
                      child: Center(child: Icon(Icons.broken_image, color: Colors.red, size: 30)),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
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
                        "By ${widget.photographer}",
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
