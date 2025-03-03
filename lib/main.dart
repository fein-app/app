import 'package:fein_app/states/chat_state.dart';
import 'package:fein_app/states/internet_state.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:fein_app/states/search_state.dart';
import 'package:flutter/material.dart';
import 'package:fein_app/view/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final modelState = Provider.of<ModelState>(context, listen: false);
      await modelState.changeModel(modelState.currentModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FEiN',
      home: Home(),
      theme: ThemeData.dark(),
    );
  }
}
