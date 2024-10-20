import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class SuperUserPanel extends StatefulWidget {
  @override
  _SuperUserPanelState createState() => _SuperUserPanelState();
}

class _SuperUserPanelState extends State<SuperUserPanel> {
  List users = [];

  // Fetch all users from the server
  Future<void> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.31.23:5000/users/all'),
        headers: {
          'Authorization': 'admin',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if jsonResponse is a Map and contains the 'users' key
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('users')) {
          setState(() {
            users = jsonResponse['users']; // Extract the list of users
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users');
    }
  }

  // Update user role on the server
  Future<void> updateUserRole(String userId, String newRole) async {
    final response = await http.put(
      Uri.parse('http://192.168.31.23:5000/users/updateRole'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode({'user': userId, 'role': newRole}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user role');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  // Pull-to-refresh functionality
  Future<void> _onRefresh() async {
    await fetchAllUsers(); // Fetch users again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super User Panel'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Add pull-to-refresh functionality
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  String userId = user['_id'];
                  String name = user['firstName'];
                  String currentRole = user['role'];

                  return Card(
                    elevation: 4, // Add elevation for card shadow
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                    child: ListTile(
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text('Role: $currentRole',
                          style: TextStyle(color: Colors.grey)),
                      
                      trailing: DropdownButton<String>(
                        value: currentRole,
                        items: ['Admin', 'DeliveryBoy', 'Customer']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newRole) {
                          if (newRole != null) {
                            setState(() {
                              updateUserRole(
                                  userId, newRole); // Update role in MongoDB
                              user['role'] = newRole;
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
