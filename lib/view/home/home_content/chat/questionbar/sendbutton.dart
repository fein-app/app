import 'package:fein_app/states/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendButton extends StatelessWidget {
  final Future<void> Function(String) onSubmitted;
  final TextEditingController controller; 

  const SendButton({
    super.key,
    required this.onSubmitted,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatState>(context);

    return IconButton(
      onPressed: () {
        if (chatProvider.promptable && controller.text.trim().isNotEmpty) {
          onSubmitted(controller.text); 
          controller.clear(); 
        } else if (chatProvider.kill) {
          chatProvider.killResponse(); 
        }
      },
      icon: Icon(
        chatProvider.promptable
            ? Icons.arrow_upward 
            : Icons.stop, 
        color: chatProvider.promptable ? Color(0xFFe9e9e9) : Color(0xFF2c2c2c),
      ),
    );
  }
}
