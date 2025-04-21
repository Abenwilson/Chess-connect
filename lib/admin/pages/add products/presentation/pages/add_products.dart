import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photographers/admin/pages/add%20products/data/firebase_product_repo.dart';
import 'package:photographers/admin/pages/add%20products/domain/entities/products.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';
import 'package:uuid/uuid.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final FirebaseProductRepo productRepo = FirebaseProductRepo();
  final _formKey = GlobalKey<FormState>();

  Uint8List? webImage;
  PlatformFile? imagePickedFile;
  bool _isUploading = false;

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Required for Web
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          webImage = result.files.first.bytes;
        } else {
          imagePickedFile = result.files.first;
        }
      });
    }
  }

  Future<String> _uploadImage() async {
    String fileName = "products/${const Uuid().v4()}";
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(webImage!);
    } else {
      File file = File(imagePickedFile!.path!);
      uploadTask = ref.putFile(file);
    }

    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() &&
        (webImage != null || imagePickedFile != null)) {
      setState(() => _isUploading = true);

      try {
        String imageUrl = await _uploadImage();

        final product = Product(
          productId: const Uuid().v4(),
          productName: _nameController.text,
          productImage: imageUrl, // Now storing the correct image URL
          price: _priceController.text,
          productdetails: _detailsController.text,
        );

        await productRepo.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product added successfully!")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }

      setState(() => _isUploading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields and select an image.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
          title: const Text(
        "Add Product",
        style: TextStyle(fontSize: 18),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      // border when unselected
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // border when Selected
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "Product Name",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  validator: (value) =>
                      value!.isEmpty ? "Enter product name" : null,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                      // border when unselected
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // border when Selected
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "Price",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  validator: (value) =>
                      value!.isEmpty ? "Enter product price" : null,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                        // border when unselected
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // border when Selected
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary),
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "Product Details",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary))),
                const SizedBox(height: 20),
                if (webImage != null) Image.memory(webImage!, height: 200),
                if (!kIsWeb && imagePickedFile != null)
                  Image.file(File(imagePickedFile!.path!), height: 200),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text(
                    "Pick an Image",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text("Save Product"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
