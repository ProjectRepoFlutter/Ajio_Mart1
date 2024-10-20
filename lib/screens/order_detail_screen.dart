import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart'; // Import your product detail screen

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order; // Expecting order data as a parameter

  OrderDetailScreen({required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> itemsWithDetails = []; // Store items with their details

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    List<Map<String, dynamic>> fetchedItems = [];

    for (var item in widget.order['items']) {
      final response = await http.get(Uri.parse(APIConfig.getProduct + item['productId']));

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        fetchedItems.add({
          'productId': item['productId'],
          'quantity': item['quantity'],
          'imageUrl': productData['imageUrl'],
          'name': productData['name'],
          'price': item['price'], // Add price for the product
        });
      } else {
        // Handle error or add default values if needed
        fetchedItems.add({
          'productId': item['productId'],
          'quantity': item['quantity'],
          'imageUrl': null,
          'name': 'Product Not Found',
          'price': 0, // Default price if not found
        });
      }
    }

    setState(() {
      itemsWithDetails = fetchedItems;
    });
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

  @override
  Widget build(BuildContext context) {
    final deliveryDate = widget.order['deliveredAt'] != null
        ? DateTime.parse(widget.order['deliveredAt']).toLocal()
        : null;

    final createdAt = DateTime.parse(widget.order['createdAt']).toLocal(); // Parse created date

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order['_id']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Created on: ${createdAt.toLocal().toString().split(' ')[0]}', // Display created date
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Total Price: \$${widget.order['totalPrice']}', // Display total price
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Payment Status: ${widget.order['paymentStatus']}', // Display payment status
              style: TextStyle(fontSize: 16),
            ),
            // Conditionally display payment method
            if (widget.order['paymentStatus'] == 'Paid') ...[
              SizedBox(height: 10),
              Text(
                'Payment Method: ${widget.order['paymentMethod']}', // Display payment method only if paid
                style: TextStyle(fontSize: 16),
              ),
            ],
            SizedBox(height: 10),
            _getDeliveryMessage(widget.order['orderStatus'], deliveryDate), // Display colored delivery message
            SizedBox(height: 10),
            // Delivery Address without clickable feature
            Text(
              'To: ${widget.order['deliveryAddress']}', // Added "To: " before the address
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('Items:'),
            Expanded(
              child: ListView.builder(
                itemCount: itemsWithDetails.length,
                itemBuilder: (context, index) {
                  final item = itemsWithDetails[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(productId: item['productId']),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: item['imageUrl'] != null
                          ? Image.network(item['imageUrl'], width: 50, height: 50)
                          : Icon(Icons.image, size: 50), // Default icon if no image
                      title: Text(item['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${item['quantity']}'),
                          Text('Price: \$${item['price']}'), // Display price for the product
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
