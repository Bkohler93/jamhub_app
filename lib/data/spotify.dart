import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyInfo {
  final String songTitle;
  final String artistName;
  final String thumbnailUrl;

  SpotifyInfo(
      {required this.songTitle,
      required this.artistName,
      required this.thumbnailUrl});
}

class SpotifyApiService {
  Future<SpotifyInfo?> getTrackInfo(
      String spotifyUrl, String spotifyToken) async {
    try {
      // Extract the track ID from the Spotify URL
      String trackId = spotifyUrl.split("/").last.split("?").first;

      // Spotify API endpoint for retrieving track information
      String endpoint = "https://api.spotify.com/v1/tracks/$trackId";

      // Replace 'YOUR_ACCESS_TOKEN' with a valid Spotify access token
      // String accessToken = dotenv.get("SPOTIFY_TOKEN");

      // Make a GET request to the Spotify API
      http.Response response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $spotifyToken'},
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> trackInfo = json.decode(response.body);

        // Extract relevant information
        String songTitle = trackInfo['name'];
        String artistName = trackInfo['artists'][0]['name'];
        String thumbnailUrl = trackInfo['album']['images'][2]['url'];

        return SpotifyInfo(
          songTitle: songTitle,
          artistName: artistName,
          thumbnailUrl: thumbnailUrl,
        );
      } else {
        // Handle errors
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      return null;
    }
  }
}
