import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/post/domain/entites/comment.dart';
import 'package:photographers/features/post/domain/entites/post.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';
import 'package:photographers/features/post/presentation/cubits/post_states.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/profile/presentation/pages/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatefulWidget {
  final Post post;

  final void Function()? onDeletePresssed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePresssed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postcubits = context.read<PostCubits>();
  late final profileCubits = context.read<ProfileCubits>();
  final TextEditingController commentTextController = TextEditingController();

  //  current user
  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user

  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getcurrentUser();
    fetchPostUser();
  }

  void getcurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    if (currentUser != null) {
      isOwnPost = widget.post.userId == currentUser!.uid;
    }
  }

  Future<void> fetchPostUser() async {
    final fetchUser = await profileCubits.getUserProfile(widget.post.userId);
    if (fetchUser != null && mounted) {
      setState(() {
        postUser = fetchUser;
      });
    }
  }

/*
Likes
*/
  void toggleLikePost() {
    if (currentUser == null) return; // Prevent crash
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); //unlike
      } else {
        widget.post.likes.add(currentUser!.uid); //like
      }
    });
    // update the like
    postcubits
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      //if there is an error reverse back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // revert values
        } else {
          widget.post.likes.remove(currentUser!.uid); //revert likes
        }
      });
    });
  }

  /*
 Comments
  */
  // comments text controller

  void openNewCommentBox() {
    final TextEditingController commentTextController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Comment input field

              const SizedBox(height: 10),

              // Display Comments Using BlocBuilder
              BlocBuilder<PostCubits, PostStates>(
                builder: (context, state) {
                  if (state is PostLoaded) {
                    final post =
                        state.posts.firstWhere((p) => p.id == widget.post.id);

                    if (post.comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("No comments yet, be the first!"),
                      );
                    }

                    return SizedBox(
                      height: 300, // Adjust height as needed
                      child: ListView.builder(
                        itemCount: post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];

                          return ListTile(
                            title: Text(
                              comment.userName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment.text),
                            trailing: currentUser?.uid == comment.userId
                                ? IconButton(
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                    ),
                                    onPressed: () =>
                                        showCommentOptions(comment.id),
                                  )
                                : null,
                          );
                        },
                      ),
                    );
                  } else if (state is PostLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PostErrors) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentTextController,
                      decoration: InputDecoration(
                        hintText: "Drop a comment ♡",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      addComment(commentTextController.text);
                      commentTextController.clear(); // Clear input
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }

  void addComment(String text) {
    if (currentUser == null || text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: text,
      timestamp: DateTime.now(),
    );

    postcubits.addComment(widget.post.id, newComment).then((_) {
      if (mounted) {
        setState(() {
          commentTextController.clear(); // Clear text safely
        });
      }
    }).catchError((e) {
      debugPrint("Error adding comment: $e");
    });
  }

  @override
  void dispose() {
    commentTextController.dispose(); // Properly disposing controller
    super.dispose();
  }
  // show options

  void showCommentOptions(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              postcubits.deleteComment(widget.post.id, commentId);
              Navigator.of(context).pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
        // Display image
        Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(uid: widget.post.userId))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              //Top section:Profilpicture / name/ delete button

              child: Row(
                children: [
                  //profile pic
                  postUser?.profileImagUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImagUrl,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 30,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover)),
                          ),
                        )
                      : Icon(Icons.person),
                  SizedBox(
                    width: 20,
                  ),
                  // name
                  Text(widget.post.userName),

                  Spacer(),
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 430,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Wrap Row inside Expanded
                Row(
                  children: [
                    GestureDetector(
                      onTap: toggleLikePost,
                      child: Icon(
                        widget.post.likes.contains(currentUser?.uid ?? '')
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            widget.post.likes.contains(currentUser?.uid ?? '')
                                ? Colors.lightBlue
                                : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.post.likes.length.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: openNewCommentBox,
                  icon: Icon(Icons.comment_outlined, color: Colors.grey[650]),
                ),
                Text(widget.post.comments.length.toString()),
                Spacer(),
                Text(
                  timeago.format(widget.post.timeStamp),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                //username
                Text(
                  widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                //text
                Text(
                  widget.post.text,
                ),
              ],
            ),
          ),
          BlocBuilder<PostCubits, PostStates>(
            builder: (context, state) {
              //Loaded
              if (state is PostLoaded) {
                //final individual post
                final post = state.posts
                    .firstWhere((post) => (post.id == widget.post.id));

                if (post.comments.isNotEmpty) {
                  //how many comment to show
                  // int showCommentCount = post.comments.length;

                  // comment section
                  return SizedBox(
                    height: 20,
                    // child: ListView.builder(
                    //     itemCount: showCommentCount,
                    //     shrinkWrap: false,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemBuilder: (context, index) {
                    //get individual comments
                    // final comment = post.comments[index];

                    // comment tile UI

                    // return null;
                    // }),
                  );
                }
              }

              if (state is PostLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //Error

              else if (state is PostErrors) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }
}
