import 'package:flutter/material.dart';
import 'package:unieaat/services/database_service.dart';

class DatabaseDataScreen extends StatefulWidget {
  const DatabaseDataScreen({super.key});

  @override
  _DatabaseDataScreenState createState() => _DatabaseDataScreenState();
}

class _DatabaseDataScreenState extends State<DatabaseDataScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchDatabaseData();
  }

  Future<void> fetchDatabaseData() async {
    users = await DatabaseHelper.instance.getFoodItems();
    orders = await DatabaseHelper.instance.getOrders();
    foodItems = await DatabaseHelper.instance.getFoodItems();
    favorites = await DatabaseHelper.instance.getFavoriteItems(1); // Assuming user ID 1

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Database Data")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSection("Users", users),
              buildSection("Orders", orders),
              buildSection("Food Items", foodItems),
              buildSection("Favorites", favorites),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        data.isEmpty
            ? const Text("No data available")
            : Column(
          children: data.map((item) => buildItem(item)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: item.entries.map((entry) {
            return Text("${entry.key}: ${entry.value}", style: const TextStyle(fontSize: 14));
          }).toList(),
        ),
      ),
    );
  }
}
