import 'package:flutter/material.dart';

class MyDrawertile extends StatelessWidget {
  final String title;
  final icon;
  final void Function()? ontap;
  const MyDrawertile(
      {super.key,
      required this.title,
      required this.icon,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: ontap,
    );
  }
}
