import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _selectedIndex == 0 ? ProductSection() : CategorySection(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class ProductSection extends StatefulWidget {
  @override
  _ProductSectionState createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  List products = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse(APIConfig.getProduct));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse(APIConfig.getProduct),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(product),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully.')),
      );
      fetchProducts(); // Refresh the product list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product.')),
      );
      throw Exception('Failed to add product');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse(APIConfig.getProduct + id),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(product),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully.')),
      );
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product.')),
      );
      throw Exception('Failed to update product');
    }
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final TextEditingController nameController =
        TextEditingController(text: product?['name']);
    final TextEditingController productIdController =
        TextEditingController(text: product?['productId']);
    final TextEditingController descriptionController =
        TextEditingController(text: product?['description']);
    final TextEditingController priceController =
        TextEditingController(text: product?['price']?.toString());
    final TextEditingController mrpController =
        TextEditingController(text: product?['mrp']?.toString());
    final TextEditingController stockController =
        TextEditingController(text: product?['stock']?.toString());
    final TextEditingController categoryIdController =
        TextEditingController(text: product?['categoryId']);
    final TextEditingController imageUrlController =
        TextEditingController(text: product?['imageUrl']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Product Name'),
                _buildTextField(productIdController, 'Product Id'),
                _buildTextField(descriptionController, 'Description'),
                _buildTextField(priceController, 'Price', isNumber: true),
                _buildTextField(mrpController, 'MRP', isNumber: true),
                _buildTextField(stockController, 'Stock', isNumber: true),
                _buildTextField(categoryIdController, 'Category Id',
                    isNumber: true),
                _buildTextField(imageUrlController, 'Image URL'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> productData = {
                  'name': nameController.text,
                  'productId': productIdController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'mrp': double.tryParse(mrpController.text) ?? 0.0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'categoryId': categoryIdController.text,
                  'imageUrl': imageUrlController.text,
                };

                if (product == null) {
                  addProduct(productData);
                } else {
                  updateProduct(product['_id'], productData);
                }
                Navigator.of(context).pop();
              },
              child: Text(product == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Products',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      if (product['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                        return _buildProductItem(product);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showProductDialog(),
                child: Text('Add Product'),
              ),
            ],
          );
  }

  Widget _buildProductItem(product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              product['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(product['name'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Stock: ${product['stock']}, Price: ₹${product['price']}'),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showProductDialog(product: product);
          },
        ),
      ),
    );
  }
}

class CategorySection extends StatefulWidget {
  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  List categories = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse(APIConfig.getAllCategories));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> category) async {
    final response = await http.put(
      Uri.parse(APIConfig.getAllCategories + id),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(category),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully.')),
      );
      fetchCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update category.')),
      );
      throw Exception('Failed to update category');
    }
  }

  Future<void> addCategory(Map<String, dynamic> category) async {
    final response = await http.post(
      Uri.parse(APIConfig.getAllCategories),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(category),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully.')),
      );
      fetchCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Category. Please try again.')),
      );
      throw Exception('Failed to add category');
    }
  }

  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final TextEditingController categoryIdController =
        TextEditingController(text: category?['categoryId']);
    final TextEditingController nameController =
        TextEditingController(text: category?['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: category?['description']);
    final TextEditingController imageUrlController =
        TextEditingController(text: category?['imageUrl']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(categoryIdController, 'Category Id'),
                _buildTextField(nameController, 'Category Name'),
                _buildTextField(descriptionController, 'Description'),
                _buildTextField(imageUrlController, 'Image URL'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> categoryData = {
                  'categoryId': categoryIdController.text,
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'imageUrl': imageUrlController.text,
                };

                if (category == null) {
                  // Add new category
                  addCategory(categoryData);
                } else {
                  updateCategory(category['_id'], categoryData);
                }
                Navigator.of(context).pop();
              },
              child: Text(category == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Categories',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchCategories,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      if (category['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                        return _buildCategoryItem(category);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showCategoryDialog(),
                child: Text('Add Category'),
              ),
            ],
          );
  }

  Widget _buildCategoryItem(category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              category['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(category['name'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showCategoryDialog(category: category);
          },
        ),
      ),
    );
  }
}
