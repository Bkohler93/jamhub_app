import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/data/providers/subscriptions.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/screens/create_room.dart';
import 'package:jamhubapp/screens/login.dart';
import 'package:jamhubapp/screens/room.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends ConsumerState {
  int tappedIndex = -1;
  String tappedSection = "";

  Widget roomList(AsyncValue<List<SubscriptionData>> data, BuildContext context,
      String sectionName) {
    return SizedBox(
      height: 20.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: data.when(
            data: (subList) => List.generate(
                subList.length,
                (i) => GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          tappedSection = sectionName;
                          tappedIndex = i;
                        });
                      },
                      onTap: () {
                        setState(() {
                          tappedSection = "";
                          tappedIndex = -1;
                        });
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => RoomPage(
                                  roomID: subList[i].roomID,
                                  roomName: subList[i].roomName,
                                )));
                      },
                      onTapCancel: () {
                        setState(() {
                          tappedSection = "";
                          tappedIndex = -1;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        height: 5.0.h,
                        width: 20.0.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: tappedIndex == i &&
                                  tappedSection == sectionName
                              ? Theme.of(context).primaryColorDark
                              : Theme.of(context)
                                  .primaryColor, // Replace with your desired color
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(
                                  0, 3), // Offset in the x, y direction
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            subList[i].roomName,
                            style: const TextStyle(
                                color: Colors.white), // Text color
                          ),
                        ),
                      ),
                    )),
            error: (err, stack) => List.generate(
                1,
                (n) => SizedBox(
                    height: 5.0.h,
                    width: 20.0.h,
                    child: const Text("You aren't subscribed to any rooms yet!"))),
            loading: () => List.generate(
                3,
                (n) => SizedBox(
                    height: 5.0.h,
                    width: 20.0.h,
                    child: const CircularProgressIndicator()))),
      ),
    );
  }

  void Function() handleAddRoom(BuildContext context) {
    return () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const CreateRoomPage()));
    };
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<SubscriptionData>> personalRoomsList =
        ref.watch(userSubscriptionsProvider);
    final AsyncValue<List<SubscriptionData>> topRoomsList =
        ref.watch(topSubscribedRoomsProvider);

    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: handleAddRoom(context),
        icon: Container(
          decoration: BoxDecoration(
              color: Colors.lightGreen[100],
              borderRadius: BorderRadius.circular(8)),
          height: 5.h,
          width: 5.h,
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LoginPage();
                    },
                  ),
                );
              },
              child: const Text("Logout"))
        ],
        title: const Text("JamHub"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Your Rooms",
            style: TextStyle(fontSize: 28),
          ),
          roomList(personalRoomsList, context, "userRooms"),
          const Text("Top Rooms", style: TextStyle(fontSize: 28)),
          roomList(topRoomsList, context, "topRooms"),
        ]),
      ),
    );
  }
}
