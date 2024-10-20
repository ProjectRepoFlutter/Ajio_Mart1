import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'order_detail_screen.dart'; // Import the new screen

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> orders = [];
  Map<String, dynamic> productDetails = {}; // Store product details for each order

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final response = await http.get(Uri.parse(APIConfig.getAllOrders +
        globals.userContactValue.toString()));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orders = data;
      });

      // Fetch product details for each order
      for (var order in orders) {
        if (order['items'].isNotEmpty) {
          String productId = order['items'][0]['productId'];
          fetchProductDetails(productId, order['_id']); // Pass the order ID to store details uniquely
        }
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchProductDetails(String productId, String orderId) async {
    final response = await http.get(Uri.parse(APIConfig.getProduct + productId));

    if (response.statusCode == 200) {
      final productData = json.decode(response.body);
      setState(() {
        productDetails[orderId] = {
          'name': productData['name'],
          'imageUrl': productData['imageUrl'],
        };
      });
    } else {
      throw Exception('Failed to load product details');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle; // Check icon for delivered
      case 'Processing':
        return Icons.sync; // Sync icon for processing
      case 'Shipped':
        return Icons.local_shipping; // Shipping icon for shipped
      case 'Pending':
        return Icons.hourglass_empty; // Hourglass icon for pending
      case 'Cancelled':
        return Icons.cancel; // Cancel icon for cancelled
      default:
        return Icons.error; // Error icon for unknown status
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green; // Green for delivered
      case 'Processing':
        return Colors.blue; // Blue for processing
      case 'Shipped':
        return Colors.orange; // Orange for shipped
      case 'Pending':
        return Colors.yellow; // Yellow for pending
      case 'Cancelled':
        return Colors.red; // Red for cancelled
      default:
        return Colors.grey; // Grey for unknown status
    }
  }

  Text _getDeliveryMessage(String status, DateTime? deliveryDate) {
    String message;
    Color color;

    if (status == 'Cancelled') {
      message = 'Order Cancelled';
      color = Colors.red;
    } else if (status == 'Delivered') {
      message = 'Delivered on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.green;
    } else if (deliveryDate == null) {
      message = 'Arriving Soon';
      color = Colors.orange; // Optional color for "Arriving Soon"
    } else {
      message = 'Arriving on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.blue; // Optional color for arriving messages
    }

    return Text(
      message,
      style: TextStyle(color: color), // Apply the color to the text
    );
  }

  Future<void> _onRefresh() async {
    await fetchOrderData(); // Refresh the order data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Trigger refresh on pull down
        child: orders.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final deliveryDate = order['deliveredAt'] != null
                      ? DateTime.parse(order['deliveredAt']).toLocal()
                      : null;
                  final orderId = order['_id'];
                  final productDetail = productDetails[orderId];
                  final orderStatus = order['orderStatus'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order), // Navigate to order details
                        ),
                      );
                    },
                    child: ListTile(
                      leading: productDetail != null && productDetail['imageUrl'] != null
                          ? Image.network(productDetail['imageUrl'])
                          : Icon(Icons.image),
                      title: Text(
                        order['items'].length > 1 && productDetail != null
                            ? '${productDetail['name']}...and more'
                            : productDetail != null ? productDetail['name'] : 'Loading...',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getDeliveryMessage(orderStatus, deliveryDate), // Display colored delivery message
                          SizedBox(height: 4), // Add some spacing between lines
                          Text(
                            'To: ${order['deliveryAddress']}', // Add "To: " before the address
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                            maxLines: 1, // Limit to one line
                            overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                          ),
                        ],
                      ),
                      trailing: Icon(
                        _getStatusIcon(orderStatus),
                        color: _getStatusColor(orderStatus),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
