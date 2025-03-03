import 'package:fein_app/states/chat_state.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:fein_app/view/account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  final bool isDrawerOpen;

  const Sidebar({super.key, required this.isDrawerOpen});

  @override
  Widget build(BuildContext context) {
    String model = context.watch<ModelState>().currentModel;
    String currChat = context.watch<ChatState>().currentChat;
    List<String> currentModels = context.watch<ModelState>().currentModels;
    final chatProvider = Provider.of<ChatState>(context);

    return Drawer(
      backgroundColor: Color(0xFF101010),
      child: Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
          children: [
            Container(
              decoration: BoxDecoration( 
                border: Border.all(
                  color: Colors.grey, 
                  width: 1.5, 
                ),
                borderRadius: BorderRadius.circular(8), 
              ),
              child: DropdownButton<String>(
                borderRadius: BorderRadius.circular(8), 
                value: model,
                hint: Center(
                  child: Text(
                    "Switch the model",
                    textAlign: TextAlign.center, 
                  ),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<ModelState>().changeModel(newValue);
                  }
                },
                items: currentModels.map<DropdownMenuItem<String>>((model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Center(
                      child: Text(
                        model,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
                underline: Container(),
                isExpanded: true, 
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  chatProvider.changeChat(model, "new");
                  chatProvider.killResponse();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFe9e9e9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                ),
                label: Text("New chat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                icon: Icon(IconData(0xe154, fontFamily: 'MaterialIcons',), color: Colors.black,),
              ),
            ),

            SizedBox(
              height: 80,
            ),

            Container(
              alignment: Alignment.centerLeft,
              child: Text("Last conversations"),
            ),

            SizedBox(
              height: 10,
            ),

            Expanded(
              child: ListView.separated(
                itemCount: chatProvider.currentChats.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final chat = chatProvider.currentChats[index];

                  return TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: chat == currChat ? const Color(0xFF2B2B2B) : const Color(0x002B2B2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      chatProvider.changeChat(model, chat);
                      chatProvider.killResponse();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () {
                            chatProvider.deleteChat(model, chat);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              height: 10,
            ),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Account(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x00000000),
                side: BorderSide(
                  width: 1.0,
                  color: Color(0xFF2c2c2c)
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0)
              ),
              label: Text("Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
              icon: Icon(IconData(0xee35, fontFamily: 'MaterialIcons'), color: Colors.white,),
            ),

            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
