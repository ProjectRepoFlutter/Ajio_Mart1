import 'package:flutter/material.dart';
import 'package:ajio_mart/screens/home_screen.dart'; // Import your HomeScreen
import 'package:ajio_mart/screens/product_list_screen.dart'; // Import your ProductScreen
import 'package:ajio_mart/screens/cart_screen.dart'; // Import your CartScreen
import 'package:ajio_mart/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0; // Current index of the Bottom Navigation Bar
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Define your screens here
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Initialize the screens in initState
    _screens.addAll([
      HomeScreen(), // Pass the callback here
      // Center(child: Text("Select a category")),
      CartScreen(),
      CartScreen(),
      ProfileScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index when tapped
      if (index == 1) { // If navigating to Categories
        _selectedCategoryId = null; // Reset category selection
        _selectedCategoryName = null;
      }
    });
  }

  // Method to select a category and navigate to product list
  void selectCategory(String categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId; // Set selected category ID
      _selectedCategoryName = categoryName;
      _currentIndex = 1; // Switch to Products tab
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = _screens[_currentIndex];

    // If in Products and a category is selected, show the product list
    if (_currentIndex == 1 && _selectedCategoryId != null) {
      currentScreen = ProductScreen(categoryId: _selectedCategoryId!, categoryName: _selectedCategoryName!);
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
        ],
        currentIndex: _currentIndex, // Highlight the currently selected item
        onTap: _onItemTapped, // Call the method when an item is tapped
      ),
    );
  }
}
