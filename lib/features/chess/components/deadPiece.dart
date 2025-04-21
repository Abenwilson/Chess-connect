import 'package:flutter/material.dart';

class Deadpiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const Deadpiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      color: isWhite ? Colors.grey[400] : Colors.grey[800],
      scale: 3.5,
    );
  }
}
