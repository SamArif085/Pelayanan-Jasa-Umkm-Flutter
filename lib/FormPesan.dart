// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'navigation_home_screen.dart';

class FormPesan extends StatefulWidget {
  final int? id;

  const FormPesan({super.key, required this.id});

  @override
  _FormPesanState createState() => _FormPesanState();
}

class _FormPesanState extends State<FormPesan> {
  final _formKey = GlobalKey<FormState>();

  final _problemDetailController = TextEditingController();
  final _customerAddressController = TextEditingController();
  int? _selectedElectronicId;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _electronics = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadElectronics();
  }

  Future<void> _loadElectronics() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? dataLayanan = preferences.getString('DataLayanan');
    if (dataLayanan != null) {
      List<dynamic> data = jsonDecode(dataLayanan);
      setState(() {
        _electronics = List<Map<String, dynamic>>.from(data);
        var selectedData = _electronics.firstWhereOrNull(
          (element) => element['id'] == widget.id,
        );
        if (selectedData != null) {
          _selectedElectronicId = selectedData['id'];
        }
      });
    }
  }

  Future<void> submitFormData() async {
    setState(() {
      _isSubmitting = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userDataString = preferences.getString('userData');

    if (userDataString != null) {
      Map<String, dynamic> userData = jsonDecode(userDataString);
      int? userId = userData['value']['id'];

      if (userId != null) {
        String apiUrl =
            'https://umkmbackend.pjjaka.com/api/submit-pesanan';

        if (_selectedElectronicId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an electronic item')),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        String? formattedDate;
        if (_selectedDate != null) {
          formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        } else {
          formattedDate = '';
        }

        Map<String, dynamic> formData = {
          'id_pelanggan': userId.toString(),
          'layanan': _selectedElectronicId.toString(),
          'masalah': _problemDetailController.text,
          'tgl_pesan': formattedDate,
          'alamat': _customerAddressController.text,
        };

        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            body: formData,
          );

          print('API Response: ${response.body}');

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pesanan Berhasil')),
            );

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const NavigationHomeScreen()),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to submit form')),
            );
          }
        } catch (error) {
          print('Error submitting form: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An error occurred')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  void dispose() {
    _problemDetailController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
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
            title: Text(
              'Form Pesanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Nama Elektronik',
                      ),
                      value: _selectedElectronicId,
                      items:
                          _electronics.map((Map<String, dynamic> electronic) {
                        return DropdownMenuItem<int>(
                          value: electronic['id'],
                          child: Text(electronic['layanan']),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedElectronicId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an electronic item';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _problemDetailController,
                      decoration: const InputDecoration(
                        labelText: 'Detail Masalah',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the problem details';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'No Date Chosen!'
                                : 'Tanggal Servis: ${DateFormat.yMd().format(_selectedDate!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: _presentDatePicker,
                          child: const Text(
                            'Choose Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _customerAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Pelanggan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Data sedang diproses')),
                              );
                            }
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                                submitFormData();
                              }
                            },
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
