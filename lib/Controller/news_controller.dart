import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../Model/article_model.dart';

class NewsController extends GetxController {
  var _loading = false.obs;
  var articles = <ArticleModel>[].obs;
  var page = 1.obs;
  final int perPage = 15;

  Isolate? _imageIsolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  Completer<void>? _isolateReady;

  bool get isLoading => _loading.value;

  @override
  void onInit() {
    super.onInit();
    _initializeIsolate();
    fetchImages();
  }

  @override
  void onClose() {
    _terminateIsolate();
    super.onClose();
  }

  void _initializeIsolate() async {
    _receivePort = ReceivePort();
    _isolateReady = Completer<void>();

    _imageIsolate = await Isolate.spawn(_imageProcessingIsolate, _receivePort!.sendPort);

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isolateReady?.complete();
      } else if (message is List<ArticleModel>) {
        articles.addAll(message);
        page.value++;
      }
    });
  }

  void _terminateIsolate() {
    _imageIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
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

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['photos'] == null || (jsonData['photos'] as List).isEmpty) {
          throw Exception("No images found in API response.");
        }

        List<Map<String, dynamic>> rawPhotos =
        (jsonData['photos'] as List).cast<Map<String, dynamic>>();

        List<Map<String, String>> imageDetails = rawPhotos.map((photo) {
          return {
            'imageUrl': photo['src']['original'] as String,
            'photographer': photo['photographer'] as String,
            'description': photo['alt'] as String? ?? "No description",
          };
        }).toList();

        // Wait until isolate is ready
        await _isolateReady?.future;

        // Send image details (URLs, photographers, descriptions) to isolate for processing
        _sendPort?.send(imageDetails);
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

  /// **Isolate function for processing images**
  static void _imageProcessingIsolate(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is List<Map<String, String>>) {
        List<ArticleModel> processedArticles = [];

        // Fetch and process each image asynchronously to avoid blocking the isolate
        for (var imageDetail in message) {
          try {
            final url = imageDetail['imageUrl']!;
            final photographer = imageDetail['photographer']!;
            final description = imageDetail['description']!;

            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              processedArticles.add(
                ArticleModel(
                  photographer: photographer,
                  urlToImage: url,
                  title: description,
                ),
              );
            }
          } catch (e) {
            print("Error loading image: $e");
          }
        }

        sendPort.send(processedArticles);
      }
    });
  }
}
