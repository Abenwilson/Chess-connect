import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/post/domain/entites/comment.dart';
import 'package:photographers/features/post/domain/entites/post.dart';
import 'package:photographers/features/post/domain/repos/post_repos.dart';
import 'package:photographers/features/post/presentation/cubits/post_states.dart';
import 'package:photographers/features/storage/domain/storage_repo.dart';

class PostCubits extends Cubit<PostStates> {
  final PostRepos postRepos;
  final StorageRepo storageRepo;
  PostCubits({required this.postRepos, required this.storageRepo})
      : super(PostInitial());

  //create new Post
  Future<void> createPost(
    Post post, {
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    String? imageurl;

    // handle image for Web platforms (using file path)
    try {
      emit(PostUploading());
      if (imageBytes != null) {
        emit(PostUploading());
        imageurl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }
      //handle image for mobile platforms(using file Bytes)
      else if (imagePath != null) {
        emit(PostUploading());
        imageurl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }
      //give a image url to post
      final newPost = post.copyWith(imageUrl: imageurl);

      //create a post in backend
      postRepos.createPost(newPost);

      // refetch all posts
      fetchAllposts();
    } catch (e) {
      Exception("faild to create posts $e");
    }

    // give image url to post
  }

  Future<void> fetchAllposts() async {
    try {
      emit(PostLoading());
      final posts = await postRepos.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      Exception("error on feching post $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepos.deletePost(postId);
    } catch (e) {
      throw Exception("error ocuured on delete $e");
    }
  }

  // toggle page
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepos.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostErrors("failed to toggle like $e"));
    }
  }

// add comments
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepos.addComment(postId, comment);
      await fetchAllposts(); // Ensure state updates with new comments
    } catch (e) {
      emit(PostErrors("Failed to add comments:$e"));
    }
  }

  //delete comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepos.deleteComment(postId, commentId);
      await fetchAllposts();
    } catch (e) {
      emit(PostErrors("Failed to delete comments:$e"));
    }
  }
}
