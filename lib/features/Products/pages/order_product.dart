import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photographers/features/Products/orders_product/domain/entities/Apporder.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:photographers/admin/pages/add%20products/domain/entities/products.dart';

class OrderProduct extends StatefulWidget {
  final Product product;

  const OrderProduct({super.key, required this.product});

  @override
  State<OrderProduct> createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  void confirmOrder() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to place an order.")),
        );
        return;
      }

      String phoneNumber = phoneNumberController.text.trim();
      String deliveryAddress = addressController.text.trim();

      // Validate phone number (must be exactly 10 digits)
      if (phoneNumber.isEmpty || phoneNumber.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter a valid 10-digit phone number.")),
        );
        return;
      }

      // Validate address (must not be empty)
      if (deliveryAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delivery address cannot be empty.")),
        );
        return;
      }

      // Fetch user details from Firestore
      DocumentSnapshot userSnapshot =
          await firebaseFirestore.collection('users').doc(user.uid).get();

      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User details not found.")),
        );
        return;
      }

      // Convert snapshot to AppUser
      AppUser appUser =
          AppUser.fromJson(userSnapshot.data() as Map<String, dynamic>);

      String orderId = const Uuid().v4(); // Generate a unique order ID

      AppOrder order = AppOrder(
        orderId: orderId,
        userId: user.uid,
        userName: appUser.name,
        deliveryAddress: deliveryAddress,
        orderDate: DateTime.now(),
        phNo: phoneNumber,
        productId: widget.product.productId,
        productName: widget.product.productName,
        productImage: widget.product.productImage,
        productdetails: widget.product.productdetails,
        price: widget.product.price,
      );

      await firebaseFirestore
          .collection('orders')
          .doc(orderId)
          .set(order.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

      Navigator.pop(context); // Close the order screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
          title: const Text(
        "Order Product",
        style: TextStyle(fontSize: 18),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.productName,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Image.network(
                  widget.product.productImage,
                  fit: BoxFit.contain, // Ensures full image visibility
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 50),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "\$${widget.product.price}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text("Enter Delivery Address:"),
              TextField(
                controller: addressController,
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
                    hintText: "Enter Delievery  Address",
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                maxLines: 2,
              ),
              SizedBox(
                height: 10,
              ),
              const Text("Enter Contact:"),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10, // Restricts to 10 digits
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ], // Allows only numbers
                decoration: InputDecoration(
                  counterText: "", // Hides default max length counter
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "+91",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width *
                      0.2, // 20% of screen width
                  vertical: 10,
                ),
                child: Text("Delivery Within 3 Days"),
              ),
              ElevatedButton(
                onPressed: confirmOrder,
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
