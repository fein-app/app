import 'dart:typed_data';

import 'package:fein_app/fein.dart';
import 'package:fein_app/states/chat_state.dart';
import 'package:fein_app/states/internet_state.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:fein_app/states/search_state.dart';
import 'package:fein_app/store/models_store.dart';
import 'package:fein_app/view/models.dart';
import 'package:flutter/material.dart';
import 'package:fein_app/view/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatState()),
        ChangeNotifierProvider(create: (context) => ModelState()),
        ChangeNotifierProvider(create: (context) => InternetState()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }
  
  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    
    if (isFirstLaunch) {
      // Set the flag to false for future launches
      await prefs.setBool('first_launch', false);
      
      // Add a small delay to ensure context is available
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showInfoDialog(context);
        }
      });
    }
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1b1b1b),
          title: Text('Important Information'),
          content: SingleChildScrollView(
            child: Container(
              color: Color(0xFF1b1b1b),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("- Before installing any model make sure that you are not installing malitious software."),
                  SizedBox(height: 8),
                  Text("- The app can only run models .gguf format. (We are working on more formats)"),
                  SizedBox(height: 8),
                  Text("- You can check your download status under Home > Account"),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
              side: BorderSide(
                width: 1.0,
                color: Color(0xFF2c2c2c)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
            ),
              child: Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Model> currModels = context.watch<ModelState>().currentModels;
    return MaterialApp(
      title: 'FEiN',
      home: currModels.isNotEmpty ? Home() : ModelScreen(),
      theme: ThemeData.dark(),
    );
  }
}