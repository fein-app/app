import 'package:flutter/material.dart';

class ToggleTextField extends StatefulWidget {
  final String message;
  final String think; // Allow passing initial text

  ToggleTextField({required this.message, required this.think, Key? key}) : super(key: key);

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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, 
      children: [
        ElevatedButton(
          onPressed: _toggleTextField,
          child: Text(_isTextFieldVisible ? "Think >" : "Think v"),
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
