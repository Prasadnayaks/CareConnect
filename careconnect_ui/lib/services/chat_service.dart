// lib/services/chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:careconnect_ui/models/chat_message_model.dart';
import 'package:careconnect_ui/core/app_config.dart';
import 'package:uuid/uuid.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ChatService with ChangeNotifier {
  WebSocketChannel? _channel;
  final List<ChatMessageModel> _messages = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String _errorMessage = '';
  final Uuid _uuid = const Uuid();
  bool _isModelTyping = false;

  List<ChatMessageModel> get messages => _messages;
  ConnectionStatus get connectionStatus => _connectionStatus;
  String get errorMessage => _errorMessage;
  bool get isModelTyping => _isModelTyping;

  ChatService() {
    // Optionally connect on initialization or provide a manual connect method
    // connect();
  }

  void connect() {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }

    _setConnectionStatus(ConnectionStatus.connecting);
    _errorMessage = '';
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConfig.webSocketUrl));
      _setConnectionStatus(ConnectionStatus.connected);
      _isModelTyping = false; // Reset typing indicator
      _messages.add(ChatMessageModel(
          id: _uuid.v4(),
          role: MessageRole.model,
          content: "Hello! I'm CareConnect. How are you feeling today?",
          timestamp: DateTime.now()));
      notifyListeners();

      _channel!.stream.listen(
        (data) {
          _isModelTyping =
              false; // Stop typing indicator once first chunk arrives
          final serverResponse =
              ServerResponseMessage.fromJson(jsonDecode(data as String));

          if (serverResponse.type == 'content') {
            if (_messages.isNotEmpty &&
                _messages.last.role == MessageRole.model) {
              // Append to the last model message
              _messages.last.content += serverResponse.data;
            } else {
              // Or create a new model message (shouldn't happen if server streams correctly after user msg)
              _messages.add(ChatMessageModel(
                id: _uuid.v4(),
                role: MessageRole.model,
                content: serverResponse.data,
                timestamp: DateTime.now(),
              ));
            }
          } else if (serverResponse.type == 'error') {
            _messages.add(ChatMessageModel(
              id: _uuid.v4(),
              role: MessageRole.model, // Or a special 'system_error' role
              content: "Error: ${serverResponse.data}",
              timestamp: DateTime.now(),
            ));
            _errorMessage = serverResponse.data;
          } else if (serverResponse.type == 'info') {
            _messages.add(ChatMessageModel(
              id: _uuid.v4(),
              role: MessageRole.model, // Or a special 'system_info' role
              content: "Info: ${serverResponse.data}",
              timestamp: DateTime.now(),
            ));
          }
          notifyListeners();
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _errorMessage = 'Connection error: $error';
          _setConnectionStatus(ConnectionStatus.error);
          _isModelTyping = false;
          notifyListeners();
        },
        onDone: () {
          print('WebSocket connection closed');
          _setConnectionStatus(ConnectionStatus.disconnected);
          if (_messages.isNotEmpty &&
              _messages.last.role == MessageRole.model &&
              _messages.last.content.isEmpty) {
            _messages.removeLast(); // Clean up empty typing message if any
          }
          _isModelTyping = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('WebSocket connection exception: $e');
      _errorMessage = 'Failed to connect: $e';
      _setConnectionStatus(ConnectionStatus.error);
      _isModelTyping = false;
      notifyListeners();
    }
  }

  void sendMessage(String query) {
    if (_channel == null || _connectionStatus != ConnectionStatus.connected) {
      _errorMessage = "Not connected to the server.";
      notifyListeners();
      // Optionally try to reconnect
      // connect();
      return;
    }

    // Add user message to UI immediately
    final userMessage = ChatMessageModel(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: query,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isModelTyping = true; // Start typing indicator
    // Add a placeholder for model's response or ensure last model message exists
    if (!(_messages.isNotEmpty &&
        _messages.last.role == MessageRole.model &&
        _messages.last.content.isEmpty)) {
      _messages.add(ChatMessageModel(
          id: _uuid.v4(), // Temporary ID for typing indicator message
          role: MessageRole.model,
          content: "", // Initially empty, will be filled by stream
          timestamp: DateTime.now()));
    }
    notifyListeners();

    // Prepare history for the server
    // Server expects history of previous user/model turns, not the current query
    List<Map<String, dynamic>> historyForServer = [];
    // Iterate up to the second to last message (don't include the current user query in history)
    for (int i = 0; i < _messages.length - (_isModelTyping ? 2 : 1); i++) {
      historyForServer.add(_messages[i].toJsonForServer());
    }

    final userInput = {
      'query': query,
      'history': historyForServer,
    };

    _channel!.sink.add(jsonEncode(userInput));
  }

  void _setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    if (status != ConnectionStatus.connected &&
        status != ConnectionStatus.connecting) {
      _isModelTyping = false;
    }
    notifyListeners();
  }

  void disposeConnection() {
    _channel?.sink.close();
    _setConnectionStatus(ConnectionStatus.disconnected);
    print("ChatService disposed, WebSocket connection closed.");
  }

  @override
  void dispose() {
    disposeConnection();
    super.dispose();
  }
}
