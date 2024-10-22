import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart'; // Assuming this model exists

class SpecialHomeWidget extends StatelessWidget {
  final String heading;
  final List<Product> products;
  final int numberOfProducts;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;

  SpecialHomeWidget({
    required this.heading,
    required this.products,
    required this.numberOfProducts,
    required this.showViewAll,
    this.onViewAllTap,
  });

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
                heading,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (showViewAll &&
                  onViewAllTap !=
                      null) // Only show the button if the callback is provided
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
            itemCount: numberOfProducts < products.length
                ? numberOfProducts + (showViewAll ? 1 : 0)
                : products.length,
            itemBuilder: (context, index) {
              if (index < numberOfProducts && index < products.length) {
                return _buildProductCard(products[index]);
              } else if (showViewAll && index == numberOfProducts) {
                return _buildViewAllButton();
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  // Product card with 3D effect and vertical spacing
  Widget _buildProductCard(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 8, vertical: 12), // Added vertical spacing
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
          Text(
            '\₹${product.price}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
        ],
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