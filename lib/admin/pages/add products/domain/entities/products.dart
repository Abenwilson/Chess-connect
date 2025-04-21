class Product {
  final String productId;
  final String productName;
  final String productImage;
  final String price;
  final String productdetails;

  Product({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.productdetails,
  });

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'productdetails': productdetails,
    };
  }

  // Convert JSON to Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'],
      productdetails: json['productdetails'],
    );
  }

  // Copy with method to modify specific fields
  Product copyWith({
    String? productId,
    String? productName,
    String? productImage,
    String? price,
    String? productdetails,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      productdetails: productdetails ?? this.productdetails,
    );
  }
}
