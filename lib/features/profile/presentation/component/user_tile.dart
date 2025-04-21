import 'package:flutter/material.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/profile/presentation/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        ListTile(
          leading: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(user.name),
          trailing: Icon(
            Icons.arrow_forward,
            color: Theme.of(context).colorScheme.primary,
          ),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => Profile(uid: user.uid))),
        ),
      ],
    );
  }
}
