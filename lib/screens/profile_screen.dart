import 'package:ajio_mart/screens/login_screen.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Full Name section
          ListTile(
            leading: Icon(Icons.person),
            title: Text('${globals.userFullName}'),
            subtitle: Text('${globals.userContactValue}'),
            onTap: () {
              // Navigate to Edit Full Name Screen
            },
          ),
          Divider(),

          // Your Addresses section
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Your Addresses'),
            onTap: () {
              // Navigate to the Address Management Screen
              Navigator.pushNamed(context, '/addressScreen');
            },
          ),
          Divider(),

          // Orders section
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Orders'),
            onTap: () {
              // Navigate to Orders Screen
              Navigator.pushNamed(context, '/ordersScreen');
            },
          ),
          Divider(),

          // Help and Support section
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help and Support'),
            onTap: () {
              // Navigate to Help and Support Screen
              Navigator.pushNamed(context, '/helpSupportScreen');
            },
          ),
          Divider(),

          // Logout section
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout functionality
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Handle logout logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SharedPrefsHelper.clearUserData();
              // Navigate to the login screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen()), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
