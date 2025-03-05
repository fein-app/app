import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fein_app/fein.dart';
import 'package:path/path.dart' as path;

class ChatsStore {
  Future<List<String>> getChats(String modelName) async {
    Directory dir = await getApplicationSupportDirectory();
    String subdirPath = "${dir.path}/$modelName/chats"; // Change this as needed
    Directory subdir = Directory(subdirPath);

    if (!(await subdir.exists())) {
      return [];
    }

    List<FileSystemEntity> fileEntities = [];
    await for (FileSystemEntity entity in subdir.list()) { 
      if (entity is File) {
        fileEntities.add(entity);
      }
    }

    fileEntities.sort((a, b) {
      DateTime aDate = a.statSync().modified;
      DateTime bDate = b.statSync().modified;
      return bDate.compareTo(aDate);
    });

    List<String> fileNames = fileEntities.map((file) {
      return path.basename(file.path);
    }).toList();

    return fileNames;
  }

  Future<List<Message>> getChat(String modelName, String chatName) async { // Debug print
    Directory dir = await getApplicationSupportDirectory();
    String filepath = '${dir.path}/$modelName/chats/$chatName';
    final file = File(filepath);

    if(!(await file.exists())) {
      return [];
    }

    String content = await file.readAsString();
    List<dynamic> jsonData = json.decode(content);

    return jsonData.map((e) => Message.fromJSON(e)).toList();
  }

  Future<void> createChat(String filename, String model) async {
    Directory dir = await getApplicationSupportDirectory();
    String filepath = '${dir.path}/$model/chats/$filename';
    print(filepath);
    final file = File(filepath);
    
    if (!(await file.exists())) {
      await file.create();
    } 

    await file.writeAsString("[]");
  }

  // True sender is the person and false is the model
  Future<void> updateChat(String model, String chat, Message message) async {
    Directory dir = await getApplicationSupportDirectory();
    String filepath = '${dir.path}/$model/chats/$chat';
    final file = File(filepath);

    if(!(await file.exists())) {
    }

    String content = await file.readAsString();
    List<dynamic> jsonData = json.decode(content);

    List<Message> messageList = jsonData.map((e) => Message.fromJSON(e)).toList();
    messageList.add(message);

    String updatedJson = json.encode(messageList.map((e) => e.toJSON()).toList());
    await file.writeAsString(updatedJson);
  }

  Future<void> deleteChat(String model, String filename) async {
    Directory dir = await getApplicationSupportDirectory();
    String filepath = '${dir.path}/$model/chats/$filename';
    final file = File(filepath);

    if (await file.exists()) {
      await file.delete();
    }
  }

}

