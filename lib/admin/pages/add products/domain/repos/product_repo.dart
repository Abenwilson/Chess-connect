import 'package:photographers/admin/pages/add%20products/domain/entities/products.dart';

abstract class ProductRepos {
  Future<List<Product>> fetchAllProducts();
  Future<void> addProduct(Product Product);
}
