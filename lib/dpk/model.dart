import 'dart:ui';
import 'package:path/path.dart' as path;
import 'package:fein_app/fein.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class ModelExecUtils {

  Stream<String> generateResponse(Uri uri, List<Message> messages, String prompt) async* {
    List<Map<String, String>> apiMessages = messages.map((message) => message.toAPIFormat()).toList();

    try {
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'messages': apiMessages,
        'max_tokens': 4097,
        'temperature': 1.0,
        'stream': true
      });
      
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        String buffer = "";
        
        await for (var chunk in streamedResponse.stream.transform<String>(utf8.decoder)) {
          final lines = chunk.split('\n');
          
          for (final line in lines) {
            if (line.trim() == '[DONE]') {
              continue;
            }
            
            if (line.startsWith('data: ')) {
              final jsonString = line.substring(6).trim();
              if (jsonString.isNotEmpty) {
                try {
                  final jsonData = jsonDecode(jsonString);
                  final delta = jsonData['choices'][0]['delta'];
                  // Some APIs might not include 'content' in all chunks
                  final word = delta.containsKey('content') ? delta['content'] : '';
                  
                  if (word != null && word.isNotEmpty) {
                    buffer += word;
                    if (word.endsWith(" ") || word.endsWith("\n")) {
                      yield buffer.trim();
                      buffer = "";
                    }
                  }
                } catch (e) {
                  print('Failed to parse JSON: $e');
                }
              }
            }
          }
        }
        
        if (buffer.isNotEmpty) {
          yield buffer.trim();
        }
      } else {
        throw HttpException('HTTP error ${streamedResponse.statusCode}');
      }
    } catch (e) {
      yield "Error: $e";
    }
  }

  Future<Process?> startModel(String model, String modelPath) async {
    String appDir = Platform.resolvedExecutable;
    print(appDir);
    String llamaDir = path.dirname(appDir) + '\\llama-b4854-bin-win-avx2-x64';
    String build = llamaDir + '\llama-server.exe';

    try {
      // Start the llama-server process
      Process runningModel = await Process.start(
        build,
        ["-m", modelPath, "--port", "8080"],
        workingDirectory: llamaDir,
        environment: {
          "LD_LIBRARY_PATH": llamaDir, // Add the directory to LD_LIBRARY_PATH
        },
      );

      return runningModel;
    } catch (e) {
      throw Exception(e); // Handle any errors
    }
  }

  Future<void> stopProcess(Process currentRunningModel) async {
    currentRunningModel.kill();
    print("Stopped");
  }
}