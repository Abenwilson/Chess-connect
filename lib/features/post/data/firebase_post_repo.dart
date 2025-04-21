import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/features/post/domain/entites/comment.dart';
import 'package:photographers/features/post/domain/entites/post.dart';
import 'package:photographers/features/post/domain/repos/post_repos.dart';

class FirebasePostRepo implements PostRepos {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Store all post ina a post collection called Post
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("error occured on posting");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      print("Attempting to delete post with ID: $postId"); // Debugging line
      await postsCollection.doc(postId).delete();
      print("Post deleted successfully!"); // Debugging line
    } catch (e) {
      print("Error deleting post: $e");
      throw Exception("Error deleting post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      //get all post with most recent at the post
      final postsSnapshot =
          await postsCollection.orderBy('timeStamp', descending: true).get();

      //
      if (postsSnapshot.docs.isEmpty) {
        print("No posts found.");
      }

      // convert these firestore document from json -> list of posts
      final List<Post> allpost = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      print("Fetched ${allpost.length} posts.");

      return allpost;
    } catch (e) {
      throw Exception("error on fetching posts $e");
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();
      // convert these file from json to list of files
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception("error occured$e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // get the post documents from firestore
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        //check if user has already like this post
        final hasLiked = post.likes.contains(userId);
        //update the likes list
        if (hasLiked) {
          post.likes.remove(userId); // unlike
        } else {
          post.likes.add(userId); // like
        }
        //update the post document with the new like list
        await postsCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception("post not  found");
      }
    } catch (e) {
      throw Exception("error on toggle like $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        //update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("post not found");
      }
    } catch (e) {
      throw Exception("error adding comments: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        //update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("post not found");
      }
    } catch (e) {
      throw Exception("error deleting comments: $e");
    }
  }
}
