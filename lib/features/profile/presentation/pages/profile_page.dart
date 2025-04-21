import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_states.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';
import 'package:photographers/features/post/presentation/cubits/post_states.dart';
import 'package:photographers/features/profile/presentation/component/bio_box.dart';
import 'package:photographers/features/profile/presentation/component/follow_Button.dart';
import 'package:photographers/features/profile/presentation/component/prof_box.dart';
import 'package:photographers/features/profile/presentation/component/profile_stats.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_states.dart';
import 'package:photographers/features/profile/presentation/pages/edit_profile.dart';
import 'package:photographers/features/profile/presentation/pages/follower_page.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';
import 'package:timeago/timeago.dart' as timeago;

class Profile extends StatefulWidget {
  final String uid;
  const Profile({super.key, required this.uid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final authcubit = context.read<AuthCubit>();
  late final profilecubits = context.read<ProfileCubits>();

// current user
  late AppUser? currentUser = authcubit.currentUser;

  int postCount = 0;

  late AppUser? currentuser = authcubit.currentUser;
// load profile page  this part connecting next page

  @override
  void initState() {
    super.initState();
    // load profile page and user data
    profilecubits.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() async {
    final profileState = profilecubits.state;
    if (profileState is! ProfileLoaded || currentUser == null) return;

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistically update ui
    setState(() {
      //unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      // follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });
    try {
      // perform actual toggle in cubits
      profilecubits.toggleFollow(currentUser!.uid, widget.uid);
    } catch (e) {
      // reverse update if there is an error
      setState(() {
        //unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        // follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    }
  }

//BUILD UI
  @override
  Widget build(BuildContext context) {
    // is own post
    bool isOwnPost =
        (widget.uid == currentUser!.uid); //It checks the own post or not//

    return BlocConsumer<ProfileCubits, ProfileStates>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {}); // Forces UI update
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          print('Profile Image URL: ${user.profileImagUrl}');

          return ConstrainedScaffold(
            //app bar
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                user.name,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              actions: [
                if (isOwnPost)
                  //edit porfile button
                  IconButton(
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EditProfile(user: user);
                        }));
                        // Ensure updated data is fetched
                        setState(() {
                          profilecubits.fetchUserProfile(widget.uid);
                        });
                      },
                      icon: Icon(Icons.edit))
              ],
            ),

            body: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: user.profileImagUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.person, size: 60),
                      fit: BoxFit.cover,
                      imageBuilder: (context, ImageProvider) => Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: ImageProvider, fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                // profile stats
                ProfileStats(
                  postCount: postCount,
                  followersCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowerPage(
                              followers: user.followers,
                              following: user.following))),
                ),
                // follow button
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),

                SizedBox(
                  height: 25,
                ),
                // bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: BioBox(
                    text: user.bio,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                //profession name
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Profession",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ProfBox(text: user.profession),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),

                SizedBox(
                  height: 20,
                ),
                //post
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Post",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  // list of posts from this user
                ),
                BlocConsumer<PostCubits, PostStates>(
                    listener: (context, state) {
                  if (state is ProfileLoaded) {
                    setState(() {}); // Forces UI update
                  }
                }, builder: (context, state) {
                  // post Loaded
                  if (state is PostLoaded) {
                    // filter post by user id
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();
                    // Move postCount inside setState
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        postCount = userPosts.length;
                      });
                    });

                    return ListView.builder(
                      itemCount: postCount,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final authState = context.read<AuthCubit>().state;

                        String? currentUserId;
                        if (authState is Authenticated) {
                          currentUserId = authState.user.uid;
                        }

                        final post = userPosts[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    timeago.format(post.timeStamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (post.userId == currentUserId)
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Delete Post"),
                                            content:
                                                const Text("Are you sure ?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<PostCubits>()
                                                      .deletePost(post.id);
                                                  Navigator.of(context).pop();
                                                  // Refresh profile posts after deletion
                                                  context
                                                      .read<PostCubits>()
                                                      .fetchAllposts();
                                                },
                                                child: const Text(
                                                  "Delete",
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.grey),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              // Post Image
                              CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                height: 400,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  height: 400,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    // Post Text
                                    if (post.text.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(post.text),
                                    ],

                                    Spacer(),
                                    // Likes
                                    Icon(Icons.favorite_sharp,
                                        color: Colors.grey, size: 18),
                                    SizedBox(width: 5),
                                    Text(
                                      post.likes.length
                                          .toString(), // Display likes count
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    SizedBox(width: 15),

                                    // Comments
                                    Icon(Icons.comment,
                                        color: Colors.grey, size: 18),
                                    SizedBox(width: 5),
                                    Text(
                                      post.comments.length
                                          .toString(), // Display comments count
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  // posts loading
                  else if (state is PostLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text("no posts.."),
                    );
                  }

                  // post load
                })
              ],
            ),
          );

          //scafold
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Text("no profile found");
        }
      },
    );
  }
}
