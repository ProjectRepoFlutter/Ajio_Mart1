import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';

class CartScreen extends StatefulWidget {
  const CartScreen();

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      print(APIConfig.getAllItemInCart + globals.userContactValue);
      final response = await http.get(Uri.parse(APIConfig.getAllItemInCart + globals.userContactValue));
      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body)['items'];
        await fetchProductDetails(items); // Fetch product details for each item
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  // Function to fetch product details based on cart items
  Future<void> fetchProductDetails(List<dynamic> items) async {
    List<dynamic> detailedItems = [];
    try {
      for (var item in items) {
        final productResponse = await http.get(Uri.parse(APIConfig.getProduct + item['productId'].toString()));
        if (productResponse.statusCode == 200) {
          final product = jsonDecode(productResponse.body);
          // Combine product details with the cart item data
          detailedItems.add({
            'id': item['_id'],
            'name': product['name'],
            'price': item['price'], // price remains from cart
            'quantity': item['quantity'],
            'imageUrl': product['imageUrl'] // Assuming you have an imageUrl
          });
        }
      }
      setState(() {
        cartItems = detailedItems; // Update the cart items with detailed information
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  // Function to update quantity in the database via API
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_API_UPDATE_QUANTITY_ENDPOINT'),
        body: jsonEncode({
          globals.userContactType: globals.userContactValue,
          'itemId': itemId,
          'quantity': newQuantity,
        }),
      );
      if (response.statusCode == 200) {
        fetchCartItems(); // Refresh cart data after update
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Calculate the total price of all items in the cart
  int calculateTotalPrice() {
    return cartItems.fold(0, (total, item) {
      return (total + int.parse(item['price'])).toInt(); // Convert price to int
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.network(item['imageUrl'], width: 80, height: 80),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('₹${item['price']}'),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            if (item['quantity'] > 1) {
                                              updateQuantity(item['id'], item['quantity'] - 1);
                                            }
                                          },
                                        ),
                                        Text('${item['quantity']}'),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            updateQuantity(item['id'], item['quantity'] + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Add functionality to remove item from cart
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${calculateTotalPrice()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Implement checkout functionality
                        },
                        child: Text('Place Order'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}