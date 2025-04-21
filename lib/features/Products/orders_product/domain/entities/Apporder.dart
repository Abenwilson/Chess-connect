import 'package:photographers/admin/pages/add%20products/domain/entities/products.dart';

class AppOrder extends Product {
  final String orderId;
  final String userId;
  final String userName;
  final String deliveryAddress;
  final DateTime orderDate;
  final String phNo;

  AppOrder({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.deliveryAddress,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.productdetails,
    required super.price,
    required this.orderDate,
    required this.phNo,
  });

  // Method to update order details
  AppOrder copyWith({
    String? orderId,
    String? userId,
    String? userName,
    String? deliveryAddress,
    DateTime? orderDate,
    String? phNo,
    String? productId,
    String? productName,
    String? productImage,
    String? productdetails,
    String? price,
  }) {
    return AppOrder(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderDate: orderDate ?? this.orderDate,
      phNo: phNo ?? this.phNo,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productdetails: productdetails ?? this.productdetails,
      price: price ?? this.price,
    );
  }

  // Convert Order to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.toIso8601String(),
      'phNo': phNo,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productdetails': productdetails,
      'price': price,
    };
  }

  // Convert JSON to Order
  factory AppOrder.fromJson(Map<String, dynamic> json) {
    return AppOrder(
      orderId: json['orderId'],
      userId: json['userId'],
      userName: json['userName'],
      deliveryAddress: json['deliveryAddress'],
      orderDate: DateTime.parse(json['orderDate']),
      phNo: json['phNo'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      productdetails: json['productdetails'],
      price: json['price'],
    );
  }
}
