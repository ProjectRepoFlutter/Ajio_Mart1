import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:intl/intl.dart'; // For date formatting

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse(APIConfig.getAllOrders +
        globals.userContactValue.toString())); // Add your API URL here

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          } else if (snapshot.hasData) {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: _buildProductName(order),
                    subtitle: _buildDeliveryDate(order),
                    trailing: _getStatusIcon(order.orderStatus),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  // Helper function to build the product name in one line, truncated if too long
  Widget _buildProductName(Order order) {
    // Assuming the first product in the items list is representative
    final firstProduct = order.items.isNotEmpty ? order.items[0] : null;
    final productName = firstProduct != null
        ? 'Product ID: ${firstProduct.productId}'
        : 'Unknown Product';

    return Text(
      productName,
      overflow: TextOverflow.ellipsis, // Truncate with '...'
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  // Helper function to display the correct delivery date based on the order status
  Widget _buildDeliveryDate(Order order) {
    String deliveryText;
    DateTime deliveryDate;

    if (order.orderStatus == 'Delivered') {
      deliveryText = 'Delivered on: ';
      deliveryDate = order.deliveredAt;
    } else {
      deliveryText = 'Expected delivery on: ';
      deliveryDate = order
          .deliveredAt; // Assuming deliveredAt is used as expected date too
    }

    // Format the date to a readable format
    String formattedDate = DateFormat.yMMMd().format(deliveryDate);

    return Text('$deliveryText $formattedDate');
  }

  // Helper function to return status icon based on delivery status
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'Pending':
        return Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'Cancelled':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return Icon(Icons.info, color: Colors.grey);
    }
  }
}
