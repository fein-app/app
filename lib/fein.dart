class Message {
  bool sender;
  DateTime date;
  String message;

  Message({required this.sender, required this.date, required this.message});

  factory Message.fromJSON(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      date: DateTime.parse(json['date']), 
      message: json['message']);
  }

  Map<String, dynamic> toJSON() {
    return {
      'sender': sender,
      'date': date.toIso8601String(),
      'message': message,
    };
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
