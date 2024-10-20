import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List products = [];
  List filteredProducts = []; // For product search
  List categories = [];
  List filteredCategories = []; // For category search
  bool isLoading = true;
  String searchTerm = ''; // For product search term
  String categorySearchTerm = ''; // For category search term

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  // Fetch products from API
  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://192.168.170.164:5000/products'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        filteredProducts = products; // Initially all products
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://192.168.170.164:5000/categories'));

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
        filteredCategories = categories; // Initially all categories
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Delete a product
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('http://192.168.170.164:5000/products/$id'));

    if (response.statusCode == 200) {
      fetchProducts(); // Refresh the list after deletion
    } else {
      throw Exception('Failed to delete product');
    }
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('http://192.168.170.164:5000/categories/$id'));

    if (response.statusCode == 200) {
      fetchCategories(); // Refresh the list after deletion
    } else {
      throw Exception('Failed to delete category');
    }
  }

  // Add a new product
  Future<void> addProduct(String productId, String name, String categoryId, String description, int price, int stock, String imageUrl) async {
    final response = await http.post(
      Uri.parse('http://192.168.170.164:5000/products'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode({
        'productId': productId,
        'name': name,
        'categoryId': categoryId,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl // Sample image for now
      }),
    );

    if (response.statusCode == 201) {
      fetchProducts(); // Refresh the product list after adding
    } else {
      throw Exception('Failed to add product');
    }
  }

  // Add a new category
  Future<void> addCategory(String categoryId, String name, String description, String imageUrl) async {
    final response = await http.post(
      Uri.parse('http://192.168.170.164:5000/categories'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode({
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl
      }),
    );

    if (response.statusCode == 201) {
      fetchCategories(); // Refresh the category list after adding
    } else {
      throw Exception('Failed to add category');
    }
  }

  // Search products
  void searchProducts(String searchTerm) {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product['name'].toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  // Search categories
  void searchCategories(String searchTerm) {
    setState(() {
      filteredCategories = categories
          .where((category) =>
              category['name'].toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section for Product Management with Search
                    _buildSectionTitle('Products', context),
                    SizedBox(height: 10),
                    _buildSearchBar('Search Products', searchProducts),
                    SizedBox(height: 10),
                    _buildProductList(context),

                    SizedBox(height: 20),
                    // Section for Category Management with Search
                    _buildSectionTitle('Categories', context),
                    SizedBox(height: 10),
                    _buildSearchBar('Search Categories', searchCategories),
                    SizedBox(height: 10),
                    _buildCategoryList(context),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildFABMenu(context),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar(String label, Function(String) onSearchChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        onSearchChanged(value);
      },
    );
  }

  // Dynamically build product list with search functionality
  Widget _buildProductList(BuildContext context) {
    return Column(
      children: filteredProducts.map((product) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(product['imageUrl'] ?? 'https://via.placeholder.com/150'), // Fetch from API
            ),
            title: Text(product['name']),
            subtitle: Text('CategoryId: ${product['categoryId']}\nStock: ${product['stock']}\nPrice: ₹${product['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteProduct(product['id']);
              },
            ),
            onTap: () {
              // Navigate to product details or edit screen
            },
          ),
        );
      }).toList(),
    );
  }

  // Dynamically build category list with search functionality
  Widget _buildCategoryList(BuildContext context) {
    return Column(
      children: filteredCategories.map((category) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(category['imageUrl'] ?? 'https://via.placeholder.com/150'), // Fetch from API
            ),
            title: Text(category['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteCategory(category['id']);
              },
            ),
            onTap: () {
              // Navigate to category details or edit screen
            },
          ),
        );
      }).toList(),
    );
  }

  // Floating Action Button Menu for creating new products or categories
  Widget _buildFABMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          label: const Text('Add Product'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            _showAddProductDialog();
          },
        ),
        SizedBox(height: 10),
        FloatingActionButton.extended(
          label: const Text('Add Category'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            _showAddCategoryDialog();
          },
        ),
      ],
    );
  }

  // Dialog to add new product
  void _showAddProductDialog() {
    String productId = '';
    String name = '';
    String description = '';
    String categoryId = '';
    int price = 0;
    int stock = 0;
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Fields to input new product details
                TextField(
                  decoration: InputDecoration(labelText: 'ProductId'),
                  onChanged: (value) {
                    productId = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Product Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'CategoryId'),
                  onChanged: (value) {
                    categoryId = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    price = int.tryParse(value) ?? 0;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    stock = int.tryParse(value) ?? 0;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Image URL'),
                  onChanged: (value) {
                    imageUrl = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                addProduct(productId, name, categoryId, description, price, stock, imageUrl);
                Navigator.of(context).pop(); // Close the dialog after adding
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to add new category
  void _showAddCategoryDialog() {
    String categoryId = '';
    String name = '';
    String description = '';
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Fields to input new category details
                TextField(
                  decoration: InputDecoration(labelText: 'CategoryId'),
                  onChanged: (value) {
                    categoryId = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Category Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Image URL'),
                  onChanged: (value) {
                    imageUrl = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                addCategory(categoryId, name, description, imageUrl);
                Navigator.of(context).pop(); // Close the dialog after adding
              },
            ),
          ],
        );
      },
    );
  }
}
