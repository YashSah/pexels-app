import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Controller/news_controller.dart';
import 'Widgets/blog_tile.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsController newsController = Get.put(NewsController());
  late ScrollController scrollController;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200 && !newsController.isLoading) {
        // ✅ Debounce scrolling: Fetch data only if scrolling stops for 500ms
        _fetchTimer?.cancel();
        _fetchTimer = Timer(Duration(milliseconds: 500), () {
          newsController.fetchImages();
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _fetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pexels"),
            Text(
              "App",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newsController.page.value = 1; // Reset page
          newsController.articles.clear(); // Clear previous data
          newsController.fetchImages(); // Reload data
        },
        child: Icon(Icons.refresh),
      ),
      body: Obx(() {
        if (newsController.isLoading && newsController.articles.isEmpty) {
          return Center(child: CircularProgressIndicator()); // Initial loading
        } else if (newsController.articles.isEmpty) {
          return Center(child: Text("No images found"));
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: newsController.isLoading
              ? newsController.articles.length + 1
              : newsController.articles.length,
          itemBuilder: (context, index) {
            if (index == newsController.articles.length) {
              return newsController.isLoading
                  ? Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                ),
              ) : SizedBox(); // Don't show anything if not loading
            }

            var article = newsController.articles[index];

            return BlogTile(
              photographer: article.photographer ?? "Unknown Photographer",
              imageUrl: article.urlToImage ?? "",
              title: article.title ?? "No Title",
            );
          },
        );
      }),
    );
  }
}
