// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pelayanan_jasa_umkm_flutter/FormPesan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeList {
  HomeList({
    required this.id,
    required this.navigateScreen,
    required this.imagePath,
    required this.name,
  });

  int id;
  Widget navigateScreen;
  String imagePath;
  String name;

  static List<HomeList> homeList = [];

  static Future<void> fetchDataFromApi() async {
    const String apiUrl =
        'https://umkmbackend.pjjaka.com/api/data/layanan';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final List<dynamic> data = json.decode(response.body)['data'];
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('DataLayanan', jsonEncode(data));
      homeList = data.map((item) {
        // Menggunakan default image jika gambar kosong
        String imagePath = item['gambar'] != null
            ? 'https://umkmbackend.pjjaka.com/' +
                item['gambar']
            : 'assets/default_image.png';
        String name = item['layanan'] ?? 'data kosong';
        int id = item['id']; // Ambil id dari data
        return HomeList(
          id: id,
          imagePath: imagePath,
          name: name,
          navigateScreen: const FormPesan(
            id: null,
          ),
        );
      }).toList();
    } catch (error) {
      // Tangani kesalahan jika terjadi
      print('Error fetching data: $error');
    }
  }
}
