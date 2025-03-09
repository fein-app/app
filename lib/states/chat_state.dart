import 'dart:async';
import 'package:fein_app/dpk/model_utils.dart';
import 'package:fein_app/fein.dart';
import 'package:fein_app/store/chats_store.dart';
import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  String currentChat = "new";
  List<String> currentChats = [];
  List<Message> currentMessagesFromChat = [];
  StreamController<String>? _responseController;
  Stream<String>? get currentResponse => _responseController?.stream;
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;
  
  bool promptable = true;
  bool kill = false;
  
  ChatState() {
    _initCompleter.complete();
    _initialize();
  }
  
  Future<void> _initialize() async {
    notifyListeners();
  }
  
  void killResponse() {
    if (!kill) kill = true;
    notifyListeners();
  }

  Future<void> changeModel(String model) async {
    currentChats = await ChatsStore().getChats(model);
    currentChat = "new";
    notifyListeners();
  }
  
  Future<void> createChat(String model, String name) async {
    await ChatsStore().createChat(name, model);
    currentChat = name;
    currentChats = [name, ...currentChats];
    notifyListeners();
  }
  
  Future<void> deleteChat(String model, String name) async {
    currentChats.remove(name);
    if (currentChats.isEmpty) changeChat(model, "new");
    await ChatsStore().deleteChat(model, name);
    notifyListeners();
  }
  
  Future<void> changeChat(String model, String name) async {
    currentChat = name;
    currentMessagesFromChat = await ChatsStore().getChat(model, name);
    notifyListeners();
  }
  
  Future<void> appendMessage(String model, Message message) async {
    currentMessagesFromChat.add(message);
    await ChatsStore().updateChat(model, currentChat, message);
    notifyListeners();
  }
  
  Future<void> generateResponse(String model, Uri uri, String prompt) async {
    if (!promptable) kill = true;

    if (promptable) {
      if (kill) kill = false;
      promptable = false;
      
      if (_responseController != null) {
        _responseController!.close();
      }
      _responseController = StreamController<String>.broadcast();
      
      StringBuffer buffer = StringBuffer();
      StreamSubscription<String>? subscription;
      
      try {
        Stream<String> responseStream = ModelExecUtils().generateResponse(uri, currentMessagesFromChat, prompt);
        bool hasError = false;
        Completer<void> streamDone = Completer<void>();
        
        subscription = responseStream.listen(
          (String chunk) {
            if (!kill) {
              buffer.write(chunk);
              
              if (_responseController != null && !_responseController!.isClosed) {
                _responseController!.add(buffer.toString());
              } 
            } else {
              subscription?.cancel();
              if (!streamDone.isCompleted) streamDone.complete();
              kill = false;
            }
          },
          onError: (error) {
            hasError = true;
            if (!streamDone.isCompleted) streamDone.complete();
          },
          onDone: () async {
            if (!kill) {
              Message newMessage = Message.fromBuffer(buffer.toString());
              
              await appendMessage(model, newMessage);
              kill = false;
              
              if (_responseController != null && !_responseController!.isClosed) {
                _responseController!.close();
              }
              _responseController = null;
            }
            if (!streamDone.isCompleted) {
              streamDone.complete();
            }
          },
        );
        
        await streamDone.future;
      } catch (e) {
        print(e);
      } finally {
        await subscription?.cancel();
        
        if (_responseController != null && !_responseController!.isClosed) {
          _responseController!.close();
        }
        
        promptable = true;
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _responseController?.close();
    super.dispose();
  }
}