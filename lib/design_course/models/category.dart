import 'dart:convert';
import 'package:http/http.dart' as http;

class Category {
  Category({
    required this.id,
    required this.layanan,
    required this.masalah,
    required this.status,
  });

  final int id;
  final String layanan;
  final String masalah;
  final int status;

  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('http://192.168.18.3/Pelayanan-Jasa-Umkm-BE-Laravel/public/api/riwayat-pesanan'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((category) {
        return Category(
          id: category['id'],
          layanan: category['layanan'],
          masalah: category['masalah'],
          status: category['status'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}

