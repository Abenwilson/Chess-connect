import 'package:flutter/material.dart';

class CompnameBox extends StatelessWidget {
  final String text;
  const CompnameBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: double.infinity,
      child: Text(text.isNotEmpty ? text : "empty.."),
    );
  }
}
