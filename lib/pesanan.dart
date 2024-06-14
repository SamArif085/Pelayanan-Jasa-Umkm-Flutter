import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pelayanan_jasa_umkm_flutter/DetailPesanan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_theme.dart';

class Pesanan extends StatefulWidget {
  const Pesanan({Key? key});

  @override
  _PesananState createState() => _PesananState();
}

class _PesananState extends State<Pesanan> {
  List<Map<String, dynamic>> _pesananList = [];

  @override
  void initState() {
    super.initState();
    _fetchPesananData();
  }

  Future<void> _fetchPesananData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userDataString = preferences.getString('userData');
    if (userDataString == null) {
      // Penanganan jika UserData tidak ditemukan
      print('UserData not found in SharedPreferences');
      return;
    }

    Map<String, dynamic> userData = jsonDecode(userDataString);
    int? idUser = userData['value']['id']; // Mengambil id dari UserData
    if (idUser == null) {
      print('ID User not found');
      return;
    }

    String apiUrl =
        'https://umkmbackend.pjjaka.com/api/riwayat-pesanan/$idUser';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _pesananList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {});
    }
  }

  List<Widget> _buildCards() {
    return _pesananList.map((pesanan) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPesanan(pesanan: pesanan),
            ),
          );
        },
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(pesanan['data_layanan']['layanan'] ?? ''),
            subtitle: Text(pesanan['masalah'] ?? ''),
            trailing: Text(statusMap[pesanan['status']] ?? ''),
          ),
        ),
      );
    }).toList();
  }

  Map<int, String> statusMap = {
    0: 'Menunggu Konfirmasi',
    1: 'Proses Pesanan',
    2: 'Proses Pengerjaan',
    3: 'Pesanan Selesai',
    4: 'Pesanan Dibatalkan',
  };

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          body: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 45, left: 16, right: 16),
                child: Text(
                  'Pesanan',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _buildCards(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
