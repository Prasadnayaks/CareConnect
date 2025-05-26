// lib/core/app_config.dart
class AppConfig {
  // Replace with your computer's local IP address if testing on a physical device
  // Or use 'localhost' or '127.0.0.1' if testing on an emulator/simulator on the same machine
  // Ensure the port matches your FastAPI server (default 8000)
  static const String webSocketUrl =
      'ws://localhost:8000/ws/v1/careconnect_chat';
  // Example for local IP:
  // static const String webSocketUrl = 'ws://192.168.1.100:8000/ws/v1/careconnect_chat';
}
