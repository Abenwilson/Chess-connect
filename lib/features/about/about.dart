import 'package:flutter/material.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              "About Chess Connect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Chess-themed social media platforms have become vibrant hubs for players of all skill levels to connect, learn, and compete.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              "These platforms combine the strategic depth of chess with the dynamic interaction of social networking, allowing users to share game analyses, watch live streams of grandmasters, and engage in friendly or competitive matches.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              "Communities on platforms like Chess.com, Lichess, and even broader social media such as Reddit or YouTube offer tutorials, puzzles, memes, and discussions that keep the chess culture lively and accessible. ",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
