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
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProductDetails(); // Fetch product details when the screen is initialized
    checkIfProductInCart(); // Check if the product is already in the cart
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
        checkIfProductInCart(); // Refresh cart data after update
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final response =
          await http.get(Uri.parse(APIConfig.getProduct + widget.productId));
      if (response.statusCode == 200) {
        setState(() {
          productDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> checkIfProductInCart() async {
    try {
      final cartResponse = await http.get(Uri.parse(
          APIConfig.getAllItemInCart + globals.userContactValue.toString()));
      if (cartResponse.statusCode == 200) {
        final cartData = json.decode(cartResponse.body);
        List<dynamic> cartItems = cartData['items'] ?? [];
        final cartItem = cartItems.firstWhere(
            (item) => item['productId'] == widget.productId,
            orElse: () => null);
        if (cartItem != null) {
          setState(() {
            quantityInCart = cartItem['quantity'];
          });
        }
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error checking product in cart: $e');
    }
  }

  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    final String apiUrl = APIConfig.addToCart;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user": globals.userContactValue,
          'productId': productId,
          'quantity': quantity,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          quantityInCart += quantity;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Product added to cart!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add product to cart!')));
      }
    } catch (error) {
      print('Error adding product to cart: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong!')));
    }
  }

  Future<void> deleteItem(String itemId) async {
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
          quantityInCart = 0; // Remove the item from the list
        });
        checkIfProductInCart(); // Refresh cart data after update
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  void updateCartQuantity(int newQuantity) {
    setState(() {
      quantityInCart = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    if (hasError || productDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(
          child: Text('Failed to load product details',
              style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    }

    final isInStock = productDetails!['stock'] > 0;
    final double mrp =
        (productDetails!['mrp'] != null && productDetails!['mrp'] is num)
            ? productDetails!['mrp'].toDouble()
            : 0.0;
    final double price =
        (productDetails!['price'] != null && productDetails!['price'] is num)
            ? productDetails!['price'].toDouble()
            : 0.0;

    // Safeguard to avoid division by zero and ensure discount is a valid percentage
    final int discountPercentage =
        (mrp > 0) ? ((mrp - price) / mrp * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with shadow and error handling
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // Rounded edges
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(66, 85, 80, 70), // Shadow color
                    blurRadius: 5, // Softer shadow for subtle effect
                    offset: Offset(0, 3), // Move shadow down slightly
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio:
                      4 / 3, // Maintain a 16:9 aspect ratio (adjust as needed)
                  child: Image.network(
                    productDetails!['imageUrl'] ?? APIConfig.logoUrl,
                    fit: BoxFit
                        .cover, // Use BoxFit.cover to maintain aspect ratio
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        APIConfig.logoUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
            Divider(thickness: 2),

            // Product name
            Text(
              productDetails!['name'] ?? 'Unknown Product',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Discount badge above the price
            if (discountPercentage > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],

            // Price, MRP, and discount
            Row(
              children: [
                Text(
                  '₹$price',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(width: 8),
                if (mrp > price)
                  Text(
                    '₹$mrp',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),

            // Product description
            Text(
              productDetails!['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Stock availability
            Text(
              isInStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                  fontSize: 18, color: isInStock ? Colors.green : Colors.red),
            ),
            SizedBox(height: 16),

            // Product rating and rating count
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              color: Colors.green,
                              onPressed: quantityInCart > 1
                                  ? () {
                                      updateQuantity(
                                          widget.productId, quantityInCart - 1);
                                    }
                                  : () {
                                      deleteItem(widget
                                          .productId); // Call deleteItem when quantity is 1
                                    },
                            ),
                            Text(
                              '$quantityInCart',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.green,
                              onPressed: isInStock
                                  ? () {
                                      updateQuantity(
                                          widget.productId, quantityInCart + 1);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: isInStock
                        ? () {
                            addToCart(context, widget.productId, 1);
                          }
                        : null,
                    child: Text('Add to Cart'),
                  ),
          ],
        ),
      ),
    );
  }
}
