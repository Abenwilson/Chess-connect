import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/presentation/components/my_text_field.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/post/domain/entites/post.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';
import 'package:photographers/features/post/presentation/cubits/post_states.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  //web image pick
  Uint8List? webImage;

  //mobile image pick
  PlatformFile? imagePickedFile;

  //text controller -> caption
  final textController = TextEditingController();
  // current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authcubit = context.read<AuthCubit>();
    currentUser = authcubit.currentUser;
  }

  //selectImage

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Required for Web
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          webImage = result.files.first.bytes; // Store bytes for web
        } else {
          imagePickedFile = result.files.first; // Store file for mobile
        }
      });
    }
  }

  // create and upload the post
  void uploadPost() {
    if (imagePickedFile == null && webImage == null ||
        textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Both image and caption are required")));
      return;
    }
    final newPost = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timeStamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    // post cubits
    final postCubit = context.read<PostCubits>();

    //web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: webImage);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubits, PostStates>(
      builder: (context, state) {
        print(state);
        //loading or uploading..
        if (state is PostLoading || state is PostUploading) {
          return ConstrainedScaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Posting......")],
              ),
            ),
          );
        } else {
          return buildUploadPage();
        }
      },
      //upload is done.
      listener: (context, state) {
        if (state is PostLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Create posts",
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: uploadPost,
            icon: Icon(Icons.upload_file),
            color: Theme.of(context).colorScheme.inversePrimary,
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //image preview for Web
              // Image preview for Web
              if (kIsWeb && webImage != null) Image.memory(webImage!),

              // Image preview for Mobile
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),

              //material button for pick image

              MaterialButton(
                onPressed: pickImage,
                color: Colors.blue[300],
                child: Text("pick an image"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(
                height: 20,
              ),

              // text box for description

              Padding(
                padding: const EdgeInsets.all(20),
                child: MyTextField(
                    controller: textController,
                    hinttext: "about image",
                    obscureText: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
