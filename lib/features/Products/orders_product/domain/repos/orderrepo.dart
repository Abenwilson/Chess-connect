import 'package:photographers/features/Products/orders_product/domain/entities/Apporder.dart';

abstract class AppOrderRepo {
  Future<List<AppOrder>> fetchAllOrders();
  Future<List<AppOrder>> fetchAllconfirmedAppOrders();
}
