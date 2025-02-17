import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../Model/article_model.dart';

class NewsController extends GetxController {
  var _loading = false.obs;
  var articles = <ArticleModel>[].obs;
  var page = 1.obs;
  final int perPage = 6;

  bool get isLoading => _loading.value;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  Future<void> fetchImages() async {
    if (_loading.value) return;

    _loading.value = true;
    final url =
        "https://api.pexels.com/v1/search?query=nature&per_page=$perPage&page=${page.value}";
    const headers = {
      "Authorization": "EC61aknqRfeFmQEt9Mnw3TvMWsF1fffp31ezEajpLW3suMGUt38Tifc3",
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> rawPhotos = List<Map<String, dynamic>>.from(jsonData['photos']);

        if (rawPhotos.isEmpty) {
          throw Exception("No images found in API response.");
        }

        // Convert to simple list before sending to isolate
        List<String> jsonList = rawPhotos.map((e) => jsonEncode(e)).toList();

        // Use compute() safely
        List<ArticleModel> fetchedArticles = await compute(_processImages, jsonList);

        if (fetchedArticles.isNotEmpty) {
          articles.addAll(fetchedArticles);
          page.value++;
        }
      } else {
        throw Exception("Failed to load images: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching images: $e");
    } finally {
      _loading.value = false;
      update();
    }
  }

  // Updated Isolate function
  static List<ArticleModel> _processImages(List<String> jsonList) {
    try {
      return jsonList.map((jsonString) {
        Map<String, dynamic> photo = jsonDecode(jsonString);
        return ArticleModel(
          photographer: photo['photographer'] ?? "Unknown",
          urlToImage: photo['src']['original'] ?? "",
          title: photo['alt'] ?? "No title",
        );
      }).toList();
    } catch (e) {
      print("Error processing images in isolate: $e");
      return [];
    }
  }

}
