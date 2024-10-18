import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:ajio_mart/models/categories_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:ajio_mart/theme/app_colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // Import your AppColors file

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  String? contactType = "";
  String? contactValue = "";
  String? firstName = "";
  String? lastName = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // Set AppBar color from AppColors
        title: Text(
            'Welcome to the Ajio Mart', 
            style: TextStyle(color: AppColors.textColor)), // Set text color
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: AppColors.secondaryColor), // Hint text color
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderColor), // Use border color
                ),
                suffixIcon: Icon(Icons.search, color: AppColors.accentColor), // Icon color
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentColor)) // Loader color
          : Column(
              children: [
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
                // Categories Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(context, screen: ProductScreen(
                                categoryId:
                                    category.categoryId,
                                categoryName: category.name,
                              ),
                              withNavBar: true,
                              );
                        },
                        child: Card(
                          elevation: 2,
                          color: AppColors.backgroundColor, // Card background color
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
                                      color: AppColors.textColor), // Set text color
                                ),
                              ),
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
}
