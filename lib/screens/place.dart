import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePlaceScreen extends StatefulWidget {
  const CreatePlaceScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {

  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _loading = false;
  String _message = "";

  Future<void> _createPlace() async {
    setState(() {
      _loading = true;
      _message = "";
    });

    try {
      final name = _nameController.text.trim();
      final latitude = double.parse(_latitudeController.text.trim());
      final longitude = double.parse(_longitudeController.text.trim());

      if (name.isEmpty) {
        setState(() {
          _message = "Place name cannot be empty";
          _loading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection("places").add({
        "name": name,
        "name_lower": name.toLowerCase(), // 🔥 important for search
        "latitude": latitude,
        "longitude": longitude,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _message = "✅ Place added successfully";
      });

      _nameController.clear();
      _latitudeController.clear();
      _longitudeController.clear();

    } catch (e) {
      setState(() {
        _message = "❌ Failed to add place";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Place Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _latitudeController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Latitude (Google First Value)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _longitudeController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Longitude (Google Second Value)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains("❌")
                      ? Colors.red
                      : Colors.green,
                ),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _createPlace,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Place"),
            ),
          ],
        ),
      ),
    );
  }
}