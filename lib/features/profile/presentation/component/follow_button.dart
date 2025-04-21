/*
 follow and unfollow button

  This is follow /un follow button.
  -----------------------------------
  - a fuction (eg.toggleFolloW())
  - is following (eg toggle Follow())
*/
import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const FollowButton(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding outSide
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MaterialButton(
          onPressed: onPressed,
          // padding inside
          padding: const EdgeInsets.all(25),

          // color is blue
          color: isFollowing
              ? Theme.of(context).colorScheme.primary
              : Colors.blue[400],
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
