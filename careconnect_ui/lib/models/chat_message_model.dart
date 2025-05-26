// lib/models/chat_message_model.dart
import 'package:flutter/foundation.dart'; // For kDebugMode

enum MessageRole { user, model }

class ChatMessageModel {
  final String id; // For unique keys in lists
  final MessageRole role;
  String content; // Mutable to append streamed content
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  // For sending to server (part of UserInput.history)
  Map<String, dynamic> toJsonForServer() {
    return {
      'role': role.name, // 'user' or 'model'
      'content': content,
    };
  }

  // Not directly used for parsing server's ClientResponse,
  // as that has a different structure.
  // This is more for reconstructing from a saved history if implemented.
}

// Model for data coming FROM the server (matches server's ClientResponse)
class ServerResponseMessage {
  final String type; // "content", "error", "info"
  final String data;

  ServerResponseMessage({required this.type, required this.data});

  factory ServerResponseMessage.fromJson(Map<String, dynamic> json) {
    return ServerResponseMessage(
      type: json['type'] as String,
      data: json['data'] as String,
    );
  }
}
