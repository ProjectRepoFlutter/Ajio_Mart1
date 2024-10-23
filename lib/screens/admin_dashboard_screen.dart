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

  // List of screens for each section (Product, Category, Slider)
  final List<Widget> _sections = [
    ProductSection(), // Existing product section
    CategorySection(), // Existing category section
    SliderSection(), // New slider section
    OrderAssigningSection()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _sections[
          _selectedIndex], // Display current section based on selected index
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
          BottomNavigationBarItem(
            icon: Icon(Icons.slideshow),
            label: 'Sliders', // New tab for Slider Section
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Order Assign', // New tab for Order Assignment
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor:
            Colors.grey, // Optional: Color for unselected items
        onTap: (index) {
          setState(() {
            _selectedIndex =
                index; // Update selected index when a tab is clicked
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

class SliderSection extends StatefulWidget {
  @override
  _SliderSectionState createState() => _SliderSectionState();
}

class _SliderSectionState extends State<SliderSection> {
  List sliders = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSliders();
  }

  Future<void> fetchSliders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('https://ajiomart.onrender.com/sliders'));
      if (response.statusCode == 200) {
        setState(() {
          sliders = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sliders');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addSlider(Map<String, dynamic> sliderData) async {
    final response = await http.post(
      Uri.parse('https://ajiomart.onrender.com/sliders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sliderData),
    );
    if (response.statusCode == 201) {
      fetchSliders();
    } else {
      throw Exception('Failed to add slider');
    }
  }

  Future<void> updateSlider(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('https://ajiomart.onrender.com/sliders/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      fetchSliders();
    } else {
      throw Exception('Failed to update slider');
    }
  }

  Future<void> deleteSlider(String id) async {
    final response = await http
        .delete(Uri.parse('https://ajiomart.onrender.com/sliders/$id'));
    if (response.statusCode == 200) {
      fetchSliders();
    } else {
      throw Exception('Failed to delete slider');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddSliderDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSliders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search sliders...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: sliders.length,
                      itemBuilder: (context, index) {
                        final slider = sliders[index];
                        if (slider['title']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase())) {
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(slider['title']),
                              subtitle: Text(
                                  'Number of Products: ${slider['numberOfProducts']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showUpdateSliderDialog(context, slider);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteConfirmation(
                                          context, slider['_id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Slider Dialog
  Future<void> _showAddSliderDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController productsController = TextEditingController();
    final TextEditingController productsNumberController =
        TextEditingController();
    bool showViewAll = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Slider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: productsController,
                decoration:
                    InputDecoration(labelText: 'Products (comma-separated)'),
              ),
              TextField(
                controller: productsNumberController,
                decoration: InputDecoration(labelText: 'Number of Products'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: showViewAll,
                    onChanged: (bool? value) {
                      setState(() {
                        showViewAll = value ?? true;
                      });
                    },
                  ),
                  Text('Show View All'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSlider = {
                'title': titleController.text,
                'products': productsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                'numberOfProducts': int.parse(productsNumberController.text),
                'showViewAll': showViewAll,
              };
              addSlider(newSlider);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Update Slider Dialog
  Future<void> _showUpdateSliderDialog(
      BuildContext context, dynamic slider) async {
    final TextEditingController titleController =
        TextEditingController(text: slider['title']);
    final TextEditingController productsController =
        TextEditingController(text: slider['products'].join(', '));
    final TextEditingController productsNumberController =
        TextEditingController(text: slider['numberOfProducts'].toString());
    bool showViewAll = slider['showViewAll'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Slider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: productsController,
                decoration:
                    InputDecoration(labelText: 'Products (comma-separated)'),
              ),
              TextField(
                controller: productsNumberController,
                decoration: InputDecoration(labelText: 'Number of Products'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: showViewAll,
                    onChanged: (bool? value) {
                      setState(() {
                        showViewAll = value ?? true;
                      });
                    },
                  ),
                  Text('Show View All'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSlider = {
                'title': titleController.text,
                'products': productsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                'numberOfProducts': int.parse(productsNumberController.text),
                'showViewAll': showViewAll,
              };
              updateSlider(slider['_id'], updatedSlider);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Confirm delete dialog
  Future<void> _deleteConfirmation(
      BuildContext context, String sliderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Slider'),
        content: Text('Are you sure you want to delete this slider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteSlider(sliderId);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class OrderAssigningSection extends StatefulWidget {
  @override
  _OrderAssigningSectionState createState() => _OrderAssigningSectionState();
}

class _OrderAssigningSectionState extends State<OrderAssigningSection> {
  List<dynamic> orders = [];
  List<dynamic> deliveryBoys = [];
  Map<String, String?> selectedDeliveryBoys = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchDeliveryBoys();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://192.168.31.23:5000/orders/allOrder'));
    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        // Only fetch orders with "Pending" status
        orders = data['orders']
            .where((order) => order['orderStatus'] == 'Pending')
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchDeliveryBoys() async {
    final response = await http
        .get(Uri.parse('http://192.168.31.23:5000/users/deliveryBoys'));
    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        deliveryBoys = data['deliveryBoys'];
      });
    } else {
      throw Exception('Failed to load delivery boys');
    }
  }

  Future<void> assignOrder(String orderId, String deliveryBoyId) async {
    final response = await http.put(
      Uri.parse('http://192.168.31.23:5000/orders/assignOrder/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'deliveryBoyId': deliveryBoyId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order assigned successfully'),
      ));
      // Refresh the orders after assignment
      fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to assign order'),
      ));
    }
  }

  Future<void> _refresh() async {
    await fetchOrders();
    await fetchDeliveryBoys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Pending Orders'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  if (!selectedDeliveryBoys.containsKey(order['_id'])) {
                    selectedDeliveryBoys[order['_id']] =
                        null; // Initialize with null
                  }
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Order ID: ${order['_id']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Chip(
                                label: Text(order['orderStatus']),
                                backgroundColor:
                                    order['orderStatus'] == 'Pending'
                                        ? Colors.orangeAccent
                                        : Colors.greenAccent,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Customer: ${order['user']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Total Price: ₹${order['totalPrice']}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Delivery Address:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(order['deliveryAddress']),
                          SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            hint: Text('Select Delivery Boy'),
                            value: selectedDeliveryBoys[order['_id']],
                            onChanged: (value) {
                              setState(() {
                                selectedDeliveryBoys[order['_id']] = value;
                              });
                            },
                            items: deliveryBoys.map((deliveryBoy) {
                              return DropdownMenuItem<String>(
                                value: deliveryBoy['_id'],
                                child: Text(
                                  '${deliveryBoy['firstName']} ${deliveryBoy['lastName']}',
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: selectedDeliveryBoys[order['_id']] ==
                                    null
                                ? null
                                : () {
                                    assignOrder(order['_id'],
                                        selectedDeliveryBoys[order['_id']]!);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal, // Background color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text('Assign Order',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
