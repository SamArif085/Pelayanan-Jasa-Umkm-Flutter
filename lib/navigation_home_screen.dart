// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'custom_drawer/drawer_user_controller.dart';
import 'custom_drawer/home_drawer.dart';
import 'FormUser.dart';
import 'pesanan.dart';
import 'home_screen.dart';

class NavigationHomeScreen extends StatefulWidget {
  const NavigationHomeScreen({super.key});

  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;
  late int userId; // Menyimpan userId dari SharedPreferences

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    getUserIdFromSharedPreferences(); // Panggil fungsi untuk mengambil userId dari SharedPreferences
    super.initState();
  }

  // Fungsi untuk mengambil userId dari SharedPreferences
  Future<void> getUserIdFromSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userDataString = preferences.getString('userData');

    if (userDataString != null) {
      Map<String, dynamic> userDataJson = jsonDecode(userDataString);
      userId = userDataJson['value']['id'];
        print(userId);
    } else {
      userId = 0; // Atur userId menjadi null jika data tidak ditemukan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const MyHomePage();
          });
          break;
        case DrawerIndex.Help:
          setState(() {
            screenView = Pesanan();
          });
          break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = EditUserForm(
              userId: userId,
              key: null,
            ); // Gunakan userId di sini
          });
          break;

        default:
          break;
      }
    }
  }
}
