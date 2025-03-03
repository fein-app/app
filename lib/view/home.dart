import 'package:fein_app/view/home/home_content.dart';
import 'package:fein_app/view/home/sidebar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isDrawerOpen = true;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF1b1b1b),
    body: Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isDrawerOpen ? 300 : 0,
          child: Drawer(
            child: Sidebar(isDrawerOpen: isDrawerOpen),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15.0,
              left: 30.0,   
              bottom: 30.0, 
              right: 30.0,  
            ),
            child: HomeContent(
              isDrawerOpen: isDrawerOpen,
              onMenuPressed: () {
                setState(() {
                  isDrawerOpen = !isDrawerOpen; // Toggle the drawer state
                });
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}