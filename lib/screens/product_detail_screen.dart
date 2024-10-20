import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals; // Import global variables

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productDetails; // Store product details

  @override
  void initState() {
    super.initState();
    fetchProductDetails(); // Fetch product details when the screen is initialized
  }

  Future<void> fetchProductDetails() async {
    final response = await http.get(Uri.parse(APIConfig.getProduct + widget.productId));

    if (response.statusCode == 200) {
      setState(() {
        productDetails = json.decode(response.body); // Parse the product details
      });
    } else {
      // Handle error
      throw Exception('Failed to load product details');
    }
  }

  Future<void> addToCart(BuildContext context, String productId, int quantity) async {
    final String apiUrl = APIConfig.addToCart; // Add your API endpoint for adding to cart

    try {
      // Send POST request to add product to cart
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user": globals.userContactValue, // Use global variable for user contact
          'productId': productId,
          'quantity': quantity, // You can send quantity as 1 initially
          // Add more fields if needed, like userId, etc.
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If product added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added to cart!')),
        );
      } else {
        // Show error if the product was not added
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

  @override
  Widget build(BuildContext context) {
    if (productDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
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
            // Add to Cart button
            ElevatedButton(
              onPressed: isInStock
                  ? () {
                      // Call addToCart function when button is pressed
                      addToCart(context, widget.productId, 1); // Assuming quantity is 1
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
