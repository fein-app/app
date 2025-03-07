import 'package:flutter/material.dart';

class ToggleTextField extends StatefulWidget {
  final String message;
  final String think; // Allow passing initial text

  const ToggleTextField({required this.message, required this.think, super.key});

  @override
  _ToggleTextFieldState createState() => _ToggleTextFieldState();
}

class _ToggleTextFieldState extends State<ToggleTextField> {
  bool _isTextFieldVisible = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleTextField() {
    setState(() {
      _isTextFieldVisible = !_isTextFieldVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // Changed from center to start
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: Color(0x00000000),
            side: BorderSide(
              width: 1.0,
              color: _isTextFieldVisible ? Color(0xFF2c2c2c) : Color(0x002c2c2c)
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: _toggleTextField,
          child: Text(_isTextFieldVisible ? "Thougths" : "Thougths", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
        ),
        if (_isTextFieldVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SelectableText(widget.think),
              ],
            ),
          ),
        SelectableText(widget.message),
      ],
    );
  }
}
