import 'package:jamhubapp/data/providers/auth.dart';
import 'package:jamhubapp/auth/jamhub_auth.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid_value.dart';

final userSubscriptionsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final user = ref.watch(authNotifierProvider)!;
  try {
    return await locator<JamhubService>().getUserSubscriptionList(user);
  } catch (e) {
    if (e is AccessTokenExpiredException) {
      await locator<AuthService>().refresh(user);
      return await locator<JamhubService>().getUserSubscriptionList(user);
    }
    rethrow;
  }
});

final topSubscribedRoomsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final topRoomsList =
      await locator<JamhubService>().getTopSuscribedRoomsList();

  return topRoomsList;
});

final isUserSubscribedToRoomProvider = FutureProvider.family<bool, UuidValue>(
  (ref, roomID) async {
    final user = ref.watch(authNotifierProvider);

    final isSubscribed = await locator<JamhubService>()
        .checkIfUserSubscribedToRoom(user!, roomID);

    return isSubscribed;
  },
);
