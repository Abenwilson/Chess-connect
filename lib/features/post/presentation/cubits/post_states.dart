/*

POST STATES


*/
import 'package:photographers/features/post/domain/entites/post.dart';

abstract class PostStates {}
//initial

class PostInitial extends PostStates {}

//loading
class PostLoading extends PostStates {}

//uploading
class PostUploading extends PostStates {}

//error

class PostErrors extends PostStates {
  final String message;
  PostErrors(this.message);
}

//loaded
class PostLoaded extends PostStates {
  final List<Post> posts;
  PostLoaded(this.posts);
}
