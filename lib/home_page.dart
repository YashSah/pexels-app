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
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!newsController.isLoading.value && _fetchTimer == null) {
        _fetchTimer = Timer(Duration(milliseconds: 500), () {
          newsController.fetchArticles();
          _fetchTimer = null;
        });
      }
    }
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     newsController.page.value = 1; // Reset page
      //     newsController.articles.clear(); // Clear previous data
      //
      //     // Ensure UI updates before fetching new articles
      //     newsController.isLoading.value = true;
      //
      //     await newsController.fetchArticles();
      //     newsController.update();
      //   },
      //   child: Icon(Icons.refresh),
      // ),
      body: Obx(() {
        if (newsController.isLoading.value && newsController.articles.isEmpty) {
          return Center(child: CircularProgressIndicator()); // Initial loading
        } else if (newsController.articles.isEmpty) {
          return Center(child: Text("No articles available")); // Better empty state handling
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: newsController.articles.length + (newsController.isLoading.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == newsController.articles.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            var article = newsController.articles[index];

            return BlogTile(
              key: ValueKey("${article.urlToImage}-$index"), // Ensuring unique keys
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
