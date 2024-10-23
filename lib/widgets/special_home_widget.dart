import 'dart:convert';

import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart'; // Assuming this model exists
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class SpecialHomeWidget extends StatefulWidget {
  final String heading;
  final List<String> products;
  final int numberOfProducts;
  final bool showViewAll;

  SpecialHomeWidget({
    required this.heading,
    required this.products,
    required this.numberOfProducts,
    required this.showViewAll,
  });
  @override
  _SpecialHomeWidgetState createState() => _SpecialHomeWidgetState();
}
class _SpecialHomeWidgetState extends State<SpecialHomeWidget> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.products); // Call API when the widget initializes
  }
  void onViewAllTap(){
    PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ProductScreen(
                                products: products,
                                categoryName: widget.heading,
                              ),
                              withNavBar: true,
                            );
  }
   Future<void> fetchProduct(List<String> produc) async {
    try {
      print(produc);
      for (var productId in produc) {
        final url =
            APIConfig.getProduct + productId; // Replace with your API URL

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          print(data); // Print the raw JSON data for debugging

          final product = Product.fromJson(data);

          products.add(Product(
              id: product.id,
              description: product.description,
              name: product.name,
              mrp: product.mrp,
              price: product.price,
              imageUrl: product.imageUrl,
              stock: product.stock,
              rating: product.rating,
              ratingCount: product.ratingCount,                        
              ));
          print(products.length);
        } else {
          print('Failed to load product: ${response.statusCode}');
        }
      };
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading and "View All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.heading,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
            : Container(
                height: 200, // Set the height of the product display area
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.numberOfProducts,
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      return _buildProductCard(products[index]);
                    } else {
                      return Container(); // Return an empty container if there are fewer products
                    }
                  },
                ),
              ),
              if (widget.showViewAll) // Only show the button if the callback is provided
                GestureDetector(
                  onTap: onViewAllTap, // Ensure this is provided
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Horizontal list of products
        Container(
          height: 240, // Adjusted height for larger images
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.numberOfProducts < products.length
                ? widget.numberOfProducts + (widget.showViewAll ? 1 : 0)
                : products.length,
            itemBuilder: (context, index) {
              if (index < widget.numberOfProducts && index < products.length) {
                return _buildProductCard(products[index]);
              } else if (widget.showViewAll && index == widget.numberOfProducts) {
                return _buildViewAllButton();
              }
              return SizedBox.shrink();
            },
          ),
        ),
        Divider(),
      ],
    );
  }


Widget _buildProductCard(Product product) {
  // Calculate percentage discount
  double discountPercentage = 0;
  if (product.mrp > product.price && product.mrp > 0) {
    discountPercentage = ((product.mrp - product.price) / product.mrp) * 100;
  }

  return InkWell(
    onTap: () {
      // Action when a product is tapped
      // Example: Navigate to product details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: product.id),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      width: 160, // Slightly larger width for better visuals
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: Offset(5, 5), // Adds 3D shadow effect
            blurRadius: 10,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(-3, -3), // Slight top-left shadow for depth
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              product.imageUrl,
              height: 120, // Larger image height
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),

          // Product Name
          Text(
            product.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),

          // MRP (crossed out) and Discounted Price
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\₹${product.mrp.toStringAsFixed(2)}', // Show MRP
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough, // Strikethrough for MRP
                ),
              ),
              SizedBox(width: 5),
              Text(
                '\₹${product.price.toStringAsFixed(2)}', // Show discounted price
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),

          // Discount percentage
          if (discountPercentage > 0)
            Text(
              '${discountPercentage.toStringAsFixed(1)}% off', // Show percentage off
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    ),
  );
}


  // "View All" button using InkWell for better tap handling and visual feedback
 // "View All" button using InkWell for better tap handling and visual feedback
Widget _buildViewAllButton() {
  return InkWell(
    onTap: onViewAllTap, // Ensure this callback is provided
    borderRadius: BorderRadius.circular(50), // For the circular shape
    child: Container(
      width: 80, // Adjusted size to make the button circular
      height: 80, // Equal width and height for a circular button
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle, // Circular shape for the container
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(3, 3), // Slight 3D effect on "View All"
          ),
        ],
      ),
      child: Center(
        child: Text(
          'View All',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12, // Adjusted font size to fit the circular button
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
}