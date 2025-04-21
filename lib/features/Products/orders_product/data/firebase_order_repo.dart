import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/features/Products/orders_product/domain/entities/Apporder.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';

class FirebaseOrderRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<List<AppOrder>> fetchAllOrders() async {
    try {
      final querySnapshot = await firebaseFirestore.collection('orders').get();
      List<AppOrder> orders = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();

        // Fetch user name from Firestore if it's missing
        if (data['userName'] == null || data['userName'].isEmpty) {
          DocumentSnapshot userSnapshot = await firebaseFirestore
              .collection('users')
              .doc(data['userId'])
              .get();

          if (userSnapshot.exists) {
            AppUser appUser =
                AppUser.fromJson(userSnapshot.data() as Map<String, dynamic>);
            data['userName'] = appUser.name; // Update user name
          }
        }

        orders.add(AppOrder.fromJson(data));
      }

      return orders;
    } catch (e) {
      throw Exception("Failed to fetch orders: $e");
    }
  }

  Future<List<AppOrder>> fetchAllConfirmedOrders() async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('orders')
          .where('status', isEqualTo: 'confirmed')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AppOrder.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch confirmed orders: $e");
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await firebaseFirestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception("Failed to delete order: $e");
    }
  }
}
