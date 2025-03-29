import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unieaat/services/database_service.dart';
import 'OrderStatusPage.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';
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
  String selectedCategory = "";
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  TextEditingController _addressController =
  TextEditingController();
  bool isPhoneValid = true;

  List<Map<String, dynamic>> favoriteItems = [];
  List<Map<String, dynamic>> filteredFoodItems = [];
  @override
  void initState() {
    super.initState();
    printFavoritesTableSchema();
    _initializeData();
    _phoneController.addListener(() {
      setState(() {
        isPhoneValid = _phoneController.text.length >= 11;
      });
    });// Call async function without awaiting
  }

  void _initializeData() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> columns = await db.rawQuery("PRAGMA table_info(food_items);");
    print(columns);
    await _loadFoodItems();
    await _loadUserData();
    await _loadFavoriteItems();
    setState(() {
      filteredFoodItems = List.from(foodItems);
    });
  }



  void addInitialFoodData() async {
    final dbHelper = DatabaseHelper.instance;

    await dbHelper.deleteAllFoodItems(); // ✅ No more error!

    await dbHelper.insertFoodItems(burgerList);
    await dbHelper.insertFoodItems(pizzaList);
    await dbHelper.insertFoodItems(noodlesList);
    await dbHelper.insertFoodItems(meatList);
    await dbHelper.insertFoodItems(vegetableList);
    await dbHelper.insertFoodItems(dessertList);

    print("Food items inserted successfully!");
  }
  List<Map<String, dynamic>> burgerList = [
    {
      "id": 5,
      "name": "Burger Bistro",
      "restaurant": "Rose Garden",
      "price": 40,
      "image": "assets/burger_bistro.png",
    },
    {
      "id": 6,
      "name": "Smokin' Burger",
      "restaurant": "Cafenio Restaurant",
      "price": 60,
      "image": "assets/smokin_burger.png",
    },
    {
      "id": 7,
      "name": "Buffalo Burgers",
      "restaurant": "Kaji Firm Kitchen",
      "price": 75,
      "image": "assets/buffalo_burger.png",
    },
    {
      "id": 8,
      "name": "Bullseye Burgers",
      "restaurant": "Kabab Restaurant",
      "price": 94,
      "image": "assets/bullseye_burger.png",
    },
  ];
  List<Map<String, dynamic>> pizzaList = [
    {
      "id": 9,
      "name": "Cheese Lovers",
      "restaurant": "Pizza Hut",
      "price": 30,
      "image": "assets/cheese_lovers.png",
    },
    {
      "id": 10,
      "name": "Pepperoni Feast",
      "restaurant": "Dominos",
      "price": 45,
      "image": "assets/pepperoni_pizza.png",
    },
    {
      "id": 11,
      "name": "BBQ Chicken Pizza",
      "restaurant": "Papa Johns",
      "price": 50,
      "image": "assets/bbq_chicken_pizza.png",
    },
    {
      "id": 12,
      "name": "Veggie Delight",
      "restaurant": "Local Pizzeria",
      "price": 35,
      "image": "assets/veggie_pizza.png",
    },
  ];
  List<Map<String, dynamic>> noodlesList = [
    {
      "id": 13,
      "name": "Spicy Chicken Noodles",
      "restaurant": "Asian Bites",
      "price": 50,
      "image": "assets/Noodles_1.png",
    },
    {
      "id": 14,
      "name": "Garlic Butter Noodles",
      "restaurant": "Noodle House",
      "price": 40,
      "image": "assets/Noodles_2.png",
    },
    {
      "id": 15,
      "name": "Schezwan Noodles",
      "restaurant": "Dragon Wok",
      "price": 55,
      "image": "assets/Noodles_3.png",
    },
    {
      "id": 16,
      "name": "Veggie Stir-Fry Noodles",
      "restaurant": "Green Kitchen",
      "price": 45,
      "image": "assets/Noodles_4.png",
    },
  ];
  List<Map<String, dynamic>> meatList = [
    {
      "id": 17,
      "name": "Grilled Steak",
      "restaurant": "Steak House",
      "price": 120,
      "image": "assets/meat_1.png",
    },
    {
      "id": 18,
      "name": "BBQ Ribs",
      "restaurant": "Smokehouse Grill",
      "price": 150,
      "image": "assets/meat_2.png",
    },
    {
      "id": 19,
      "name": "Lamb Chops",
      "restaurant": "Mediterranean Delight",
      "price": 180,
      "image": "assets/meat_3.png",
    },
    {
      "id": 20,
      "name": "Tandoori Chicken",
      "restaurant": "Spicy Corner",
      "price": 100,
      "image": "assets/meat_4.png",
    },
  ];
  List<Map<String, dynamic>> vegetableList = [
    {
      "id": 21,
      "name": "Fresh Salad",
      "restaurant": "Healthy Bites",
      "price": 30,
      "image": "assets/vegetable_1.png",
    },
    {
      "id": 22,
      "name": "Grilled Veggies",
      "restaurant": "Green Delight",
      "price": 40,
      "image": "assets/vegetable_2.png",
    },
    {
      "id": 23,
      "name": "Mixed Stir-Fry",
      "restaurant": "Veggie Heaven",
      "price": 35,
      "image": "assets/vegetable_3.png",
    },
    {
      "id": 24,
      "name": "Broccoli & Carrot Mix",
      "restaurant": "Organic Kitchen",
      "price": 45,
      "image": "assets/vegetable_4.png",
    },
  ];
  List<Map<String, dynamic>> dessertList = [
    {
      "id": 1,  // ✅ Unique ID
      "name": "Chocolate Cake",
      "restaurant": "Sweet Treats",
      "price": 50,
      "image": "assets/dessert_1.png",
    },
    {
      "id": 2,
      "name": "Ice Cream Sundae",
      "restaurant": "Frosty Delights",
      "price": 40,
      "image": "assets/dessert_2.png",
    },
    {
      "id": 3,
      "name": "Strawberry Cheesecake",
      "restaurant": "Cheese Heaven",
      "price": 55,
      "image": "assets/dessert_3.png",
    },
    {
      "id": 4,
      "name": "Brownie with Ice Cream",
      "restaurant": "Chocolate House",
      "price": 45,
      "image": "assets/dessert_4.png",
    },
  ];

  Future<void> _loadFoodItems() async {
    final item = await DatabaseHelper.instance.getFoodItems();
    print("Loaded Food Items: $item");

    setState(() {
      foodItems = item;
    });
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
  List<Map<String, dynamic>> getAllFoodItems() {
    return [
      ...burgerList,
      ...pizzaList,
      ...noodlesList,
      ...meatList,
      ...vegetableList,
      ...dessertList,
    ];
  }

  List<Map<String, dynamic>> food = [
    {"id": 1, "name": "Burger"},
    {"id": 2, "name": "Pizza"},
    {"id": 3, "name": "Pasta"},
  ];
  void _filterFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFoodItems = getAllFoodItems(); // Show all food items if search is empty
      } else {
        filteredFoodItems = getAllFoodItems().where((item) {
          return item['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
    setState(() {
      filteredFoodItems = List.from(filteredFoodItems);
    });

    print("Filtered Food Items: $filteredFoodItems");

  }



  Widget _buildFoodGrid() {
    List<Map<String, dynamic>> displayList;

    if (searchController.text.isNotEmpty) {
      displayList = filteredFoodItems;
    }
    else if (selectedCategory == "Hamburger") {
      displayList = burgerList;
    } else if (selectedCategory == "Pizza") {
      displayList = pizzaList;
    } else if (selectedCategory == "Noodles") {
      displayList = noodlesList;
    } else if (selectedCategory == "Meat") {
      displayList = meatList;
    } else if (selectedCategory == "Vegetables") {
      displayList = vegetableList;
    } else if (selectedCategory == "Dessert") {
      displayList = dessertList;
    }
    else {
      displayList = getAllFoodItems();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterFoods,
                    decoration: InputDecoration(
                      hintText: "Search food...",
                      prefixIcon: const Icon(Icons.search,color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                _buildFoodSlider(),
                _buildFoodItem((selected) {
                  setState(() {
                    selectedCategory = selected;
                  });
                }),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: displayList.length, // 🔹 Always use filtered list
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    bool isFavorite = favoriteItems.any(
                          (fav) => fav['name'] == item['name'],
                    );
                    return _buildFoodCard(item, isFavorite);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodSlider() {
    final List<Widget> banners = [
      _buildBanner(
        "Food delivery",
        "Order food you love",
        "assets/banner1.json",
        Colors.pink,
      ),
      _buildBanner(
        "Pick-Up",
        "Everyday up to \n 25% off",
        "assets/burger.json",
        Colors.brown,
      ),
      _buildBanner(
        "Shops",
        "Grocery & more..",
        "assets/food.json",
        Color(0xFF85C0FC),
      ),
      _buildBanner(
        "The Best",
        "Options of the day \n in your university",
        "assets/okkkkkk.json",
        Color(0xFF044783),
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
  )
  {
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
            borderRadius: BorderRadius.circular(100),
            child: Lottie.asset(
              imagePath, // Image path passed dynamically
              width: 100,
              height: 100,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(void Function(String) onCategorySelected) {
    final List<Map<String, String>> categories = [
      {"icon": "🍔", "label": "Hamburger"},
      {"icon": "🍕", "label": "Pizza"},
      {"icon": "🍜", "label": "Noodles"},
      {"icon": "🍖", "label": "Meat"},
      {"icon": "🥬", "label": "Vegetables"},
      {"icon": "🍰", "label": "Dessert"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap:
              () => onCategorySelected(
                category["label"]!,
              ), // Call function when tapped
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category["icon"]!, style: TextStyle(fontSize: 40)),
              SizedBox(height: 5),
              Text(
                category["label"]!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadFavoriteItems() async {
    int userId = 1; // Replace with actual logged-in user ID
    final items = await DatabaseHelper.instance.getFavoriteItems(userId);

    print("DEBUG: Loaded Favorite Items => $items"); // ✅ Debug log

    setState(() => favoriteItems = items);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> item) async {
      print("DEBUG: Item Data => $item");

      if (!item.containsKey('id')) {
        item['id'] = DateTime.now().millisecondsSinceEpoch; // ✅ Assign unique ID if missing
      }

      int foodId = item['id'];
      int userId = 1; // Actual user ID add karo

      bool isFav = favoriteItems.any((fav) => fav['id'] == foodId);

      if (isFav) {
        await DatabaseHelper.instance.removeFromFavorites(item['food_id'], userId!);
        print("✅ Removed from favorites");
      } else {
        await DatabaseHelper.instance.addToFavorites(
            userId,
            foodId,
            item['name'],
            item['image'],
            item['price']
        );
        print("❤️ Added to favorites");
      }

      _loadFavoriteItems();
    }


  Widget _buildFavoritesPage() {
    return favoriteItems.isEmpty
        ? const Center(
      child: Text("No favorites added yet", style: TextStyle(fontSize: 18)),
    )
        : GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: favoriteItems.length, // ✅ Use favoriteItems
      itemBuilder: (context, index) {
        final item = favoriteItems[index]; // ✅ Use favoriteItems
        return
          SizedBox(
            width: double.infinity, // Makes Card take full available width
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              child: Container(
                height: 900, // Fixed height
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Stack to position delete & cart buttons
                    Stack(
                      children: [
                        // Circular Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            item['image'],
                            width: double.infinity,
                            height: 120, // Increased size
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Add to Cart Button (Top Right)
                        Positioned(
                          top: 8,
                          right: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _addToCart(item),
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              iconSize: 24,
                            ),
                          ),
                        ),

                        // Delete Button (Top Left)
                        Positioned(
                          top: 8,
                          left: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _toggleFavorite(item),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 10, // Larger text
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "PKR${item['price']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );







      },
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> item, bool isFavorite) {
      print("Image URL: ${item['image']}");
      print("Checking Image Path: ${item['image']}");
      print("File Exists: ${File(item['image']).existsSync()}");
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Container(
          height: 600, // Fixed height to prevent overflow
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      child:
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item['image'] != null && item['image'].startsWith('assets/')
                            ? Image.asset(
                          item['image'], // Directly use Image.asset for assets folder
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(item['image']), // Only use File() for local storage paths
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                    ),
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
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  Future<void> printFavoritesTableSchema() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery("PRAGMA table_info(favorites)");

    for (var column in result) {
      print("Column: ${column['name']} | Type: ${column['type']}");
    }
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

  Future<int> placeOrder(
      int userId,
      int foodItemId,
      int quantity,
      double totalPrice,
      String address,
      String paymentMethod,
      String foodName,
      String phoneNumber,
      String landmark,
      String timestamp) async {

    final db = await DatabaseHelper.instance.database; // Ensure the database is fetched correctly

    return await db.insert(
      'orders',
      {
        'userId': userId,
        'foodItemId': foodItemId,
        'foodName': foodName,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'address': address,
        'phoneNumber': phoneNumber,
        'landmark': landmark,
        'status': 'Processing',
        'paymentMethod': paymentMethod,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future<void> showPaymentBottomSheet(BuildContext context) async {
    double totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + item['price'],
    ); // Calculate total price

    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Card information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  labelText: "Card number",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: "MM / YY",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: "CVC",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Country or region",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(child: Text("Pakistan"), value: "PK"),
                  DropdownMenuItem(child: Text("United States"), value: "US"),
                  DropdownMenuItem(child: Text("Canada"), value: "CA"),
                  DropdownMenuItem(child: Text("United Kingdom"), value: "GB"),
                  DropdownMenuItem(child: Text("Australia"), value: "AU"),
                  DropdownMenuItem(child: Text("Germany"), value: "DE"),
                  DropdownMenuItem(child: Text("France"), value: "FR"),
                  DropdownMenuItem(child: Text("Italy"), value: "IT"),
                  DropdownMenuItem(child: Text("Spain"), value: "ES"),
                  DropdownMenuItem(child: Text("Netherlands"), value: "NL"),
                  DropdownMenuItem(child: Text("Switzerland"), value: "CH"),
                  DropdownMenuItem(child: Text("Sweden"), value: "SE"),
                  DropdownMenuItem(child: Text("Norway"), value: "NO"),
                  DropdownMenuItem(child: Text("Denmark"), value: "DK"),
                  DropdownMenuItem(child: Text("Finland"), value: "FI"),
                  DropdownMenuItem(child: Text("Japan"), value: "JP"),
                  DropdownMenuItem(child: Text("South Korea"), value: "KR"),
                  DropdownMenuItem(child: Text("China"), value: "CN"),
                  DropdownMenuItem(child: Text("India"), value: "IN"),
                  DropdownMenuItem(child: Text("Brazil"), value: "BR"),
                  DropdownMenuItem(child: Text("Mexico"), value: "MX"),
                  DropdownMenuItem(child: Text("Argentina"), value: "AR"),
                  DropdownMenuItem(child: Text("Colombia"), value: "CO"),
                  DropdownMenuItem(child: Text("Chile"), value: "CL"),
                  DropdownMenuItem(child: Text("Peru"), value: "PE"),
                  DropdownMenuItem(child: Text("South Africa"), value: "ZA"),
                  DropdownMenuItem(child: Text("Nigeria"), value: "NG"),
                  DropdownMenuItem(child: Text("Egypt"), value: "EG"),
                  DropdownMenuItem(child: Text("Turkey"), value: "TR"),
                  DropdownMenuItem(child: Text("Saudi Arabia"), value: "SA"),
                  DropdownMenuItem(child: Text("United Arab Emirates"), value: "AE"),
                  DropdownMenuItem(child: Text("Malaysia"), value: "MY"),
                  DropdownMenuItem(child: Text("Singapore"), value: "SG"),
                  DropdownMenuItem(child: Text("Thailand"), value: "TH"),
                  DropdownMenuItem(child: Text("Vietnam"), value: "VN"),
                  DropdownMenuItem(child: Text("Indonesia"), value: "ID"),
                  DropdownMenuItem(child: Text("Philippines"), value: "PH"),
                  DropdownMenuItem(child: Text("New Zealand"), value: "NZ"),
                  DropdownMenuItem(child: Text("Russia"), value: "RU"),
                  DropdownMenuItem(child: Text("Ukraine"), value: "UA"),
                  DropdownMenuItem(child: Text("Poland"), value: "PL"),
                  DropdownMenuItem(child: Text("Czech Republic"), value: "CZ"),
                  DropdownMenuItem(child: Text("Hungary"), value: "HU"),
                  DropdownMenuItem(child: Text("Greece"), value: "GR"),
                  DropdownMenuItem(child: Text("Portugal"), value: "PT"),
                  DropdownMenuItem(child: Text("Belgium"), value: "BE"),
                  DropdownMenuItem(child: Text("Austria"), value: "AT"),
                  DropdownMenuItem(child: Text("Romania"), value: "RO"),
                  DropdownMenuItem(child: Text("Bulgaria"), value: "BG"),
                  DropdownMenuItem(child: Text("Serbia"), value: "RS"),
                  DropdownMenuItem(child: Text("Croatia"), value: "HR"),
                  DropdownMenuItem(child: Text("Slovakia"), value: "SK"),
                  DropdownMenuItem(child: Text("Slovenia"), value: "SI"),
                  DropdownMenuItem(child: Text("Lithuania"), value: "LT"),
                  DropdownMenuItem(child: Text("Latvia"), value: "LV"),
                  DropdownMenuItem(child: Text("Estonia"), value: "EE"),
                  DropdownMenuItem(child: Text("Kazakhstan"), value: "KZ"),
                  DropdownMenuItem(child: Text("Uzbekistan"), value: "UZ"),
                  DropdownMenuItem(child: Text("Qatar"), value: "QA"),
                  DropdownMenuItem(child: Text("Bahrain"), value: "BH"),
                  DropdownMenuItem(child: Text("Kuwait"), value: "KW"),
                  DropdownMenuItem(child: Text("Oman"), value: "OM"),
                  DropdownMenuItem(child: Text("Lebanon"), value: "LB"),
                  DropdownMenuItem(child: Text("Jordan"), value: "JO"),
                  DropdownMenuItem(child: Text("Israel"), value: "IL"),
                  DropdownMenuItem(child: Text("Morocco"), value: "MA"),
                  DropdownMenuItem(child: Text("Algeria"), value: "DZ"),
                  DropdownMenuItem(child: Text("Tunisia"), value: "TN"),
                  DropdownMenuItem(child: Text("Ethiopia"), value: "ET"),
                  DropdownMenuItem(child: Text("Kenya"), value: "KE"),
                  DropdownMenuItem(child: Text("Ghana"), value: "GH"),
                  DropdownMenuItem(child: Text("Ivory Coast"), value: "CI"),
                  DropdownMenuItem(child: Text("Senegal"), value: "SN"),
                  DropdownMenuItem(child: Text("Bangladesh"), value: "BD"),
                  DropdownMenuItem(child: Text("Sri Lanka"), value: "LK"),
                  DropdownMenuItem(child: Text("Myanmar"), value: "MM"),
                  DropdownMenuItem(child: Text("Nepal"), value: "NP"),
                  DropdownMenuItem(child: Text("Bhutan"), value: "BT"),
                  DropdownMenuItem(child: Text("Mongolia"), value: "MN"),
                  DropdownMenuItem(child: Text("Afghanistan"), value: "AF"),
                  DropdownMenuItem(child: Text("Iran"), value: "IR"),
                  DropdownMenuItem(child: Text("Iraq"), value: "IQ"),
                  DropdownMenuItem(child: Text("Syria"), value: "SY"),
                  DropdownMenuItem(child: Text("Yemen"), value: "YE"),
                  DropdownMenuItem(child: Text("Sudan"), value: "SD"),
                  DropdownMenuItem(child: Text("Somalia"), value: "SO"),
                  DropdownMenuItem(child: Text("Zambia"), value: "ZM"),
                  DropdownMenuItem(child: Text("Uganda"), value: "UG"),
                  DropdownMenuItem(child: Text("Madagascar"), value: "MG"),
                  DropdownMenuItem(child: Text("Mozambique"), value: "MZ"),
                  DropdownMenuItem(child: Text("Zimbabwe"), value: "ZW"),
                  DropdownMenuItem(child: Text("Paraguay"), value: "PY"),
                  DropdownMenuItem(child: Text("Bolivia"), value: "BO"),
                  DropdownMenuItem(child: Text("Venezuela"), value: "VE"),
                  DropdownMenuItem(child: Text("Uruguay"), value: "UY"),
                  DropdownMenuItem(child: Text("Ecuador"), value: "EC"),
                  DropdownMenuItem(child: Text("Honduras"), value: "HN"),
                  DropdownMenuItem(child: Text("Guatemala"), value: "GT"),
                  DropdownMenuItem(child: Text("Panama"), value: "PA"),
                  DropdownMenuItem(child: Text("Costa Rica"), value: "CR"),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: "ZIP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (value) {}),
                  const Text("Save this card for future payments"),
                ],
              ),
              // const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close modal on payment
                  },
                  icon: const Icon(Icons.lock),
                  label: Text(
                    "Pay PKR ${totalPrice.toStringAsFixed(2)}",
                  ), // Dynamic price
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet() {

    Future<void> _getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          String fullAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
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
                      borderSide: BorderSide(
                        color: isPhoneValid ? Colors.grey : Colors.red, // Red border if invalid
                      ),
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

                      String? paymentMethod = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Choose Payment Method"),
                            content: const Text("How would you like to pay?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, "Cash"),
                                child: const Text("Cash on Delivery"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, "Online"),
                                child: const Text("Online Payment"),
                              ),
                            ],
                          );
                        },
                      );

                      if (paymentMethod != null) {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                        // debugPrint("Saving Order with: Address: $address, Phone: $phoneNumber, Landmark: $landmark");
                        String formattedDate = DateFormat('dd-M-yy h:mm a').format(DateTime.now());
                        int userId = 1;
                        String address = _addressController.text;
                        String phoneNumber = _phoneController.text.trim().isNotEmpty
                            ? _phoneController.text.trim()
                            : "N/A";

                        String landmark = _landmarkController.text.trim().isNotEmpty
                            ? _landmarkController.text.trim()
                            : "N/A";
                        if (paymentMethod == "Online") {
                          await showPaymentBottomSheet(context);
                        }
                        debugPrint("🚀 Saving Order Details:");
                        debugPrint("User ID: $userId");
                        debugPrint("Address: $address");
                        debugPrint("Phone Number: $phoneNumber");
                        debugPrint("Landmark: $landmark");
                        debugPrint("Payment Method: $paymentMethod");
                        debugPrint("Cart Items Count: ${cartItems.length}");
                        for (var item in cartItems) {
                          int foodItemId = item['id'] ?? 0;
                          String foodName = item['name'];
                          double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                          int quantity = 1;
                          await DatabaseHelper.instance.placeOrder(
                            userId,
                            foodItemId,
                            quantity,
                            price,
                            address,
                            paymentMethod,
                            foodName,
                            phoneNumber,
                            landmark,
                              formattedDate,
                          );

                        }

                        debugPrint(
                            paymentMethod == "Cash"
                                ? "Cash on Delivery order confirmed!"
                                : "Online payment order confirmed!"
                        );

                        if (mounted) {
                          setState(() => cartItems.clear());
                        }
                      }
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

  Widget _buildCartPage() {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: Column(
        children: [
          Expanded(
            child:
                cartItems.isEmpty
                    ? const Center(
                      child: Text(
                        "Cart is empty",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
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
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Rounded image
                              child: Image.network(
                                item['image'], // Fetch image from the item
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover, // Ensure the image fits well
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.fastfood,
                                    size: 40,
                                    color: Colors.brown,
                                  );
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
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
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
            padding: const EdgeInsets.symmetric(
              vertical: 30,
            ), // Move button upwards
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : _showAddressBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 50,
                ),
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
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.blue,
                  ), // Adjusted size
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
      title: Text(
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

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    TextEditingController controller = TextEditingController(
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
    _buildFoodGrid(), // 0 - Home
    _buildFavoritesPage(),
    _buildCartPage(),
    profilepage(),
    // 3 - Favorites
    OrderStatusPage(),
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
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.favorite, 1),
              // Home
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.person, 3), // Profile
              _buildNavItem(Icons.receipt_long, 4), // Orders
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
