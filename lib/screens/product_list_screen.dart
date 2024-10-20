import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';
import 'package:ajio_mart/screens/product_detail_screen.dart'; // Import your ProductDetailScreen

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      print(APIConfig.getAllProductsInCategory + widget.categoryId);
      final response = await http.get(
          Uri.parse(APIConfig.getAllProductsInCategory + widget.categoryId));
      if (response.statusCode == 200) {
        print("Products found");
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    final String apiUrl = APIConfig.addToCart; //TODO

    try {
      // Send POST request to add product to cart
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user": globals.userContactValue,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Change the number of columns in the grid
                childAspectRatio: 0.6, // Aspect ratio to control item height
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final int rating = product['rating'] ?? 0.0; // Get rating, default to 0.0
                final int price = product['price'] ?? 0; // Get price as int
                final bool isInStock = product['stock'] > 0; // Stock availability check

                return GestureDetector( // Wrap Card with GestureDetector
                  onTap: () {
                    // Navigate to ProductDetailScreen when the product is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: product['productId']),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Image.network(
                            (product['imageUrl'] != null && product['imageUrl'].isNotEmpty)
                                ? product['imageUrl']
                                : APIConfig.logoUrl, // Default image URL
                            fit: BoxFit.cover,
                            height: 100, // Set a fixed height for the image
                            width: double.infinity,
                          ),

                          SizedBox(height: 30.0),

                          // Product Name
                          Text(
                            product['name'] ?? 'Unknown Name of Product',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 5.0),

                          // Rating with Stars
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < rating
                                    ? Icons.star
                                    : Icons.star_border, // Filled or empty star
                                color: Colors.amber,
                                size: 16.0,
                              );
                            }),
                          ),

                          SizedBox(height: 5.0),

                          // Price
                          Text(
                            "\₹ $price", // Display price as integer
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 5.0),

                          // Stock Status
                          Text(
                            isInStock ? "In Stock" : "Out of Stock",
                            style: TextStyle(
                              color: isInStock ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10.0),

                          // Add to Cart Button
                          ElevatedButton(
                            onPressed: isInStock
                                ? () {
                                    // Call the addToCart method with the required productId and quantity
                                    addToCart(context, product['productId'], 1);
                                  }
                                : null, // Disable button if out of stock
                            child: Text("Add to Cart"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInStock
                                  ? Colors.blue
                                  : Colors.grey, // Change button color based on stock
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
