  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';
  
  class DatabaseHelper {
    static final DatabaseHelper instance = DatabaseHelper._init();
    static Database? _database;
  
    DatabaseHelper._init();
  
    Future<Database> get database async {
      if (_database != null) return _database!;
      _database = await _initDB('unieats.db');
      return _database!;
    }
  
    Future<void> deleteAllFoodItems() async {
      final db = await DatabaseHelper.instance.database; // ✅ Correct way to get database instance
      await db.delete("food_items"); // ✅ Ensure "food_items" is your actual table name
    }
    Future<Database> _initDB(String filePath) async {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
  
      return await openDatabase(
        path,
        version: 3, // Increment version when modifying schema
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }



    Future<void> _createDB(Database db, int version) async {
      await db.execute('''
       CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT UNIQUE,
      password TEXT,
      phone TEXT,     -- ✅ Added phone field
      address TEXT,   -- ✅ Added address field
      role TEXT
  )
      ''');
      await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      foodItemId INTEGER,
      foodName TEXT,   -- ✅ Add this line
      quantity INTEGER,
      totalPrice REAL,
      address TEXT,
        phoneNumber TEXT,  -- ✅ New column
        landmark TEXT,
      status TEXT,
      paymentMethod TEXT
    )
  ''');


      await db.execute('''
  CREATE TABLE IF NOT EXISTS orders (  -- ✅ Fix: Prevent duplicate table creation
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    foodItemId INTEGER,
    foodName TEXT,
    quantity INTEGER,
    totalPrice REAL,
    address TEXT,
    phoneNumber TEXT,
    landmark TEXT,
    status TEXT,
    paymentMethod TEXT,
    timestamp TEXT
  )
''');




      await db.execute('''
        CREATE TABLE food_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          image TEXT
        )
      ''');

      await db.execute('''
       CREATE TABLE IF NOT EXISTS orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      foodItemId INTEGER,
      quantity INTEGER,
      totalPrice REAL,
      address TEXT,
        phoneNumber TEXT,  -- ✅ New column
        landmark TEXT,
      status TEXT DEFAULT 'Pending',
      orderDate TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (foodItemId) REFERENCES food_items(id)
  )

      ''');
      await db.execute('''
  CREATE TABLE IF NOT EXISTS favorites (  
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    food_id INTEGER,
    name TEXT,  -- ✅ Ensure the 'name' column is here
    image TEXT,
    price REAL
  )
''');

    }
    Future<void> printFavoritesTableSchema() async {
      final db = await DatabaseHelper.instance.database;
      List<Map<String, dynamic>> result = await db.rawQuery("PRAGMA table_info(favorites)");

      for (var column in result) {
        print("Column: ${column['name']} | Type: ${column['type']}");
      }
    }

    Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 3) { // Ensure new version is higher
        await db.execute('ALTER TABLE favorites ADD COLUMN name TEXT;');
        await db.execute('ALTER TABLE favorites ADD COLUMN image TEXT;');
        await db.execute('ALTER TABLE favorites ADD COLUMN price REAL;');
      }
    }


    Future<void> placeOrder(
        int userId,
        int foodItemId,
        int quantity,
        double price,
        String address,
        String paymentMethod,
        String foodName,
        String phoneNumber,
        String landmark,
        String timestamp,
        ) async {
      print("Storing Order: Phone Number = $phoneNumber");

      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'orders',
        {
          'userId': userId,
          'foodItemId': foodItemId,
          'foodName': foodName,
          'quantity': quantity,
          'totalPrice': price,
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

    Future<int> updateUser(int id, String phone, String address) async {
      final db = await database;
      return await db.update(
        'users',
        {'phone': phone, 'address': address},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  
    Future<Map<String, dynamic>?> getUserById(int userId) async {
      final db = await database;
      List<Map<String, dynamic>> result = await db.query(
        'users',
        columns: ['id', 'name', 'email', 'phone', 'address', 'role'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
  
      if (result.isNotEmpty) {
        return result.first; // Return user data if found
      }
      return null; // Return null if no user found
    }
    Future<void> addToFavorites(int userId, int foodId, String name, String image, int price) async {
      final db = await database;
      await db.insert(
        'favorites',
        {
          'user_id': userId,
          'food_id': foodId,
          'name': name,
          'image': image,
          'price': price,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Update if already exists
      );
    }


    Future<void> updateFoodPrice(int id, String name, double price, String imagePath) async {
      final db = await database;
      await db.update(
        'food_items', // ✅ Corrected table name
        {'name': name, 'price': price, 'image': imagePath},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  
  
    Future<Map<String, dynamic>?> getUserByEmail(String email) async {
      final db = await database;
      List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty ? result.first : null;
    }
  
  
  
    Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
      final db = await database;
      return await db.rawQuery('''
      SELECT orders.*, food_items.name AS food_name, food_items.price 
      FROM orders
      JOIN food_items ON orders.foodItemId = food_items.id
      WHERE orders.userId = ?
    ''', [userId]);
    }
    Future<String?> getUserName(String email) async {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        columns: ['name'],
        where: 'email = ?',
        whereArgs: [email],
      );
      if (result.isNotEmpty) {
        return result.first['name'] as String?;
      }
      return null;
    }
  
  
  


    Future<List<Map<String, dynamic>>> getOrders() async {
      final db = await database;
      return await db.query('orders', columns: [
        'id', 'userId', 'foodItemId', 'foodName', 'quantity', 'totalPrice',
        'address', 'phoneNumber', 'landmark', 'status', 'paymentMethod', 'timestamp' // Include timestamp
      ]);
    }





    Future<int> updateOrderStatus(int orderId, String newStatus) async {
      final db = await instance.database;
      return await db.update(
        'orders',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [orderId],
      );
    }

    Future<void> insertFoodItems(List<Map<String, dynamic>> foodList) async {
      final db = await database;
      for (var food in foodList) {
        print("Inserting: ${food['name']} | Image: ${food['image']}"); // ✅ Debugging
        await db.insert(
          'food_items',
          {
            'name': food['name'],
            'price': food['price'],
            'image': food['image'], // ✅ Ensure image path is stored
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  
    Future<void> testFetchFoodItems() async {
      final db = await DatabaseHelper.instance.database;
      List<Map<String, dynamic>> foods = await db.query('food_items');
  
      for (var food in foods) {
        print("Food: ${food['name']} | Image: ${food['image']}"); // ✅ Debugging
      }
    }

    Future<int> insertFoodItem(String name, String restaurant, int price, String image) async {
      final db = await database;
      return await db.insert('food_items', {
        'name': name,
        'restaurant': restaurant,
        'price': price,
        'image': image,
      });
    }


    Future<void> removeFromFavorites(int foodId, int userId) async {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'food_id = ? AND user_id = ?',
        whereArgs: [foodId, userId], // ✅ Ensure correct args
      );
    }

    Future<List<Map<String, dynamic>>> getFavoriteItems(int userId) async {
      final db = await database;
      return await db.query(
        'favorites',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    Future<int> createUser(String name, String email, String password, String phone, String address, String role) async {
      final db = await instance.database;
      return await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone, // 🔹 Added
        'address': address, // 🔹 Added
        'role': role,
      });
    }
  
  
    Future<Map<String, dynamic>?> getUser(String email, String password) async {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
  
      return result.isNotEmpty ? result.first : null;
    }
  
    Future<int> resetPassword(String email, String newPassword) async {
      final db = await instance.database;
      return await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
    }

    Future<void> addToFavoritesByName(int userId, String name) async {
      final db = await database;
      await db.insert(
        'favorites',
        {'user_id': userId, 'name': name},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    Future<void> removeFromFavoritesByName(int userId, String name) async {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'user_id = ? AND name = ?',
        whereArgs: [userId, name],
      );
    }

    Future<int> addFoodItem(String name, double price, String image) async {
      final db = await instance.database;
      return await db.insert('food_items', {'name': name, 'price': price, 'image': image});
    }



    Future<List<Map<String, dynamic>>> getFoodItems() async {
      final db = await database;
      return await db.query('food_items'); // ✅ 'id' automatically include hoga
    }




    Future<int> deleteFoodItem(int id) async {
      final db = await instance.database;
      return await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
    }
  }