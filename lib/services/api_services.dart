import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this if testing on a physical phone!
  static const String apiUrl = 'http://192.168.8.60:5000/analyze-accident';

  static Future<Map<String, dynamic>?> analyzeDamage(File imageFile) async {
    try {
      // Create the Multipart Request (Just like Postman's form-data)
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Attach the image file
      var multipartFile =
          await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send().timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw Exception('Request timed out after 20 seconds'),
          );

      // Listen for the response
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);

        return jsonResult;
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> extractLicensePlate(
      File imageFile) async {
    final String plateUrl = 'http://192.168.8.60:5000/extract-plate';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(plateUrl));

      var multipartFile =
          await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send().timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw Exception('Request timed out after 20 seconds'),
          );

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);

        final String rawPlate =
            (jsonResult['license_plate'] ?? '').toString().trim();
        final int confidence = jsonResult['confidence'] ?? 0;
        return {
          'plate_text': rawPlate,
          'confidence': confidence,
        };
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }
}
