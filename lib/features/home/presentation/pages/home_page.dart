import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/home/presentation/components/my_drawer.dart';
import 'package:photographers/features/home/presentation/components/post_tile.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';
import 'package:photographers/features/post/presentation/cubits/post_states.dart';
import 'package:photographers/features/post/presentation/pages/upload_post_page.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubits>();

  @override
  void initState() {
    super.initState();

    // Fetch all posts when the page is initialized
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllposts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId).then((_) {
      fetchAllPosts(); // Refreshes posts after deletion
    }).catchError((error) {
      print("Error deleting post: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
        appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            // Upload new posts
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadPostPage())),
                icon: const Icon(Icons.add))
          ],
        ),
        drawer: const MyDrawer(),
        body: BlocBuilder<PostCubits, PostStates>(builder: (context, state) {
          // Show loading indicator when posts are being fetched or uploaded
          if (state is PostLoading || state is PostUploading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // When posts are loaded
          else if (state is PostLoaded) {
            final allPosts = state.posts;
            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No Posts Available"),
              );
            }
            return ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  // Get individual post
                  final post = allPosts[index];

                  return SingleChildScrollView(
                    child: PostTile(
                      post: post,
                      onDeletePresssed: () => deletePost(post.id),
                    ),
                  );
                });
          }
          // When an error occurs
          else if (state is PostErrors) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox();
          }
        }));
  }
}
