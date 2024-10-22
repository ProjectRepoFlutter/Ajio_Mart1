import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/models/product_model.dart';
import 'package:ajio_mart/widgets/special_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:ajio_mart/models/categories_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:ajio_mart/theme/app_colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onHomeSelected; // Add this parameter

  const HomeScreen({Key? key, this.onHomeSelected}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  // Variable for the number of products to display.
  final int numberOfProducts = 5; // This can be set dynamically
  final List<Product> products = [
  Product(
    id: '1', // Placeholder ID
    name: 'Jacket',
    description: 'A warm, stylish jacket for cold weather.', // Add description
    price: 305.0, // Convert price to double without currency symbol
    imageUrl: 'https://example.com/jacket.jpg', // Placeholder image URL
  ),
  Product(
    id: '2', // Placeholder ID
    name: 'Cap',
    description: 'A trendy cap for all seasons.', // Add description
    price: 115.0, // Convert price to double without currency symbol
    imageUrl: 'https://example.com/cap.jpg', // Placeholder image URL
  ),
  Product(
    id: '3', // Placeholder ID
    name: 'Boots',
    description: 'Durable boots perfect for hiking.', // Add description
    price: 105.0, // Convert price to double without currency symbol
    imageUrl: 'https://example.com/boots.jpg', // Placeholder image URL
  ),
  Product(
    id: '4', // Placeholder ID
    name: 'Heater',
    description: 'A portable heater to keep you warm.', // Add description
    price: 450.0, // Convert price to double without currency symbol
    imageUrl: 'https://example.com/heater.jpg', // Placeholder image URL
  ),
  Product(
    id: '5', // Placeholder ID
    name: 'Blanket',
    description: 'A cozy blanket for a good night\'s sleep.', // Add description
    price: 125.0, // Convert price to double without currency symbol
    imageUrl: 'https://example.com/blanket.jpg', // Placeholder image URL
  ),
];

  String category1 = "Essentials";

  void refresh() {
    // Logic to refresh the home screen, e.g., fetch new data
    print('HomeScreen refreshed');
    // You can call your data fetching method here
    fetchCategories();
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getAllCategories));
      if (response.statusCode == 200) {
        final List<dynamic> categoryList = jsonDecode(response.body);
        setState(() {
          categories =
              categoryList.map((json) => Category.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Pull-to-refresh functionality
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Set loading to true while refreshing
    });
    await fetchCategories(); // Fetch the categories again
  }

  Widget buildHorizontalList(String title, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(left: 16.0),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(item['imageUrl'],
                            height: 120, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text("\$${item['price']}",
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onHomeSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onHomeSelected!(); // Call the callback to update index
      });
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData, // Set the refresh function
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 170.0, // Height when fully expanded
              collapsedHeight: 60.0, // Height when collapsed
              backgroundColor:
                  Colors.amberAccent, // Background color transition
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    children: [
                      // Background image
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                APIConfig.logoUrl), // Replace with your image URL
                            fit: BoxFit.cover, // Cover the entire area
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60), // Height of the search bar
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50, // Increased height for better aesthetics
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Icon(Icons.search, color: Colors.grey),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Divider(), // Adding a separator

                  // Carousel Slider
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 150.0,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                    ),
                    items: [
                      APIConfig.logoUrl,
                      APIConfig.logoUrl,
                      'https://via.placeholder.com/600x200.png?text=Slide+3',
                    ]
                        .map((item) => Container(
                              child: Center(
                                child: Image.network(item,
                                    fit: BoxFit.cover, width: 1000),
                              ),
                            ))
                        .toList(),
                  ),
                  Divider(), // Adding a separator

                  SpecialHomeWidget(
                    heading: 'Electronics',
                    products: products,
                    numberOfProducts: 4,
                    showViewAll: true, // Show "View All" button
                    onViewAllTap: () {
                      // Navigate to all Electronics products
                      PersistentNavBarNavigator.pushNewScreen(context,
                              screen: ProductScreen(
                                categoryId: "1",
                                categoryName: "bottle",
                              ),
                              withNavBar: true);
                            print("View All clicked");
                    },
                  ),
                  SpecialHomeWidget(
                    heading: 'Fashion',
                    products: products,
                    numberOfProducts: 4,
                    showViewAll: false, // Hide "View All" button
                  ),
                  //grid 1
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category1,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle "View All" button tap event
                            PersistentNavBarNavigator.pushNewScreen(context,
                              screen: ProductScreen(
                                categoryId: "1",
                                categoryName: "bottle",
                              ),
                              withNavBar: true);
                            print("View All clicked");
                          },
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
                  // Horizontal scrollable list of products
                  // Container(
                  //   height: 200,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: numberOfProducts +
                  //         1, // +1 for the "View All" button at the end
                  //     itemBuilder: (context, index) {
                  //       if (index < numberOfProducts &&
                  //           index < products.length) {
                  //         return _buildProductCard(products[index]);
                  //       } else {
                  //         return _buildViewAllButton();
                  //       }
                  //     },
                  //   ),
                  // ),
                  Divider(), // Adding a separator

                  // Categories Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(context,
                              screen: ProductScreen(
                                categoryId: category.categoryId,
                                categoryName: category.name,
                              ),
                              withNavBar: true);
                        },
                        child: Card(
                          elevation: 2,
                          color: AppColors.backgroundColor,
                          child: Column(
                            children: [
                              Image.network(category.imageUrl,
                                  fit: BoxFit.cover),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 3.0,
        child: Column(
          children: [
            Image.network(
              'https://via.placeholder.com/150',
              height: 100,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              product['price'],
              style: TextStyle(color: Colors.green),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color:
                      index < product['rating'] ? Colors.yellow : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 3.0,
        child: Center(
          child: Text(
            'View All',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
