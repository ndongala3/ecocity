import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ReportService {
  static Future<bool> sendReport({
    required File imageFile,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    var uri = Uri.parse('http://192.168.1.10:5000/api/reports'); // ← remplace par ton IP locale

    var request = http.MultipartRequest('POST', uri)
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..fields['user_id'] = userId
      ..files.add(await http.MultipartFile.fromPath(
        'photo',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    var response = await request.send();
    return response.statusCode == 200;
  }
}
