  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:UEEats/services/database_service.dart';

  class ManageFoodPage extends StatefulWidget {
    const ManageFoodPage({super.key});

    @override
    _ManageFoodPageState createState() => _ManageFoodPageState();
  }

  class _ManageFoodPageState extends State<ManageFoodPage> {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _priceController = TextEditingController();
    File? _selectedImage;
    List<Map<String, dynamic>> foodItems = [];

    @override
    void initState() {
      super.initState();
      _loadFoodItems();
    }

    Future<void> _loadFoodItems() async {
      final items = await DatabaseHelper.instance.getFoodItems();
      setState(() => foodItems = items);
    }

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
    Future<void> _addFoodItem() async {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0;

      if (name.isNotEmpty && price > 0 && _selectedImage != null) {
        await DatabaseHelper.instance.addFoodItem(
          name,
          price,
          _selectedImage!.path,
          category: "Others",
        );

        _nameController.clear();
        _priceController.clear();
        setState(() => _selectedImage = null);

        // Reload food items after adding a new one
        _loadFoodItems();  // This will update the list of food items
        Navigator.pop(context);
      }
    }




    Future<void> _deleteFoodItem(int id) async {
      await DatabaseHelper.instance.deleteFoodItem(id);
      _loadFoodItems();
    }



    void _showAddFoodDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.yellow.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Add Food Item", style: TextStyle(color: Colors.black)),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit height
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Image at the top
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 100, width: 200, fit: BoxFit.cover)
                        : const Text("No image selected", style: TextStyle(color: Colors.black54)),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, color: Colors.amber),
                      label: const Text("Select Image", style: TextStyle(color: Colors.black)),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Food Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: _addFoodItem,
                child: const Text("Add", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );
    }





    void _showEditFoodDialog(Map<String, dynamic> item) {
      TextEditingController _editNameController = TextEditingController(text: item['name']);
      TextEditingController _editPriceController = TextEditingController(text: item['price'].toString());
      File? _newImage;

      Future<void> _pickNewImage() async {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() => _newImage = File(pickedFile.path));
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Food Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editNameController,
                  decoration: InputDecoration(
                    labelText: "Food Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _editPriceController,
                  decoration: InputDecoration(
                    labelText: "New Price (PKR)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _newImage != null
                    ? Image.file(_newImage!, height: 100, width: 100, fit: BoxFit.cover)
                    : item['image'] != null && File(item['image']).existsSync()
                    ? Image.file(File(item['image']), height: 100, width: 100, fit: BoxFit.cover)
                    : const Text("No image selected", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickNewImage,
                  icon: const Icon(Icons.image, color: Colors.amber),
                  label: const Text("Change Image", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () async {
                  final newName = _editNameController.text.trim();
                  final newPrice = double.tryParse(_editPriceController.text.trim()) ?? item['price'];
                  final newImagePath = _newImage != null ? _newImage!.path : item['image'];

                  if (newName.isNotEmpty && newPrice > 0) {
                    await DatabaseHelper.instance.updateFoodPrice(item['id'], newName, newPrice, newImagePath);
                    _loadFoodItems();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );
    }


    @override
    Widget build(BuildContext context) {
      return Theme(
        data: ThemeData(
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.yellow.shade100,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.amber),
        ),
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddFoodDialog,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return Card(
                  color: Colors.yellow.shade50,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: item['image'] != null && File(item['image']).existsSync()
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item['image'].startsWith('assets/')
                          ? Image.asset(
                        item['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        File(item['image']),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.fastfood, size: 50, color: Colors.amber),
                    title: Text(
                      item['name'],
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Text(
                      'PKR ${item['price']}',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditFoodDialog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFoodItem(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ),
      );
    }
  }
