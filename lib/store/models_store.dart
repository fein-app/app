import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:fein_app/fein.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';


class ModelsStore {
  Future<List<Model>> getModels() async {
    Directory dir = await getApplicationSupportDirectory();
    
    List<FileSystemEntity> entities = dir.listSync();
    List<Model> modelNames = [];

    for (var entity in entities) {  
      if (entity is Directory) {  
        String dirName = path.basename(entity.path);
        bool downloaded = await checkDownloadStatus(dirName);
        modelNames.add(Model(name: dirName, downloaded: downloaded));
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

  Stream<double> createModel(String name, String repoID, {int bufferSize = 1024 * 1024}) async* {
    Directory dir = await getApplicationSupportDirectory();
    Directory newDir = Directory('${dir.path}/$name');
    Directory chatsSubdir = Directory('${dir.path}/$name/chats');

    if (!(await newDir.exists())) {
      await newDir.create();
      await chatsSubdir.create();
    }

    try {
      await for (var progress in ModelsStore().downloadModelFiles(name, repoID, "", bufferSize: 1024 * 1024)) {
      yield progress.streamedBytes / progress.contentSize;
    }
  } catch (e) {
    print('Error during download: $e');
  }
  }

  Stream<DownloadProgress> downloadModelFiles(
    String modelName,
    String repoID,
    String directory,
    {int bufferSize = 1024 * 1024}
  ) async* {
    Directory localDir = await getApplicationSupportDirectory();
    String savePath = '${localDir.path}/$modelName';
    final listURL = Uri.parse('https://huggingface.co/api/models/$repoID/tree/main/$directory');
    final baseURL = 'https://huggingface.co/$repoID/resolve/main';

    StreamGroup<DownloadProgress> progressStreamGroup = StreamGroup<DownloadProgress>();

    try {
      final response = await http.get(listURL);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        final filePaths = jsonResponse
            .where((item) => item['type'] == 'file')
            .map((item) => item['path'] as String)
            .toList();

        final dirPaths = jsonResponse
            .where((item) => item['type'] == 'directory')
            .map((item) => item['path'] as String)
            .toList();

        for (final path in dirPaths) {
          String fullDir = '$directory$path/';
          
          try {
            progressStreamGroup.add(downloadModelFiles(modelName, repoID, fullDir));  
          } catch (e) {
            print("Error calling subdirs: $e");
          }
        }

        // Download files in the current directory
        for (final filePath in filePaths) {
          String lastPath = path.basename(filePath);
          String save = '$savePath/$lastPath';
          Uri uri = Uri.parse("$baseURL/$filePath");

          try {
            progressStreamGroup.add(downloadFile(uri, save));
          } catch (e) {
            print('Error during download: $e');
          }
        }

        // Sum up all the progresses in the progressStreamGroup
        Map<String, DownloadProgress> progressMap = {};
        int totalContentSize = 0;
        int totalStreamedBytes = 0;
        await for (var progress in progressStreamGroup.stream) {
            if (!progressMap.containsKey(progress.file)) {
              totalContentSize += progress.contentSize;            
            }

            progressMap[progress.file] = progress;
            totalStreamedBytes += progress.streamedBytes;

            // Yield the combined progress
            yield DownloadProgress(
              contentSize: totalContentSize,
              streamedBytes: totalStreamedBytes,
              file: "",
            );
          }
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception('Error downloading file: $e');
    } finally {
      progressStreamGroup.close();

      try {
        final String folderPath = '${localDir.path}/$modelName';
        final Directory folder = Directory(folderPath);

        if (!await folder.exists()) {
          await folder.create(recursive: true);
        }

        final File finishedFile = File('$folderPath/finished.txt');
        await finishedFile.writeAsString('Download completed at ${DateTime.now().toIso8601String()}');
      } catch (e) {
        throw Exception('Error creating finished.txt file: $e');
      }
    }
  }


  Stream<DownloadProgress> downloadFile(Uri url, String savePath, {int bufferSize = 1024 * 1024}) async* {
    final request = http.Request('GET', url);
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final contentLength = streamedResponse.contentLength ?? 0;

      final file = File(savePath);
      final sink = file.openWrite();

      int bytesDownloaded = 0;
      List<int> buffer = [];

      await for (var chunk in streamedResponse.stream) {
        buffer.addAll(chunk);

        while (buffer.length >= bufferSize) {
          sink.add(buffer.sublist(0, bufferSize));
          buffer = buffer.sublist(bufferSize);
          bytesDownloaded += bufferSize;

          yield DownloadProgress(
            contentSize: contentLength,
            streamedBytes: bytesDownloaded,
            file: savePath,
          );
        }
      }

      if (buffer.isNotEmpty) {
        sink.add(buffer);
        bytesDownloaded += buffer.length;

        yield DownloadProgress(
          contentSize: contentLength,
          streamedBytes: bytesDownloaded,
          file: savePath,
        );
      }

      await sink.close();
    } else {
      throw Exception('Failed to download: ${streamedResponse.statusCode}');
    }
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

  Future<bool> checkDownloadStatus(String modelName) async {
    Directory dir = await getApplicationSupportDirectory();
    final String modelDir = '${dir.path}/$modelName';
    final File finishedFile = File('$modelDir/finished.txt');
    
    // Check if the finished.txt file exists
    return await finishedFile.exists();
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
class DownloadProgress {
  final int contentSize;
  final int streamedBytes;
  final String file;

  DownloadProgress({required this.contentSize, required this.streamedBytes, required this.file});
}
