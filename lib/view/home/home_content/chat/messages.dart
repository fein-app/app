import 'package:fein_app/states/chat_state.dart';
import 'package:fein_app/view/home/home_content/chat/ToggleTextField/toggle_text_field.dart';
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
        List<String> currentMessage = ["", ""];
        
        return ListView.builder(
          itemCount: totalItems,
          itemBuilder: (context, index) {
            if (index == messages.length && hasStreamingContent) {
              List<String> splitString = _splitString(currentMessage, snapshot.data ?? "");
              currentMessage = splitString;

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
                      child: ToggleTextField(
                        message: currentMessage[0],
                        think: currentMessage[1],
                      ),
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
                        maxWidth: message.sender ? 500.0 : double.infinity, 
                      ),
                      child: 
                        message.sender  
                        ? Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2c2c2c),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: SelectableText(message.message),
                            ),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x002c2c2c),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: ToggleTextField(
                                  message: message.message,
                                  think: message.think,
                                ),
                              ),
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

  List<String> _splitString(List<String> oldData, String newData) {
    String content =  oldData[0] + oldData[1] + newData;

        List<String> result = ["", ""]; // Ensure two elements exist
    RegExp exp = RegExp(r'<think>(.*?)</think>', dotAll: true);
    
    if (!exp.hasMatch(content)) {
      result[1] = content;
      return result;
    }
    
    int currentPosition = 0;
    for (Match match in exp.allMatches(content)) {
      if (match.start > currentPosition) {
        result[0] += content.substring(currentPosition, match.start); 
      }
      result[1] += match.group(1) ?? ''; 
      currentPosition = match.end;
    }
    
    if (currentPosition < content.length) {
      result[0] += content.substring(currentPosition);
    }
    
    return result;
  }
}