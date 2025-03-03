import 'dart:convert';
import 'dart:io';
import 'package:fein_app/fein.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ModelsStore {
  Future<List<String>> getModels() async {
    Directory dir = await getApplicationSupportDirectory();
    
    List<FileSystemEntity> entities = dir.listSync();
    List<String> modelNames = [];

    for (var entity in entities) {  
      if (entity is Directory) {  
        String dirName = path.basename(entity.path);
        modelNames.add(dirName);
      } 
    }

    return modelNames;
  }

  Future<String?> getOneModelFile(String name) async {
    Directory dir = await getApplicationSupportDirectory();
    Directory modelDir = Directory('${dir.path}/$name');
    
    // Check if the directory exists
    if (!await modelDir.exists()) {
      return null;
    }
    
    List<FileSystemEntity> entities = await modelDir.list().toList();
    
    List<File> ggufFiles = entities
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.gguf'))
        .toList();
    
    return ggufFiles.isNotEmpty ? ggufFiles.first.path : null;
  }

  Future<void> createModel(String name, String repoID) async {
    Directory dir = await getApplicationSupportDirectory();
    Directory newDir = Directory('${dir.path}/$name');
    Directory chatsSubdir = Directory('${dir.path}/$name/chats');

    if (!(await newDir.exists())) {
      await newDir.create();
      await chatsSubdir.create();
    } 

    await downloadModelFiles(name, repoID, "");

  }

  Future<void> deleteModel(String name) async {
    Directory dir = await getApplicationSupportDirectory();
    String path = '${dir.path}/$name';

    Directory folder = Directory(path);

    try {
      if (await folder.exists()) {
        await folder.delete(recursive: true);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteAll() async {
    Directory dir = await getApplicationSupportDirectory();

    try {
      // List all entities (files and directories) in the application support directory
      List<FileSystemEntity> entities = await dir.list().toList();

      // Iterate through each entity and delete it
      for (FileSystemEntity entity in entities) {
        if (entity is Directory) {
          await entity.delete(recursive: true);
        } else if (entity is File) {
          await entity.delete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  
  Future<void> downloadModelFiles(String name, String repoID, String directory) async {
    Directory localDir = await getApplicationSupportDirectory();
    final listURL = Uri.parse('https://huggingface.co/api/models/$repoID/tree/main/$directory');
    final baseURl = 'https://huggingface.co/$repoID/resolve/main';

    print(listURL);

    try {
      final response = await http.get(listURL);
      print(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);

        final filePaths = jsonResponse
            .where((item) => item['type'] == 'file')
            .map((item) => item['path'] as String)
            .toList();

        final dirPaths = jsonResponse
            .where((item) => item['type'] == 'directory')
            .map((item) => item['path'] as String)
            .toList();

        // Download files in the current directory
        for (final path in filePaths) {
          final savePath = '${localDir.path}/$name/$path';
          Uri downloadURL = Uri.parse('$baseURl/$path');
          print('Download URL: $downloadURL');

          await downloadFile(downloadURL, savePath);
        }

        // Recursively download files in subdirectories
        for (final dirPath in dirPaths) {
          await downloadModelFiles(name, repoID, dirPath);
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> downloadFile(Uri url, String savePath) async {
    final request = http.Request('GET', url);
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      // Get the total file size (if available)
      final contentLength = streamedResponse.contentLength;
      final file = File(savePath);
      final sink = file.openWrite();

      int bytesDownloaded = 0;

      // Listen to the stream and write to the file
      streamedResponse.stream.listen(
        (List<int> chunk) {
          // Write the chunk to the file
          sink.add(chunk);

          // Update the progress
          bytesDownloaded += chunk.length;
          if (contentLength != null) {
            final progress = (bytesDownloaded / contentLength * 100).toStringAsFixed(2);
            print('Download progress: $progress% ($bytesDownloaded/$contentLength bytes)');
          } else {
            print('Downloaded $bytesDownloaded bytes');
          }
        },
        onDone: () {
          // Close the file
          sink.close();
          print('Download completed: $savePath');
        },
        onError: (error) {
          // Handle errors
          sink.close();
          print('Download failed: $error');
        },
        cancelOnError: true,
      );
    } else {
      print('Failed to download: ${streamedResponse.statusCode}');
    }
  }

  Future<List<HuggingFaceModel>?> search(String search) async {
    String? huggingFaceToken = dotenv.env['HF_KEY'];
    String encodedSearch = Uri.encodeComponent(search);
    
    Uri searchURL = Uri.parse(
      "https://huggingface.co/api/models?search=$encodedSearch&limit=20&full=true&config=true"
    );

    final response = await http.get(
      searchURL,
      headers: {"Authorization": "Bearer $huggingFaceToken"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);

      return jsonResponse.map((model) => HuggingFaceModel.fromJson(model)).toList();
    } else {
      return null;
    }
  }
}
