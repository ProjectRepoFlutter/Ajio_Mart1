import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/theme/app_colors.dart'; // Import your app colors file
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<dynamic> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAddresses();  // Fetch addresses when screen initializes
  }

  Future<void> fetchAddresses() async {
    final url = APIConfig.getAllAddresses + globals.userContactValue.toString(); // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> addressList = jsonDecode(response.body);
        setState(() {
          addresses = addressList.map((json) => {
                'id': json['_id'].toString(),
                'user': json['user'],
                'city': json['city'],
                'label': json['label'], // Add type for "Work" or "Home"
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void editAddress(int index) {
    // Implement API call and logic for editing address
    print('Edit address at index: $index');
  }

  Future<void> deleteAddress(int index) async {
    final url = 'https://api.example.com/addresses/${addresses[index]['id']}'; // Replace with your API URL
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          addresses.removeAt(index);
        });
        print('Deleted address at index: $index');
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Text(
                    'No addresses available.',
                    style: TextStyle(color: AppColors.textColor, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Heading with Name
                            Text(
                              address['label']!, // Display the name as heading
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),

                            // Subheading with Work/Home
                            Text(
                              address['user']!, // Display Work/Home as subheading
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            SizedBox(height: 8),

                            // Address
                            Text(
                              address['city']!,
                              style: TextStyle(
                                color: AppColors.textColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.edit, color: AppColors.accentColor),
                                  label: Text(
                                    'Edit',
                                    style: TextStyle(color: AppColors.accentColor),
                                  ),
                                  onPressed: () => editAddress(index),
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => deleteAddress(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentColor,
        onPressed: () {
          // Implement add new address functionality here
        },
        child: Icon(Icons.add, color: AppColors.backgroundColor),
      ),
    );
  }
}
