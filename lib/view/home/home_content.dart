import 'package:fein_app/states/chat_state.dart';
import 'package:fein_app/view/home/home_content/chat.dart';
import 'package:flutter/material.dart';
import 'package:fein_app/view/models.dart';
import 'package:provider/provider.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final bool isDrawerOpen; // Add this parameter

  const HomeContent({
    super.key,
    required this.onMenuPressed,
    required this.isDrawerOpen, // Add this parameter
  });
 
  @override
  Widget build(BuildContext context) {
    String currChat = context.watch<ChatState>().currentChat;

    return Scaffold(
      backgroundColor: Color(0xFF1b1b1b),
      appBar: AppBar(
        backgroundColor: Color(0xFF1b1b1b),
        leading: IconButton(
          onPressed: onMenuPressed,
          icon: Icon(isDrawerOpen ? Icons.close : Icons.menu),
        ),
        title: Text(currChat == "new" ? "New chat" : currChat),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModelScreen()),
              );
            },
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
            child: Text("Add models +", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
          ),
        ],
      ),
      body: Chat(),
    );
  }
}
