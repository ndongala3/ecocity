import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/report_service.dart';
import 'package:http/http.dart' as http;



class AddReportScreen extends StatefulWidget {
  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  File? _image;
  Position? _position;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _userIdController = TextEditingController();
  bool _isUserValid = false;

  Future<void> _validateUser() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) return;

    final response = await http.get(Uri.parse(
      'http://192.168.1.10:5000/api/validate_user/$userId',
    ));

    if (response.statusCode == 200 && response.body == 'true') {
      setState(() {
        _isUserValid = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur reconnu ✅')),
      );
    } else {
      setState(() {
        _isUserValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Identifiant invalide ❌")),
      );
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission de localisation refusée")),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _position = pos);
  }

  Future<void> _sendReport() async {
    if (_image != null && _position != null) {
      final userId = _userIdController.text.trim();

      bool success = await ReportService.sendReport(
        imageFile: _image!,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        userId: userId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Signalement envoyé ✅"
                : "Échec de l’envoi du signalement ❌",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo et position requises")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un point')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Identifiant utilisateur',
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _validateUser,
                ),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Prendre une photo'),
              onPressed: _isUserValid ? _takePhoto : null,
            ),
            SizedBox(height: 12),
            _image != null
                ? Image.file(_image!, height: 250)
                : Text('Aucune photo'),
            Divider(height: 30),

            ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Obtenir ma position'),
              onPressed: _isUserValid ? _getLocation : null,
            ),
            if (_position != null) ...[
              SizedBox(height: 12),
              Text('Latitude: ${_position!.latitude}'),
              Text('Longitude: ${_position!.longitude}'),
              SizedBox(height: 20),

              ElevatedButton.icon(
                icon: Icon(Icons.check_circle),
                label: Text('Valider'),
                onPressed: _isUserValid ? _sendReport : null, // fonction d’envoi propre
              ),
            ],
          ],
        ),
      ),
    );
  }
}
