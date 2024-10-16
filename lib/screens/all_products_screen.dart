import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';

class AllProductScreen extends StatefulWidget {

  const AllProductScreen();

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<AllProductScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse(APIConfig.getProduct));
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
    final String apiUrl = APIConfig.addToCart; //TODO

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final int rating =
                    product['rating'] ?? 0.0;
                final int price = product['price'] ?? 0;
                final bool isInStock =
                    product['stock'] > 0;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          (product['imageUrl'] != null &&
                                  product['imageUrl'].isNotEmpty)
                              ? product['imageUrl']
                              : APIConfig.logoUrl,
                          fit: BoxFit.cover,
                          height: 100,
                          width: double.infinity,
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
                        Text(
                          "\₹ $price",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                        ElevatedButton(
                          onPressed: isInStock
                              ? () {
                                  addToCart(context, product['productId'], 1);
                                }
                              : null,
                          child: Text("Add to Cart"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInStock
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
