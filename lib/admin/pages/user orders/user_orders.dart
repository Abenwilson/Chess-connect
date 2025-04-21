import 'package:flutter/material.dart';
import 'package:photographers/features/Products/orders_product/data/firebase_order_repo.dart';
import 'package:photographers/features/Products/orders_product/domain/entities/Apporder.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseOrderRepo orderRepo = FirebaseOrderRepo();
  late Future<List<AppOrder>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = orderRepo.fetchAllOrders();
  }

  void _confirmDeleteOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteOrder(orderId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await orderRepo.deleteOrder(orderId);
      setState(() {
        ordersFuture = orderRepo.fetchAllOrders(); // Refresh order list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
          title: const Text(
        "Orders",
        style: TextStyle(fontSize: 18),
      )),
      body: FutureBuilder<List<AppOrder>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    order.productImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  title: Text("User: ${order.userName}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product: ${order.productName}",
                        style: TextStyle(color: Colors.purple),
                      ),
                      Text("Price: \$${order.price}"),
                      Text("Delivery Address: ${order.deliveryAddress}"),
                      Text("Contact: ${order.phNo}"),
                      Text("Date: ${order.orderDate.toLocal()}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      _confirmDeleteOrder(order.orderId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
