import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
  Map<String, dynamic>? userData;

  String userName = "Guest";
  String userEmail = "Guest";
  String useradress = "Guest";
  String userPhone = "Guest";
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> userOrders = [];

  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<Map<String, dynamic>> favoriteItems = [];
  List<Map<String, dynamic>> filteredFoodItems = []; // Filtered list
  @override
  void initState() {
    super.initState();
    initIAP();
    _loadFoodItems();
    _loadUserData();
    _loadFavoriteItems();
    filteredFoodItems = List.from(foodItems);
    FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      if (productItem!.transactionStateIOS == TransactionState.purchased) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF122342),
              title: const Text(
                'Restart App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'You need to restart the app to activate the Pro features.',
                style: TextStyle(color: Colors.white70),
              ),
              shape: RoundedRectangleBorder(
                // ignore: prefer_const_constructors
                side: BorderSide(
                  color: const Color(0xFF00FFFF), // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00FFFF),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: TextButton(
                          onPressed: () async {
                            SystemChannels.platform.invokeMethod(
                              'SystemNavigator.pop',
                            );
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            'Restart Now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
    FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('Purchase Error: $purchaseError');
    });
  }

  Future<void> _loadFoodItems() async {
    final items = await DatabaseHelper.instance.getFoodItems();
    print("Loaded Food Items: $items");
    setState(() {
      foodItems = items;
    });
  }

  Future<void> initIAP() async {
    try {
      final status = await FlutterInappPurchase.instance.initialize();
      print('IAP initialized successfully.');

      List<IAPItem> items = await FlutterInappPurchase.instance.getProducts([
        'android.test.purchased',
      ]);
      print("items");
      if (items.isNotEmpty &&
          items[0].price != null &&
          items[0].currency != null) {
        setState(() {});
      }
    } catch (error) {
      print('Error initializing IAP: $error');
    }
  }

  Future<void> initiatePurchase() async {
    try {
      await initIAP();

      List<String> productIds = ['android.test.purchased'];

      for (var productId in productIds) {
        List<IAPItem> items = await FlutterInappPurchase.instance.getProducts([
          productId,
        ]);
        print(items);

        print('Number of products for $productId: ${items.length}');
        for (var item in items) {
          print('Product ID: ${item.productId}');
          print('Title: ${item.title}');
          print('Description: ${item.description}');
          print('Price: ${item.price}');
        }

        if (items.isNotEmpty && items[0].productId != null) {
          await FlutterInappPurchase.instance.requestPurchase(
            items[0].productId!,
          );
        } else {
          print('Product ID is null or empty for $productId.');
        }
      }
    } catch (error) {
      print('Error purchasing: $error');
    }
  }

  Future<void> _loadUserData() async {
    int userId = 1; // Replace this with actual logged-in user ID
    final user = await DatabaseHelper.instance.getUserById(userId);

    print("Loaded user: $user"); // Debugging

    if (user != null) {
      setState(() {
        userName = user['name'] ?? "Guest";
        userEmail = user['email'] ?? "Guest";
        userPhone = user['phone'] ?? "Guest";
        useradress = user['address'] ?? "Guest";
      });
    } else {
      print("User not found in database!");
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

  List<Map<String, dynamic>> food = [
    {"id": 1, "name": "Burger"},
    {"id": 2, "name": "Pizza"},
    {"id": 3, "name": "Pasta"},
  ];

  void _filterFoods(String query) {
    setState(() {
      filteredFoodItems =
          foodItems
              .where(
                (item) =>
                    item['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Widget _buildFoodSlider() {
    final List<Widget> banners = [
      _buildBanner(
        "Food delivery",
        "Order food you love",
        "assets/burger.png",
        Colors.pink,
      ),
      _buildBanner(
        "Pick-Up",
        "Everyday up to 25% off",
        "assets/pasta.png",
        Colors.brown,
      ),
      _buildBanner(
        "Shops",
        "Grocery & more..",
        "assets/s.png",
        Color(0xFF85C0FC),
      ),
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
      ),
      items: banners,
    );
  }

  Widget _buildBanner(
    String title,
    String subtitle,
    String imagePath,
    Color bgColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor, // Background Color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              imagePath, // Image path passed dynamically
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Column(
      children: [
        _buildFoodSlider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            controller: searchController,
            onChanged: _filterFoods,
            decoration: InputDecoration(
              hintText: "Search food...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // 🔹 Food Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredFoodItems.length, // Use filtered list
            itemBuilder: (context, index) {
              final item = filteredFoodItems[index];
              bool isFavorite = favoriteItems.any(
                (fav) => fav['id'] == item['id'],
              );
              return _buildFoodCard(item, isFavorite);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> item, bool isFavorite) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Container(
        height: 220, // Fixed height to prevent overflow
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          // ✅ Makes Column Scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🟡 Image with Cart Icon
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        item['image'] != null &&
                                File(item['image']).existsSync()
                            ? Image.file(
                              File(item['image']),
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/burger.png',
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                  ),
                  // 🛒 Cart Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _addToCart(item),
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 🟡 Food Details
              Text(
                item['name'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Pkr ${item['price']}",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 8),

              // 🟡 Rating & Favorite Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        item['rating']?.toString() ?? "4.0",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesPage() {
    return favoriteItems.isEmpty
        ? const Center(
          child: Text("No favorites added yet", style: TextStyle(fontSize: 18)),
        )
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
            bool isFavorite = favoriteItems.any(
              (fav) => fav['id'] == item['id'],
            );
            return Card(
              color: Colors.amber.shade100,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Expanded(
                    child:
                        item['image'] != null &&
                                File(item['image']).existsSync()
                            ? Image.file(File(item['image']), fit: BoxFit.cover)
                            : const Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.brown,
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "PKR${item['price']}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _addToCart(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                          ),
                          child: const Text(
                            "+ Add to Cart",
                            style: TextStyle(color: Colors.black),
                          ),
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

  Future<void> placeOrder(
    int userId,
    int foodItemId,
    int quantity,
    double price,
    String address,
  ) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('orders', {
      'userId': userId,
      'foodItemId': foodItemId,
      'quantity': quantity,
      'totalPrice': price,
      'address': address, // Manually entered address
      'status': 'Processing',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  void _showAddressBottomSheet() {
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _landmarkController = TextEditingController();
    TextEditingController _addressController = TextEditingController(); // Address controller

    Future<void> _getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check and request permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          String fullAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";

          // Update text field
          _addressController.text = fullAddress;
        }
      } catch (e) {
        print("Error fetching address: $e");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.amber.shade50,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 400, // Increased height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Delivery Details",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Address Field with "Use Current Location" Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "Enter delivery address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.my_location, color: Colors.blue),
                      onPressed: _getCurrentLocation, // Fetch current location
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Phone Number Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter your phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Landmark Field
                TextField(
                  controller: _landmarkController,
                  decoration: InputDecoration(
                    hintText: "Enter nearby landmark",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (_addressController.text.isNotEmpty &&
                        _phoneController.text.isNotEmpty) {
                      Navigator.pop(context);
                      initiatePurchase();
                      int userId = 1;
                      String address = _addressController.text;
                      String phoneNumber = _phoneController.text;
                      String landmark = _landmarkController.text;

                      for (var item in cartItems) {
                        int foodItemId = item['id'];
                        String foodName = item['name'];
                        double price = item['price'];
                        int quantity = 1;

                        await DatabaseHelper.instance.placeOrder(
                          userId,
                          foodItemId,
                          quantity,
                          price,
                          address,
                          "Cash",
                          foodName,
                          phoneNumber,
                          landmark,
                        );
                      }

                      setState(() => cartItems.clear()); // Clear cart after order
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text(
                    "Confirm Address",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // void _showAddressBottomSheet() {
  //   TextEditingController _phoneController = TextEditingController();
  //   TextEditingController _landmarkController = TextEditingController();
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.amber.shade50,
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //         ),
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           height: 350, // Increased height for extra fields
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "Enter Delivery Details",
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //
  //               // Address Field
  //               TextField(
  //                 controller: _addressController,
  //                 decoration: InputDecoration(
  //                   hintText: "Enter delivery address",
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //
  //               // Phone Number Field
  //               TextField(
  //                 controller: _phoneController,
  //                 keyboardType: TextInputType.phone,
  //                 decoration: InputDecoration(
  //                   hintText: "Enter your phone number",
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //
  //               // Landmark Field
  //               TextField(
  //                 controller: _landmarkController,
  //                 decoration: InputDecoration(
  //                   hintText: "Enter nearby landmark",
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   if (_addressController.text.isNotEmpty &&
  //                       _phoneController.text.isNotEmpty) {
  //                     Navigator.pop(context);
  //                     initiatePurchase();
  //                     int userId = 1;
  //                     String address = _addressController.text;
  //                     String phoneNumber = _phoneController.text;
  //                     String landmark = _landmarkController.text;
  //
  //                     for (var item in cartItems) {
  //                       int foodItemId = item['id'];
  //                       String foodName = item['name'];
  //                       double price = item['price'];
  //                       int quantity = 1;
  //
  //                       await DatabaseHelper.instance.placeOrder(
  //                         userId,
  //                         foodItemId,
  //                         quantity,
  //                         price,
  //                         address,
  //                         "Cash",
  //                         foodName,
  //                         phoneNumber,
  //                         landmark,
  //                       );
  //                     }
  //
  //                     setState(
  //                       () => cartItems.clear(),
  //                     ); // Clear cart after order
  //                   }
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.amber.shade700,
  //                   padding: const EdgeInsets.symmetric(
  //                     vertical: 12,
  //                     horizontal: 20,
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Confirm Address",
  //                   style: TextStyle(color: Colors.black),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildCartPage() {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Text(
                "Cart is empty",
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  elevation: 3, // Soft shadow effect
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Rounded image
                      child: Image.network(
                        item['image'], // Fetch image from the item
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover, // Ensure the image fits well
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.fastfood, size: 40, color: Colors.brown);
                        },
                      ),
                    ),
                    title: Text(
                      item['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "PKR ${item['price']}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() => cartItems.removeAt(index));
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Move Order Button Upwards
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 30), // Move button upwards
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : _showAddressBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Order Now",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget profilepage() {
    return Scaffold(
      body: Column(
        children: [
          // 🟡 Top Profile Section with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // 🟡 Profile Picture
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, size: 24, color: Colors.blue), // Adjusted size
                ),

                const SizedBox(height: 10),
                // 🟡 Name & Email
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🟡 Profile Details
          _buildInfoTile(Icons.phone, userPhone, "Edit Phone", (newValue) {
            setState(() {
              userPhone = newValue;
            });
          }),

          _buildInfoTile(Icons.home, useradress, "Edit Address", (newValue) {
            setState(() {
              useradress = newValue;
            });
          }),

          // 🟡 Logout Button
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text("Logout"),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String value,
    String title,
    Function(String) onSave,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title:
   Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          _showEditDialog(title, value, onSave);
        },
      ),
    );
  }


  void _showEditDialog(String title, String currentValue, Function(String) onSave,
  ) {TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  List<Widget> get _pages => [
    _buildFoodGrid(),       // 0 - Home
    profilepage(),          // 1 - Profile
    _buildCartPage(),       // 2 - Cart (FAB)
    _buildFavoritesPage(),  // 3 - Favorites
    OrderStatusPage(),      // 4 - Orders
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Center(child: Text("UniEats 🍽️")),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: _pages[_selectedIndex],

      // 🛑 Bottom Navigation Bar with Floating Action Button
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.red,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),           // Home
              _buildNavItem(Icons.person, 1),        // Profile
              const SizedBox(width: 40),             // Space for FAB
              _buildNavItem(Icons.favorite, 3),      // Favorites
              _buildNavItem(Icons.receipt_long, 4),  // Orders
            ],
          ),
        ),
      ),

      // 🛑 Floating Action Button for Cart
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 2; // Open Cart Page
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.shopping_cart, color: Colors.white, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.white70,
        size: 30,
      ),
    );
  }

}
