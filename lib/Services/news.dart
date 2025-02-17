// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../Model/article_model.dart';
//
// class News {
//   List<ArticleModel> news = [];
//
//   Future<void> getNews() async {
//     String url = "https://newsapi.org/v2/everything?q=tesla&from=2025-01-14&sortBy=publishedAt&apiKey=d2646ef2946847309cd5b1d837830f2e";
//     var response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         jsonData["articles"].forEach((element) {
//           if (element["urlToImage"] != null && element['description'] != null) {
//             ArticleModel articleModel = ArticleModel(
//               title: element["title"],
//               description: element["description"],
//               url: element["url"],
//               urlToImage: element["urlToImage"],
//               content: element["content"],
//               author: element["author"],
//             );
//             news.add(articleModel);
//           }
//         });
//
//         print("Fetched ${news.length} articles");
//       } else {
//         print("Error fetching articles");
//       }
//     } else {
//       print("Failed to load data: ${response.statusCode}");
//     }
//   }
// }


