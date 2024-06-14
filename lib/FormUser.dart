// ignore_for_file: must_be_immutable, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';

class EditUserForm extends StatefulWidget {
  int userId;

  EditUserForm({super.key, required this.userId});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();

  String currentPassword = ''; // Menyimpan password saat ini dari data pengguna

  @override
  void initState() {
    super.initState();
    // Load user data from API and set initial values in controllers
    fetchUserData();
  }

  void fetchUserData() async {
    final url = Uri.parse(
        'https://umkmbackend.pjjaka.com/api/user/mobile/${widget.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> userDataList =
          jsonResponse['data']; // Ambil data dari 'data'

      if (userDataList.isNotEmpty) {
        // Ambil data dari objek pertama dalam list (asumsi hanya satu objek)
        Map<String, dynamic> userData = userDataList[0];
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _noTelpController.text = userData['no_telp'] ?? '';
          currentPassword =
              userData['password'] ?? ''; // Simpan password saat ini
        });
      } else {
        // Handle jika tidak ada data ditemukan
        print('User data not found');
      }
    } else {
      // Handle error
      print('Failed to load user data: ${response.statusCode}');
    }
  }

  void updateUser() async {
    if (_formKey.currentState!.validate()) {
      // Prepare data to send to API
      Map<String, dynamic> userData = {
        'username': _usernameController.text,
        'no_telp': _noTelpController.text,
      };

      // Check if password is changed
      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      } else {
        // Use current password if not changed
        userData['password'] = currentPassword;
      }

      final url = Uri.parse(
          'https://umkmbackend.pjjaka.com/api/submit-update-user/${widget.userId}');
      final response = await http.put(
        url,
        body: jsonEncode(userData),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success
        print('User updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      } else {
        // Error
        print('Failed to update user: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                'Form Edit User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _noTelpController,
                    decoration:
                        const InputDecoration(labelText: 'Nomor Telepon'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nomor Telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true, // Membuat password tersembunyi
                    validator: (value) {
                      if (_passwordController.text.isEmpty &&
                          currentPassword.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        updateUser();
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
