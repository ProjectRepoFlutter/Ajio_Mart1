import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:ajio_mart/models/categories_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/screens/login_screen.dart';
import 'package:ajio_mart/widgets/main_scaffold.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;

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
  String? contactValue = "User";
  String? firstName = "";
  String? lastName = "";

  @override
  void initState() {
    initializeData();
    super.initState();
    fetchCategories();

    print(globals.userFirstName);
  }

  Future<void> initializeData() async {
    await setContact();

    // Wait until the user info is fetched
    await getUserInfo();

    // Now that the user info is fetched, set the globals and other values
    globals.setUserData(contactType.toString(), contactValue.toString(),firstName.toString(), lastName.toString());
  }

  Future<void> setContact() async {
    Map<String, String?> userCredentials =
        await SharedPrefsHelper.getUserContactInfo();
    contactType = userCredentials['contactType'];
    contactValue = userCredentials['contactValue'];
  }

  // Method to fetch user information
  Future<void> getUserInfo() async {
    try {
      final response = await http
          .get(Uri.parse(APIConfig.getUserInfo + contactValue.toString()));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userInfo = jsonDecode(response.body)['user'];

        // Store firstName and lastName in global variables
        firstName = userInfo['firstName'];
        lastName = userInfo['lastName'];
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
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

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   // Handle navigation based on index
  //   if (index == 0) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => HomeScreen()
  //       ),
  //     );
  //   } else if (index == 1) {
  //     // Navigate to Categories
  //   } else if (index == 2) {
  //     // Navigate to Cart
  //   } else if (index == 3) {
  //     // Navigate to Favourites
  //   } else if (index == 4) {
  //     // Navigate to Profile
  //      Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LoginScreen()
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Welcome, ${globals.userFirstName}'), // Greeting user with contact value
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
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
          ? Center(child: CircularProgressIndicator())
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                categoryId:
                                    category.categoryId, // Pass categoryId
                                categoryName: category
                                    .name, // Optionally pass category name
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          child: Column(
                            children: [
                              Image.network(category.imageUrl,
                                  fit: BoxFit.cover),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  category.name, // Display category name
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
      // // Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.category),
      //       label: 'Categories',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Cart',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite),
      //       label: 'Favourites',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
