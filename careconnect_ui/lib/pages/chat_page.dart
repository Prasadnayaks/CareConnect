// lib/pages/chat_page.dart
import 'package:careconnect_ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:careconnect_ui/services/chat_service.dart';
import 'package:careconnect_ui/widgets/chat_bubble.dart';
import 'package:careconnect_ui/models/chat_message_model.dart'; // For MessageRole
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Observe lifecycle events for keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      if (chatService.connectionStatus == ConnectionStatus.disconnected &&
          chatService.connectionStatus != ConnectionStatus.connecting) {
        chatService.connect();
      }
      // Add listener to scroll when keyboard appears/disappears due to focus
      _inputFocusNode.addListener(_onFocusChange);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Could be used for reconnect logic if app is backgrounded and foregrounded
    if (state == AppLifecycleState.resumed) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      if (chatService.connectionStatus == ConnectionStatus.disconnected &&
          chatService.connectionStatus != ConnectionStatus.connecting) {
        // chatService.connect(); // Optional: auto-reconnect on resume
      }
    }
  }

  void _onFocusChange() {
    // If the input field gains focus (e.g., keyboard shown), scroll to bottom
    if (_inputFocusNode.hasFocus) {
      _scrollToBottom(
          delayMilliseconds: 350); // Increased delay for keyboard animation
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      chatService.sendMessage(_textController.text.trim());
      _textController.clear();
      // No need to requestFocus here as it might fight with keyboard dismissal if user taps away
      _scrollToBottom();
    }
  }

  void _scrollToBottom({int delayMilliseconds = 150}) {
    // Default delay
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
              const Duration(milliseconds: 400), // Slightly longer animation
          curve: Curves.easeOutQuad, // A slightly more pronounced easing
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    // Decide on ChatService connection lifecycle.
    // If you want it to disconnect when this page is popped:
    // Provider.of<ChatService>(context, listen: false).disposeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget is efficient for rebuilding parts of the UI
    // when ChatService notifies listeners.
    return Consumer<ChatService>(
      builder: (context, chatService, child) {
        // Schedule scroll to bottom after the build phase if new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (chatService.messages.isNotEmpty || chatService.isModelTyping) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            // Back button is automatically added by Flutter when pushed onto navigator stack
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.iconColor),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back to Home',
            ),
            title: Text(
              'CareConnect',
              style: GoogleFonts.lato(
                color: AppColors.appBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            backgroundColor: AppColors.backgroundColor,
            elevation: 0.8, // A bit more defined shadow
            centerTitle: true,
            actions: [
              Tooltip(
                message: chatService.connectionStatus.name.toUpperCase(),
                child: IconButton(
                  icon: Icon(
                    chatService.connectionStatus == ConnectionStatus.connected
                        ? Icons.wifi_rounded
                        : chatService.connectionStatus ==
                                ConnectionStatus.connecting
                            ? Icons.sync_rounded // Better icon for connecting
                            : Icons.wifi_off_rounded,
                    color: chatService.connectionStatus ==
                            ConnectionStatus.connected
                        ? AppColors.sendButtonColor
                        : chatService.connectionStatus == ConnectionStatus.error
                            ? AppColors.errorColor
                            : AppColors.iconColor.withOpacity(0.6),
                  ),
                  onPressed: () {
                    if (chatService.connectionStatus !=
                            ConnectionStatus.connected &&
                        chatService.connectionStatus !=
                            ConnectionStatus.connecting) {
                      chatService.connect(); // Attempt to reconnect
                    }
                  },
                ),
              ),
              const SizedBox(width: 8), // Spacing for the action button
            ],
          ),
          body: Column(
            children: [
              if (chatService.errorMessage.isNotEmpty &&
                  chatService.connectionStatus == ConnectionStatus.error)
                Container(
                  width: double.infinity,
                  color: AppColors.errorColor.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  child: Text(
                    chatService.errorMessage,
                    style: GoogleFonts.lato(
                        color: AppColors.errorColor, // Darker error text
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).unfocus(), // Dismiss keyboard
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        10.0, 10.0, 10.0, 0), // No bottom padding for list
                    itemCount: chatService.messages.length +
                        (chatService.isModelTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatService.isModelTyping &&
                          index == chatService.messages.length) {
                        return Align(
                          // Typing indicator
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: AppColors.modelBubbleColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(4.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0.5,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              "CareConnect is thinking...",
                              style: GoogleFonts.lato(
                                fontStyle: FontStyle.italic,
                                color: AppColors.typingIndicatorColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }
                      final message = chatService.messages[index];
                      // This condition might be redundant if ChatService handles empty model messages well
                      if (message.role == MessageRole.model &&
                          message.content.isEmpty &&
                          chatService.isModelTyping &&
                          index == chatService.messages.length - 1) {
                        // -1 because typing indicator adds one to itemCount
                        return const SizedBox.shrink();
                      }
                      return ChatBubble(message: message);
                    },
                  ),
                ),
              ),
              _buildTextComposer(), // The text input area
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border:
            Border(top: BorderSide(color: Colors.grey.shade300, width: 0.7)),
      ),
      child: SafeArea(
        // Ensures input field is not obscured by system UI like the home bar on iOS
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.inputBackgroundColor,
                    borderRadius: BorderRadius.circular(26.0), // More rounded
                    border:
                        Border.all(color: Colors.grey.shade300, width: 0.8)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.18, // Slightly more max height
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _inputFocusNode,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts here...',
                      hintStyle: GoogleFonts.lato(
                          color: AppColors.hintTextColor, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 14.0), // Adjusted padding
                    ),
                    style: GoogleFonts.lato(
                        fontSize: 16.5,
                        color: AppColors.textColor,
                        height: 1.45),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onEditingComplete:
                        _sendMessage, // Send on keyboard action if appropriate
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Material(
              color: AppColors.sendButtonColor,
              borderRadius: BorderRadius.circular(24.0),
              elevation: 1.0, // Subtle elevation
              child: InkWell(
                borderRadius: BorderRadius.circular(24.0),
                onTap: _sendMessage,
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(13.0), // Slightly larger tap area
                  child:
                      Icon(Icons.send_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
