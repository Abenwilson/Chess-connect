import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/post/domain/entites/comment.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;

  const CommentTile({
    super.key,
    required this.comment,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  //  current user
  AppUser? currentuser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentuser = authCubit.currentUser;
    if (currentuser != null) {
      isOwnPost = widget.comment.userId == currentuser!.uid;
    }
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you Sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              print("Attempting to delete comment: ${widget.comment.id}");
              context
                  .read<PostCubits>()
                  .deleteComment(widget.comment.postId, widget.comment.id);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          //name

          Text(
            widget.comment.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(
            width: 10,
          ),

          //comment text

          Text(widget.comment.text),

          const Spacer(),
          if (isOwnPost)
            GestureDetector(onTap: showOptions, child: Icon(Icons.more_horiz)),
        ],
      ),
    );
  }
}
