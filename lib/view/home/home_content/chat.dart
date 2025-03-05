  import 'package:fein_app/fein.dart';
  import 'package:fein_app/states/chat_state.dart';
  import 'package:fein_app/states/model_state.dart';
  import 'package:fein_app/view/home/home_content/chat/questionbar.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:fein_app/view/home/home_content/chat/messages.dart';

  class Chat extends StatelessWidget {
    const Chat({super.key});
  
    @override
    Widget build(BuildContext context) {
      ChatState currChat = context.watch<ChatState>();
      ModelState currModel = context.watch<ModelState>();
      final chatProvider = Provider.of<ChatState>(context);

      if (currChat.currentChat == "new") {
        return SizedBox(
          width: double.infinity, // Fill the entire width
          height: double.infinity,
          child: Align(
            alignment: Alignment.bottomCenter, // Align the Column to the bottom center
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Align children to the bottom
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                Text("Hi, I'm ${currModel.currentModel}.", style: TextStyle(fontSize: 28),),
                SizedBox(height: 10),
                Text("How can I help you today?", style: TextStyle(fontSize: 16),),
                SizedBox(height: 20),
                QuestionBar(
                  onSubmitted: (value) async {
                    String newChatName = '${value.split(' ').take(3).toList().join(' ')}...';

                    await chatProvider.createChat(currModel.currentModel.name, newChatName);
                    await chatProvider.changeChat(currModel.currentModel.name, newChatName);
                    await chatProvider.appendMessage(currModel.currentModel.name, Message(sender: true, date: DateTime.now(), message: value, think: ""));
                    await chatProvider.generateResponse(currModel.currentModel.name, currModel.currentUri, value);
                  },
                ), 
              ],
            ),
          ),
        );
      } else {
        return Column(
          children: [
            Expanded(
              child: Messages(),
            ),

            // Fixed QuestionBar at the bottom
            QuestionBar(
              onSubmitted: (value) async {
                await chatProvider.appendMessage(currModel.currentModel.name, Message(sender: true, date: DateTime.now(), message: value, think: ""));
                chatProvider.generateResponse(currModel.currentModel.name, currModel.currentUri, value);
              },
            ),
          ],
        );
      }
    }
  }