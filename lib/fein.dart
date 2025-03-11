
class Message {
  bool sender;
  DateTime date;
  String message;
  String think;

  Message({required this.sender, required this.date, required this.message, required this.think});

  factory Message.fromJSON(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] == "user" ? true : false,
      date: DateTime.parse(json['date']), 
      message: json['message'],
      think: json['think']);
  }

  factory Message.fromBuffer(String buffer) {
    List<String> processed = Message.processThinkTags(buffer);
    return Message(
      sender: false,
      date: DateTime.now(),
      message: processed[0], 
      think: processed[1],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'sender': sender ? 'user' : 'system',
      'date': date.toIso8601String(),
      'message': message,
      'think': think,
    };
  }

  Map<String, String> toAPIFormat() {
    return {
      "role": sender ? "user" : "assistant",
      "content": message
    };
  }

  static List<String> processThinkTags(String content) {
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

class HuggingFaceModel {
  final String id;
  final String author;
  final int likes;
  final int trendingScore;
  final int downloads;
  final String libraryName;
  final String modelId;

  HuggingFaceModel({
    required this.id,
    required this.author,
    required this.likes,
    required this.trendingScore,
    required this.downloads,
    required this.libraryName,
    required this.modelId,
  });

  factory HuggingFaceModel.fromJson(Map<String, dynamic> json) {
    return HuggingFaceModel(
      id: json['id'] ?? "",
      author: json['author'] ?? "",
      likes: json['likes'] ?? 0,
      trendingScore: json['trendingScore'] ?? 0,
      downloads: json['downloads'] ?? 0,
      libraryName: json['library_name'] ?? "",
      modelId: json['modelId'] ?? "",
    );
  }
}

class Model {
  final String name;
  bool downloaded;
  Stream<double>? downloadStream;

  Model({required this.name, required this.downloaded, this.downloadStream});
}