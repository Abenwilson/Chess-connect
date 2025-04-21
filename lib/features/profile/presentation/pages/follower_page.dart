/*
This page will display a tab bar
-list of followers
-lis of following
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/profile/presentation/component/user_tile.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  const FollowerPage(
      {super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: ConstrainedScaffold(
          appBar: AppBar(
            bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(
                  text: "followers",
                ),
                Tab(
                  text: "following",
                )
              ],
            ),
          ),
          body: TabBarView(children: [
            _buildUserList(followers, "no followers", context),
            _buildUserList(following, "no followings", context)
          ]),
        ));
  }

  //build UI List given a list Of profile
  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];
              return FutureBuilder(
                  future: context.read<ProfileCubits>().getUserProfile(uid),
                  builder: (context, snapshot) {
                    // userLoaded
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return UserTile(user: user);
                    }

                    //loading

                    else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text("Loading..."),
                      );
                    } else {
                      return ListTile(
                        title: Text("user loaded"),
                      );
                    }
                  });
            },
          );
  }
}
