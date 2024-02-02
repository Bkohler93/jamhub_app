import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/auth/service.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid_value.dart';

final userSubscriptionsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final jamHubService = ref.watch(jamhubServiceProvider);
  final user = ref.watch(authNotifierProvider)!;
  try {
    return await jamHubService.getUserSubscriptionList(user);
  } catch (e) {
    if (e is AccessTokenExpiredException) {
      await ref.read(authServiceProvider).refresh(user);
      return await jamHubService.getUserSubscriptionList(user);
    }
    rethrow;
  }
});

final topSubscribedRoomsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final jamhubService = ref.watch(jamhubServiceProvider);

  final topRoomsList = await jamhubService.getTopSuscribedRoomsList();

  return topRoomsList;
});

final isUserSubscribedToRoomProvider = FutureProvider.family<bool, UuidValue>(
  (ref, roomID) async {
    final jamhubService = ref.watch(jamhubServiceProvider);
    final user = ref.watch(authNotifierProvider);

    final isSubscribed =
        await jamhubService.checkIfUserSubscribedToRoom(user!, roomID);

    return isSubscribed;
  },
);
