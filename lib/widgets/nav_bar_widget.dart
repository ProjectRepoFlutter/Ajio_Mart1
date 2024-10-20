import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ajio_mart/screens/home_screen.dart';
import 'package:ajio_mart/screens/cart_screen.dart';
import 'package:ajio_mart/screens/profile_screen.dart';
import 'package:ajio_mart/screens/all_products_screen.dart';
import 'package:ajio_mart/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'dart:convert';

class NavBarWidget extends StatefulWidget {
  final String? contactType;
  final String? contactValue;
  const NavBarWidget({Key? key, this.contactType, this.contactValue})
      : super(key: key);

  @override
  NavBarWidgetState createState() => NavBarWidgetState();
}

class NavBarWidgetState extends State<NavBarWidget> {
  final _controller = PersistentTabController(initialIndex: 0);
  int _currentIndex = 0; // Track the currently selected index

  // Create GlobalKeys for each screen
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey();
  final GlobalKey<ProductScreenState> _productKey = GlobalKey();
  final GlobalKey<CartScreenState> _cartKey = GlobalKey();

  @override
  void initState() {
    if (widget.contactType != null && widget.contactValue != null) {
      getUserInfo(widget.contactType, widget.contactValue);
    } else {
      setContact();
    }
    super.initState();
  }

  // Method to update the current index
  void updateCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      _controller.index = index; // Update the controller's index
    });
  }

  // Refresh the state of the selected screen
  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      // If the same tab is selected, refresh the content
      switch (index) {
        case 0:
          _homeKey.currentState?.refresh(); // Refresh HomeScreen
          break;
        case 1:
          _productKey.currentState?.refresh(); // Refresh AllProductScreen
          break;
        case 2:
          _cartKey.currentState?.refresh(); // Refresh CartScreen
          break;
      }
    } else {
      // If a different tab is selected, update the index
      updateCurrentIndex(index);
    }
  }

  List<Widget> screens() {
    return [
      HomeScreen(key: _homeKey), // Ensure HomeScreen has refresh method
      AllProductScreen(
          key: _productKey), // Ensure AllProductScreen has refresh method
      CartScreen(key: _cartKey), // Ensure CartScreen has refresh method
      ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: 'Home',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.store),
        title: 'Products',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.shopping_cart),
        title: 'Cart',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: 'Profile',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  Future<void> setContact() async {
    Map<String, String?> userCredentials =
        await SharedPrefsHelper.getUserContactInfo();
    String? contactType = userCredentials['contactType'];
    String? contactValue = userCredentials['contactValue'];
    await getUserInfo(contactType, contactValue);
  }

  static Future<void> getUserInfo(
      String? contactType, String? contactValue) async {
    try {
      final response = await http
          .get(Uri.parse(APIConfig.getUserInfo + contactValue.toString()));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userInfo = jsonDecode(response.body)['user'];
        String firstName = userInfo['firstName'];
        String lastName = userInfo['lastName'];
        globals.setUserData(contactType, contactValue, firstName, lastName);
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: screens(),
      items: navBarItems(),
      controller: _controller,
      navBarStyle: NavBarStyle.style1,
      onItemSelected: _onTabSelected, // Call the method on item selection
    );
  }
}
