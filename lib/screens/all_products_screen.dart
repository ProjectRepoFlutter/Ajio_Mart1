import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';
import 'package:ajio_mart/screens/product_detail_screen.dart';

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({Key? key}) : super(key: key);

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<AllProductScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  // Map to store quantity of each product in the cart
  Map<String, int> productQuantities = {};

  void refresh() {
    fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Set loading to true while refreshing
    });
    await fetchProducts(); // Fetch the categories again
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getProduct));
      if (response.statusCode == 200) {
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
    final String apiUrl = APIConfig.addToCart;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user": globals.userContactValue,
          'productId': productId,
          'quantity': quantity,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          productQuantities[productId] =
              quantity; // Set the quantity in the cart
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
        setState(() {
          productQuantities[itemId] = newQuantity; // Update quantity locally
        }); // Refresh cart data after update
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
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
          productQuantities.remove(itemId); // Remove the item from the list
        });
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final productId = product['productId'];
                  final double price = (product['price'] is int)
                      ? (product['price'] as int).toDouble()
                      : product['price'] ?? 0.0;

                  final double mrp = (product['mrp'] is int)
                      ? (product['mrp'] as int).toDouble()
                      : product['mrp'] ?? 0.0;

                  final int rating = product['rating'] ?? 0;
                  final bool isInStock = product['stock'] > 0;

                  final double discountPercentage = mrp > price
                      ? ((mrp - price) / mrp * 100).roundToDouble()
                      : 0.0;

                  final quantityInCart = productQuantities[productId] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(productId: productId),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              product['imageUrl'] != null &&
                                      product['imageUrl'].isNotEmpty
                                  ? product['imageUrl']
                                  : APIConfig.logoUrl,
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                // Display a fallback image or placeholder when the image fails to load
                                return Image.network(
                                  APIConfig.logoUrl, // Fallback image
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: double.infinity,
                                );
                              },
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              product['name'] ?? 'Unknown Name of Product',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16.0,
                                );
                              }),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Text(
                                  "\₹ ${price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                if (mrp > price)
                                  Text(
                                    "\₹ ${mrp.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (mrp > price)
                              Text(
                                '$discountPercentage% OFF',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 5.0),
                            Text(
                              isInStock ? "In Stock" : "Out of Stock",
                              style: TextStyle(
                                color: isInStock ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.0),

                            // Add to Cart / Increment / Decrement section
                            quantityInCart > 0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              color: Colors.green,
                                              onPressed: quantityInCart > 1
                                                  ? () {
                                                      updateQuantity(productId,
                                                          quantityInCart - 1);
                                                    }
                                                  : () {
                                                      deleteItem(
                                                          productId); // Call deleteItem when quantity is 1
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
                                                      updateQuantity(productId,
                                                          quantityInCart + 1);
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
                                            addToCart(context, productId, 1);
                                          }
                                        : null,
                                    child: Text('Add to Cart'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
