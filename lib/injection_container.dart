import 'package:get_it/get_it.dart';
import 'package:jamhubapp/auth/jamhub_auth.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/data/spotify.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<SpotifyApiService>(SpotifyApiService());
  locator.registerSingleton<SpotifyAuth>(SpotifyAuth());
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<JamhubService>(JamhubService());
}
