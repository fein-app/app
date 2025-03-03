import 'package:fein_app/states/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatState>(context);
    final messages = chatProvider.currentMessagesFromChat;
    
    
    return StreamBuilder<String>(
      stream: chatProvider.currentResponse,
      builder: (context, snapshot) {
        
        if (messages.isEmpty && !snapshot.hasData) {
          return Center(child: Text("No messages yet"));
        }
        
        final hasStreamingContent = snapshot.hasData && chatProvider.currentResponse != null;
        final totalItems = messages.length + (hasStreamingContent ? 1 : 0);
        
        
        return ListView.builder(
          itemCount: totalItems,
          itemBuilder: (context, index) {
            
            if (index == messages.length && hasStreamingContent) {
              return SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0x002c2c2c),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: SelectableText(snapshot.data ?? ""),
                    ),
                  ),
                ),
              );
            } else {
              if (index < messages.length) {
                final message = messages[index];
                
                return SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: message.sender ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: message.sender ? 500.0 : double.infinity, // Set your desired max width here (e.g., 250 pixels)
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: message.sender ? Color(0xFF2c2c2c) : Color(0x002c2c2c),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: SelectableText(message.message),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(); 
              }
            }
          },
        );
      }
    );
  }
}