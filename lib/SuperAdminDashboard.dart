import 'package:flutter/material.dart';
import 'package:UEEats/services/database_service.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  List<Map<String, dynamic>> users = [];
  Map<int, List<Map<String, dynamic>>> userOrders = {};

  @override
  void initState() {
    super.initState();
    fetchUsersAndOrders();
  }

  Future<void> fetchUsersAndOrders() async {
    final db = DatabaseHelper.instance;

    final allUsers = await db.database.then((db) => db.query('users'));
    final orders = await db.database.then((db) => db.query('orders'));

    final Map<int, List<Map<String, dynamic>>> ordersMap = {};
    for (var order in orders) {
      int userId = order['userId'] as int;
      ordersMap[userId] = [...(ordersMap[userId] ?? []), order];
    }

    setState(() {
      users = allUsers;
      userOrders = ordersMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: Colors.orange.shade50,
      body: ListView.builder(
        itemCount: users.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final user = users[index];
          final orders = userOrders[user['id']] ?? [];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.person_outline, color: Colors.deepOrange),
              title: Text(
                '${user['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${user['email']} | Role: ${user['role']}'),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildDetailRow(Icons.email, "Email", user['email']),
                _buildDetailRow(Icons.lock_outline, "Password", user['password']),
                _buildDetailRow(Icons.phone, "Phone", user['phone']),
                _buildDetailRow(Icons.home, "Address", user['address']),
                const Divider(),
                if (orders.isNotEmpty)
                  ...orders.map((order) => _buildOrderCard(order)).toList()
                else
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No orders found."),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      color: Colors.orange.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.fastfood, color: Colors.deepOrange),
        title: Text('Order ID: ${order['id']} - ${order['foodName']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quantity: ${order['quantity']}"),
            Text("Total Price: \$${order['totalPrice']}"),
            Text("Status: ${order['status']}"),
            Text("Payment: ${order['paymentMethod']}"),
            Text("Date: ${order['timestamp']}"),
          ],
        ),
      ),
    );
  }
}
