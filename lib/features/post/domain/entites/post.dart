import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/features/post/domain/entites/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;
  final List<String> likes; // store uid of all posts
  final List<Comment> comments; // store uid of all posts

  Post(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.text,
      required this.imageUrl,
      required this.timeStamp,
      required this.likes,
      required this.comments});

  Post copyWith({String? imageUrl}) {
    return Post(
        id: id,
        userId: userId,
        userName: userName,
        text: text,
        imageUrl: imageUrl ?? this.imageUrl,
        timeStamp: timeStamp,
        likes: likes,
        comments: comments);
  }

//convert post to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

// convert  json files to post

  factory Post.fromJson(Map<String, dynamic> json) {
// prepare comments
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];

    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['name'],
        text: json['text'],
        imageUrl: json['imageUrl'],
        timeStamp: (json['timeStamp'] as Timestamp).toDate(),
        likes: List<String>.from(json['likes'] ?? []),
        comments: comments //comments implemented
        );
  }
}
