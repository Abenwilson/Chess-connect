import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/presentation/components/my_text_field.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class EditProfile extends StatefulWidget {
  final ProfileUser user;
  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final bioTextController = TextEditingController();
  final professionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio;
    professionController.text = widget.user.profession;
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = result.files.first.bytes;
        }
      });
    }
  }

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubits>();
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final String? newprofession =
        professionController.text.isNotEmpty ? professionController.text : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        newProfession: newprofession,
        imageMobilePath: kIsWeb ? null : imagePickedFile?.path,
        imageWebBytes: kIsWeb ? webImage : null,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubits, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const ConstrainedScaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Uploading...")],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          //you can fetch the updated profile
          context.read<ProfileCubits>().fetchUserProfile(widget.user.uid);
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 15),
        ),
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: const Icon(Icons.upload),
            color: Theme.of(context).colorScheme.inversePrimary,
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: (kIsWeb && webImage != null)
                  ? Image.memory(webImage!, fit: BoxFit.cover)
                  : (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              "${widget.user.profileImagUrl}?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          fit: BoxFit.cover,
                        ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: MaterialButton(
                onPressed: pickImage,
                color: Colors.blue[300],
                child: const Text(
                  "Pick an Image",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          buildTextField("Bio", bioTextController, widget.user.bio),
          buildTextField(
              "Profession", professionController, widget.user.profession),
        ],
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 10),
          MyTextField(
              controller: controller, hinttext: hint, obscureText: false),
        ],
      ),
    );
  }
}
