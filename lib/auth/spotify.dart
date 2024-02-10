import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpotifyAuth {
  late String _accessToken;

  String get accessToken => _accessToken;

  SpotifyAuth() {
    // Initialize the provider by fetching the access token
    _fetchAccessToken();
  }

  Future<void> _fetchAccessToken() async {
    try {
      String clientId = dotenv.get("SPOTIFY_ID");
      String clientSecret = dotenv.get("SPOTIFY_SECRET");
      String base64Encoded =
          base64.encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $base64Encoded',
        },
        body: {'grant_type': 'client_credentials'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _accessToken = data['access_token'];
      } else {
        throw Exception('Failed to get Spotify access token');
      }
    } catch (e) {
      // Handle exceptions
      print('Error while fetching access token: $e');
    }
  }
}
