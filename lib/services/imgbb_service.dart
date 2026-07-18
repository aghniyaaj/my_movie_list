import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';

class ImgbbService {
  static Future<String?> uploadImage(XFile image) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.imgbb.com/1/upload?key=${AppConstants.imgbbApiKey}')
      );

      http.MultipartFile pic;

      if (kIsWeb) {
        // --- JALUR KHUSUS UNTUK WEB (CHROME) ---
        // Di Web, kita harus membaca foto sebagai serangkaian 'Bytes' (data digital)
        var bytes = await image.readAsBytes();
        pic = http.MultipartFile.fromBytes(
          'image', 
          bytes, 
          filename: image.name // Di web kita perlu menyertakan nama file
        );
      } else {
        // --- JALUR UNTUK MOBILE (ANDROID/iOS) ---
        // Di mobile, kita bisa langsung mengambil file dari jalurnya (Path)
        pic = await http.MultipartFile.fromPath('image', image.path);
      }

      request.files.add(pic);

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = String.fromCharCodes(responseData);

      var jsonMap = json.decode(result);
      if (jsonMap['success'] == true) {
        String finalUrl = jsonMap['data']['display_url'];
        debugPrint('BERHASIL UPLOAD! URL: $finalUrl');
        return finalUrl;
      } else {
        throw Exception("Gagal mendapatkan URL dari ImgBB");
      }
    } catch (e) {
      debugPrint("Error upload ImgBB: $e");
      return null;
    }
  }
}