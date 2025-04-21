import 'package:photographers/features/post/domain/entites/comment.dart';
import 'package:photographers/features/post/domain/entites/post.dart';

abstract class PostRepos {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
