import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart'; // Assuming this model exists
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CategoryHomeWidget extends StatefulWidget {
  final String heading;
  final String description;
  final String categoryId;
  final int numberOfProducts;


  CategoryHomeWidget({
    required this.heading,
    required this.description,
    required this.categoryId,
    required this.numberOfProducts,
  });

  @override
  _CategoryHomeWidgetState createState() => _CategoryHomeWidgetState();
}

class _CategoryHomeWidgetState extends State<CategoryHomeWidget> {
  List<Product> products = [];
  bool isLoading = true;
  bool showViewAll = true;

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.categoryId); // Call API when the widget initializes
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
  Future<void> fetchProduct(String categoryId) async {
    try {
      print("fetchProduct called in category widget");
      final url = APIConfig.getAllProductsInCategory + categoryId;

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic>? data = json.decode(response.body);

        if (data != null && data.isNotEmpty) {
          products.clear(); // Clear any existing data before adding new
          for (var item in data) {
            final product = Product.fromJson(item); // Assuming fromJson handles null values
            products.add(product);
          }
        } else {
          print('No products available.');
        }
      } else {
        print('Failed to load product: ${response.statusCode}');
      }
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
    if (products.isEmpty && !isLoading) {
      // If there are no products and data loading is complete, don't display the widget
      return SizedBox.shrink();
    }

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
              if (showViewAll && onViewAllTap != null)
                GestureDetector(
                  onTap: onViewAllTap,
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
        isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner
            : Container(
                height: 240,
                child: products.isEmpty
                    ? Center(
                        child: Text('No products available.'), // Show a message if no products
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.numberOfProducts < products.length
                            ? widget.numberOfProducts + (showViewAll ? 1 : 0)
                            : products.length,
                        itemBuilder: (context, index) {
                          if (index < widget.numberOfProducts && index < products.length) {
                            return _buildProductCard(products[index]);
                          } else if (showViewAll && index == widget.numberOfProducts) {
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
      if (product.id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      }
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
              product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? product.imageUrl!
                  : 'https://via.placeholder.com/150', // Use placeholder if imageUrl is null or empty
              height: 120, // Larger image height
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.network(
                'https://via.placeholder.com/150', // Placeholder for invalid URLs
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),

          // Product Name
          if (product.name != null)
            Text(
              product.name!,
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
              if (product.mrp != null)
                Text(
                  '\₹${product.mrp!.toStringAsFixed(2)}', // Show MRP
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              SizedBox(width: 5),
              if (product.price != null)
                Text(
                  '\₹${product.price!.toStringAsFixed(2)}', // Show discounted price
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


  Widget _buildViewAllButton() {
    return InkWell(
      onTap: onViewAllTap,
      borderRadius: BorderRadius.circular(50), // For the circular shape
      child: Container(
        width: 80,
        height: 80, // Equal width and height for a circular button
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(3, 3),
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
