import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../Model/article_model.dart';

class NewsController extends GetxController {
  var isLoading = false.obs;
  var articles = <ArticleModel>[].obs;
  var imageUrlsQueue = <String>[].obs; // Store image URLs
  var page = 1.obs;
  final int perPage = 10;
  var loadedImageUrls = <String>{}; // Store unique image URLs
  // Track the index of each image URL in the article list
  var imageUrlIndexMap = <String, int>{};

  Isolate? _imageIsolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  Completer<void>? _isolateReady;

  @override
  void onInit() {
    super.onInit();
    _initializeIsolate();
    fetchArticles();
  }

  @override
  void onClose() {
    _terminateIsolate();
    super.onClose();
  }

  void _initializeIsolate() async {
    _receivePort = ReceivePort();
    _isolateReady = Completer<void>();

    _imageIsolate = await Isolate.spawn(_imageFetcherIsolate, _receivePort!.sendPort);

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isolateReady?.complete();
      } else if (message is Map<String, dynamic>) {
        _attachImageToArticle(message);
      }
    });
  }

  void _terminateIsolate() {
    _imageIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
  }

  /// Fetch paginated articles & store image URLs
  Future<void> fetchArticles() async {
    if (isLoading.value) return;

    isLoading.value = true;
    final url = "https://api.pexels.com/v1/search?query=nature&per_page=$perPage&page=${page.value}";
    const headers = {
      "Authorization": "EC61aknqRfeFmQEt9Mnw3TvMWsF1fffp31ezEajpLW3suMGUt38Tifc3",
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['photos'] == null || (jsonData['photos'] as List).isEmpty) {
          throw Exception("No images found in API response.");
        }

        List<Map<String, dynamic>> rawPhotos =
        (jsonData['photos'] as List).cast<Map<String, dynamic>>();

        for (var i = 0; i < rawPhotos.length; i++) {
          String imageUrl = rawPhotos[i]['src']['original'];

          if (!loadedImageUrls.contains(imageUrl)) {
            loadedImageUrls.add(imageUrl);

            // Create an article entry with a blank image
            articles.add(ArticleModel(
              photographer: rawPhotos[i]['photographer'] as String,
              urlToImage: "",
              title: rawPhotos[i]['alt'] as String? ?? "No description",
            ));

            // Store the index mapping
            imageUrlIndexMap[imageUrl] = articles.length - 1;

            // Add image URL to queue
            imageUrlsQueue.add(imageUrl);
          }
        }

        page.value++; // Increment for next fetch

        await _isolateReady?.future;
        _sendNextImageToIsolate();
      } else {
        throw Exception("Failed to load metadata: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching metadata: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Send one image at a time to the isolate
  void _sendNextImageToIsolate() {
    if (_sendPort != null && imageUrlsQueue.isNotEmpty) {
      final imageUrl = imageUrlsQueue.removeAt(0);

      // If the image is not in the visible list anymore, discard it
      if (!imageUrlIndexMap.containsKey(imageUrl)) return;

      _sendPort!.send(imageUrl);
    }
  }

  /// Attach image URL to article once fetched
  void _attachImageToArticle(Map<String, dynamic> processedImage) {
    String imageUrl = processedImage['imageUrl'];

    int? index = imageUrlIndexMap[imageUrl];
    if (index != null && index < articles.length) {
      articles[index] = ArticleModel(
        photographer: articles[index].photographer,
        urlToImage: imageUrl,
        title: articles[index].title,
      );

      update([index]); // Update only the specific article
    }

    if (imageUrlsQueue.isNotEmpty) {
      _sendNextImageToIsolate();
    }
  }


  /// Isolate function to download images
  static void _imageFetcherIsolate(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is String) {
        try {
          final response = await http.get(Uri.parse(message));
          if (response.statusCode == 200) {
            sendPort.send({"imageUrl": message});
          }
        } catch (e) {
          print("Error fetching image: $e");
        }
      }
    });
  }

}
