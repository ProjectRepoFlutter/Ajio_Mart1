import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productDetails; // Store product details
  int quantityInCart = 0; // To track quantity of the product in the cart

  @override
  void initState() {
    super.initState();
    fetchProductDetails(); // Fetch product details when the screen is initialized
    checkIfProductInCart(); // Check if the product is already in the cart
  }

  Future<void> fetchProductDetails() async {
    final response =
        await http.get(Uri.parse(APIConfig.getProduct + widget.productId));

    if (response.statusCode == 200) {
      setState(() {
        productDetails =
            json.decode(response.body); // Parse the product details
      });
    } else {
      // Handle error
      throw Exception('Failed to load product details');
    }
  }

  Future<void> checkIfProductInCart() async {
  final cartResponse = await http.get(Uri.parse(APIConfig.getAllItemInCart + globals.userContactValue.toString()));
  
  if (cartResponse.statusCode == 200) {
    final cartData = json.decode(cartResponse.body);

    // Assuming `cartData` is a Map and contains a list of items under a specific key
    List<dynamic> cartItems = cartData['items'] ?? []; // Replace 'items' with the actual key

    final cartItem = cartItems.firstWhere(
      (item) => item['productId'] == widget.productId, 
      orElse: () => null
    );

    if (cartItem != null) {
      setState(() {
        quantityInCart = cartItem['quantity'];
      });
    }
  } else {
    // Handle the case where the API response is not successful
    throw Exception('Failed to load cart items');
  }
}

  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    final String apiUrl =
        APIConfig.addToCart; // Add your API endpoint for adding to cart

    try {
      // Send POST request to add product to cart
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user":
              globals.userContactValue, // Use global variable for user contact
          'productId': productId,
          'quantity': quantity,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          quantityInCart += quantity; // Update quantity in cart
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added to cart!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product to cart!')),
        );
      }
    } catch (error) {
      print('Error adding product to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong!')),
      );
    }
  }

  void updateCartQuantity(int newQuantity) {
    setState(() {
      quantityInCart = newQuantity; // Update the quantity in the cart
    });
  }

  @override
  Widget build(BuildContext context) {
    if (productDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(
            child: CircularProgressIndicator()), // Show loading indicator
      );
    }

    final isInStock = productDetails!['stock'] > 0; // Check stock availability

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display product image
            Image.network(
              productDetails!['imageUrl'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8), // Space between image and separator
            Divider(thickness: 2), // Separator after the image
            SizedBox(height: 16), // Space after the separator

            // Display product name
            Text(
              productDetails!['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Display product description
            Text(
              productDetails!['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Display product stock status
            Text(
              isInStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                fontSize: 18,
                color: isInStock ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 8),
            // Display product price
            Text(
              'Price: ₹${productDetails!['price']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Display product rating with rating count
            Text(
              'Rating: ${productDetails!['rating']} ⭐ (${productDetails!['ratingCount']} ratings)',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),

            // Add to Cart section
            quantityInCart > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // Add border
                          borderRadius:
                              BorderRadius.circular(8), // Rounded edges
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              color: Colors.green,
                              onPressed: quantityInCart > 1
                                  ? () {
                                      updateCartQuantity(quantityInCart - 1);
                                      // Optionally, you can add an API call to update the cart on the server
                                    }
                                  : null, // Disable if quantity is 1
                            ),
                            Text(
                              '$quantityInCart',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.green,
                              onPressed: isInStock
                                  ? () {
                                      updateCartQuantity(quantityInCart + 1);
                                      // Optionally, you can add an API call to update the cart on the server
                                    }
                                  : null, // Disable if out of stock
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: isInStock
                        ? () {
                            addToCart(context, widget.productId,
                                1); // Assuming quantity is 1
                          }
                        : null, // Disable button if out of stock
                    child: Text('Add to Cart'),
                  ),
          ],
        ),
      ),
    );
  }
}
