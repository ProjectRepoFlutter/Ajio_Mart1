import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'checkout_screen.dart';  // Import CheckoutScreen

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  void refresh(){
    fetchCartItems();
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true; // Show loader when fetching data
    });
    try {
      print(APIConfig.getAllItemInCart + globals.userContactValue.toString());
      final response = await http.get(
          Uri.parse(APIConfig.getAllItemInCart + globals.userContactValue.toString()));
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

  Future<void> fetchProductDetails(List<dynamic> items) async {
    List<dynamic> detailedItems = [];
    try {
      for (var item in items) {
        final productResponse = await http.get(
            Uri.parse(APIConfig.getProduct + item['productId'].toString()));
        if (productResponse.statusCode == 200) {
          final product = jsonDecode(productResponse.body);
          detailedItems.add({
            'id': item['productId'],
            'name': product['name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'imageUrl': product['imageUrl'],
            'stock': product['stock'], // Add stock status
          });
        }
      }
      setState(() {
        cartItems = detailedItems; // Update cart items with detailed information
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> deleteItem(String itemId, int index) async {
    try {
      final response = await http.delete(
        Uri.parse(APIConfig.deleteProductFromCart + itemId),
        headers: {
          'Content-Type': 'application/json',
          'user': globals.userContactValue.toString()
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeAt(index); // Remove the item from the list
        });
        fetchCartItems(); // Refresh cart data after update
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse(APIConfig.updateQuantityInCart),
        body: jsonEncode({
          "user": globals.userContactValue,
          "productId": itemId,
          "quantity": newQuantity
        }),
        headers: {
          'Content-Type': 'application/json',
        },
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

  int calculateTotalPrice() {
    return cartItems.fold(0, (total, item) {
      return (total + int.parse(item['price'])).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchCartItems, // Trigger refresh on pull-down
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : cartItems.isEmpty // Check if cartItems is empty
                ? ListView( // Use ListView to support pull to refresh even when empty
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Your cart is empty!',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20), // Space between text and image
                              Image.asset(
                                'assets/images/emptyCart.png', // Path to your empty bag image
                                height: 200, // Adjust height as needed
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
                                    Image.network(item['imageUrl'] ?? APIConfig.logoUrl,
                                        width: 80, height: 80),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'],
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Text('₹${item['price']}'),
                                          Text(
                                            item['stock'] > 0 ? '' : 'Out of stock',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: item['stock'] > 0 &&
                                                        item['quantity'] > 1
                                                    ? () {
                                                        updateQuantity(
                                                            item['id'],
                                                            item['quantity'] - 1);
                                                      }
                                                    : null, // Disable button if out of stock
                                              ),
                                              Text('${item['quantity']}'),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: item['stock'] > 0
                                                    ? () {
                                                        updateQuantity(
                                                            item['id'].toString(),
                                                            item['quantity'] + 1);
                                                      }
                                                    : null, // Disable button if out of stock
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteItem(item['id'], index); // Pass item id and index to delete
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
                                Text('Total:',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('₹${calculateTotalPrice()}',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to Checkout Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CheckoutScreen()),
                                ).then((_) {
                              fetchCartItems(); // Refresh addresses when coming back
                            });;
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
      ),
    );
  }
}

