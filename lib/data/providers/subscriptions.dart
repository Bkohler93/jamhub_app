import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/data/service.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:riverpod/riverpod.dart';

final userSubscriptionsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final jamHubService = ref.watch(jamhubServiceProvider);
  final user = ref.watch(authNotifierProvider)!;

  final userSubslist = await jamHubService.getUserSubscriptionList(user);

  return userSubslist;
});

final topSubscribedRoomsProvider =
    FutureProvider<List<SubscriptionData>>((ref) async {
  final jamhubService = ref.watch(jamhubServiceProvider);

  final topRoomsList = await jamhubService.getTopSuscribedRoomsList();

  return topRoomsList;
});


