import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const _apiKey = 'AIzaSyBpoQg6inP9I0eIt8dzUKDEBJ-33H19X3Q';

  static Future<Map<String, String>?> fetchThumbnail(String query) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=1&q=$query&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final video = data['items'][0];
      final videoId = video['id']['videoId'];
      final thumbnailUrl = video['snippet']['thumbnails']['high']['url'];
      return {
        'videoUrl': 'https://www.youtube.com/watch?v=$videoId',
        'thumbnailUrl': thumbnailUrl,
      };
    } else {
      return null;
    }
  }
}
