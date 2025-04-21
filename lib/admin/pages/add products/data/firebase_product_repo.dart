import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/admin/pages/add%20products/domain/entities/products.dart';
import 'package:photographers/admin/pages/add%20products/domain/repos/product_repo.dart';

class FirebaseProductRepo implements ProductRepos {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference productdata =
      FirebaseFirestore.instance.collection('products');

  @override
  Future<List<Product>> fetchAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await productdata.get();
      return querySnapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    try {
      await productdata.doc(product.productId).set(product.toJson());
    } catch (e) {
      throw Exception("Error adding product: $e");
    }
  }
}
