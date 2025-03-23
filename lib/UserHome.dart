import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unieaat/services/database_service.dart';
import 'OrderStatusPage.dart';
import 'login_screen.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  String userName = "Guest";
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> userOrders = [];

  int _selectedIndex = 0;

  final TextEditingController _addressController = TextEditingController();
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    _loadUserData();
    _loadFavoriteItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await DatabaseHelper.instance.getFoodItems();
    print("Loaded Food Items: $items");
    setState(() {
      foodItems = items;
    });
  }
  Future<void> _loadUserData() async {
    int userId = 1; // Replace with actual user ID
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (user != null) {
      setState(() {
        userName = user['name'] ?? "Guest";
      });
    }
  }

  Future<void> _loadFavoriteItems() async {
    int userId = 1; // Replace with actual logged-in user ID
    final items = await DatabaseHelper.instance.getFavoriteItems(userId);
    setState(() => favoriteItems = items);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> item) async {
    int userId = 1; // Replace with actual user ID
    bool isFav = favoriteItems.any((fav) => fav['id'] == item['id']);

    if (isFav) {
      await DatabaseHelper.instance.removeFromFavorites(userId, item['id']);
    } else {
      await DatabaseHelper.instance.addToFavorites(userId, item['id']);
    }

    _loadFavoriteItems();
  }



  Widget _buildFoodGrid() {
    return foodItems.isEmpty
        ? const Center(child: Text("No food items available"))
        : GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final item = foodItems[index];
        bool isFavorite = favoriteItems.any((fav) => fav['id'] == item['id']);
        return Card(
          color: Colors.amber.shade100,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Expanded(
                child: item['image'] != null && File(item['image']).existsSync()
                    ? Image.file(File(item['image']), fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, size: 50, color: Colors.brown),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(item['name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${item['price']}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.green)),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                      child: const Text("+ Add to Cart", style: TextStyle(color: Colors.black)),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(item),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesPage() {
    return favoriteItems.isEmpty
        ? const Center(child: Text("No favorites added yet", style: TextStyle(fontSize: 18)))
        : foodItems.isEmpty
        ? const Center(child: Text("No food items available"))
        : GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final item = foodItems[index];
        bool isFavorite = favoriteItems.any((fav) => fav['id'] == item['id']);
        return Card(
          color: Colors.amber.shade100,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Expanded(
                child: item['image'] != null && File(item['image']).existsSync()
                    ? Image.file(File(item['image']), fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, size: 50, color: Colors.brown),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(item['name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${item['price']}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.green)),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                      child: const Text("+ Add to Cart", style: TextStyle(color: Colors.black)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _toggleFavorite(item),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );

  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item['name']} added to cart!"),
        backgroundColor: Colors.amber.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> placeOrder(int userId, int foodItemId, int quantity,
      double price, String address) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'orders',
      {
        'userId': userId,
        'foodItemId': foodItemId,
        'quantity': quantity,
        'totalPrice': price,
        'address': address, // Manually entered address
        'status': 'Processing',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.amber.shade50,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Your Address",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  autofillHints: null, // Disables autofill
                  decoration: InputDecoration(
                    hintText: "Enter delivery address",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_addressController.text.isNotEmpty) {
                      Navigator.pop(context);

                      int userId = 1;  // Replace with actual user ID
                      String address = _addressController.text; // User input address

                      for (var item in cartItems) {
                        int foodItemId = item['id'];
                        String foodName = item['name'];  // Get original name from cart
                        double price = item['price'];  // Get original price from cart
                        int quantity = 1;

                        await DatabaseHelper.instance.placeOrder(
                          userId,
                          foodItemId,
                          quantity,
                          price,
                          address,
                          "Cash",
                          foodName,
                        );



                      }

                      setState(() => cartItems.clear()); // Clear cart after order
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text("Confirm Address", style: TextStyle(color: Colors.black)),
                ),


              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildCartPage() {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: Column(
        children: [

          const Divider(),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                child: Text("Cart is empty", style: TextStyle(fontSize: 18)))
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name'], style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${item['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() => cartItems.removeAt(index));
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : _showAddressBottomSheet,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700),
              child: const Text(
                  "Place Order", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
  Widget profilepage() {
    return Scaffold(

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 80, color: Colors.black),
              const SizedBox(height: 10),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginScreen()));// Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> get _pages => [
    _buildFoodGrid(),
    _buildCartPage(),
    OrderStatusPage(),
    _buildFavoritesPage(),
    profilepage(),

  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Center(
          child: Text("UniEats 🍽️"),
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Removes the back button
      ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        color: Colors.yellow,
        buttonBackgroundColor: Colors.yellow.shade100,
        height: 60,
        items: <Widget>[

          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.add, size: 30, color: Colors.black),
          Icon(Icons.receipt_long, size: 30, color: Colors.black),
          Icon(Icons.favorite, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
        onTap: (index) {
          if (index < _pages.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },

      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.yellow.shade100,
      //   onPressed: () {},
      //   child: Icon(Icons.add, color: Colors.black),
      //   shape: CircleBorder(),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

