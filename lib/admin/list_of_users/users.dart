import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_states.dart';
import 'package:photographers/features/profile/presentation/pages/profile_page.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubits>().fetchAllUsers(); // Fetch all users
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context
                  .read<ProfileCubits>()
                  .fetchAllUsers(); // Fetch users before leaving
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: const Text("User List",
              style: TextStyle(
                fontSize: 18,
              ))),
      body: BlocBuilder<ProfileCubits, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllUsersLoaded) {
            final users = state.users;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "T O T A L   U S E R S: ${users.length}",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text("${user.email} (${user.profession})"),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: user.profileImagUrl.isNotEmpty
                              ? CachedNetworkImageProvider(user.profileImagUrl)
                              : null,
                          child: user.profileImagUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.white)
                              : null,
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(uid: user.uid))),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("No users found"));
        },
      ),
    );
  }
}
