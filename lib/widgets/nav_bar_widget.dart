import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ajio_mart/screens/home_screen.dart';
import 'package:ajio_mart/screens/cart_screen.dart'; // Import your CartScreen
import 'package:ajio_mart/screens/profile_screen.dart';
import 'package:ajio_mart/screens/all_products_screen.dart';
import 'package:ajio_mart/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'dart:convert';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({Key? key}) : super(key: key);

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  final _controller = PersistentTabController(initialIndex: 0);
  int _currentIndex = 0; // Track the currently selected index

  @override
  void initState() {
    setContact();
    super.initState();
  }

  List<Widget> screens() {
    return [
      const HomeScreen(),
      const AllProductScreen(),
      const CartScreen(),
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

  static Future<void> getUserInfo(String? contactType, String? contactValue) async {
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

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index; // Update the current index
    });
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
