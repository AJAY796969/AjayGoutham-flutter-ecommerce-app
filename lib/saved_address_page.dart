import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressPage extends StatefulWidget {
  const SavedAddressPage({super.key});

  @override
  State<SavedAddressPage> createState() => _SavedAddressPageState();
}

class _SavedAddressPageState extends State<SavedAddressPage> {
  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("savedAddresses");

    if (saved != null) {
      final decoded = jsonDecode(saved) as List<dynamic>;
      setState(() {
        addresses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      setState(() {
        addresses = [];
      });
    }
  }

  Future<void> saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("savedAddresses", jsonEncode(addresses));
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void openAddEditDialog({Map<String, dynamic>? existing, int? index}) {
    final nameController = TextEditingController(text: existing?["name"] ?? "");
    final phoneController = TextEditingController(text: existing?["phone"] ?? "");
    final addressController = TextEditingController(text: existing?["address"] ?? "");
    final pincodeController = TextEditingController(text: existing?["pincode"] ?? "");
    final cityController = TextEditingController(text: existing?["city"] ?? "");
    final stateController = TextEditingController(text: existing?["state"] ?? "");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  existing == null ? "Add New Address" : "Edit Address",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                TextField(
                  controller: nameController,
                  decoration: _fieldDecoration("Full Name"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: phoneController,
                  decoration: _fieldDecoration("Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: addressController,
                  decoration: _fieldDecoration("Full Address"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: cityController,
                  decoration: _fieldDecoration("City"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: stateController,
                  decoration: _fieldDecoration("State"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: pincodeController,
                  decoration: _fieldDecoration("Pincode"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                nameController.dispose();
                phoneController.dispose();
                addressController.dispose();
                pincodeController.dispose();
                cityController.dispose();
                stateController.dispose();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty ||
                      cityController.text.trim().isEmpty ||
                      stateController.text.trim().isEmpty ||
                      pincodeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final newAddress = {
                    "name": nameController.text.trim(),
                    "phone": phoneController.text.trim(),
                    "address": addressController.text.trim(),
                    "city": cityController.text.trim(),
                    "state": stateController.text.trim(),
                    "pincode": pincodeController.text.trim(),
                  };

                  setState(() {
                    if (existing == null) {
                      addresses.add(newAddress);
                    } else {
                      addresses[index!] = newAddress;
                    }
                  });

                  await saveAddresses();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existing == null
                            ? "Address Added ✅"
                            : "Address Updated ✅",
                      ),
                    ),
                  );

                  nameController.dispose();
                  phoneController.dispose();
                  addressController.dispose();
                  pincodeController.dispose();
                  cityController.dispose();
                  stateController.dispose();
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }void deleteAddress(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Delete Address?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      addresses.removeAt(index);
    });

    await saveAddresses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address Deleted ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Saved Address",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: addresses.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 46,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "No saved address yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tap the button below to add a delivery address.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: () => openAddEditDialog(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final a = addresses[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF9FBFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ HEADER ROW
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          a["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // ✅ Edit Button
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => openAddEditDialog(
                          existing: a,
                          index: index,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ✅ Delete Button
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => deleteAddress(index),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ✅ Phone
                  Row(
                    children: [
                      Icon(Icons.call, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${a["phone"]}",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ✅ Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${a["address"]}",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ✅ City / State / Pincode pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop,
                            size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${a["city"]}, ${a["state"]} - ${a["pincode"]}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => openAddEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}