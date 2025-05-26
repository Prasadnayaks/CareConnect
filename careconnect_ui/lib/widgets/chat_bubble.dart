// lib/widgets/chat_bubble.dart
import 'package:careconnect_ui/models/chat_message_model.dart';
import 'package:careconnect_ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUserMessage = message.role == MessageRole.user;
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isUserMessage
              ? AppColors.userBubbleColor
              : AppColors.modelBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isUserMessage
                ? const Radius.circular(20.0)
                : const Radius.circular(4.0),
            bottomRight: isUserMessage
                ? const Radius.circular(4.0)
                : const Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.78, // Max width for bubbles
        ),
        child: SelectionArea(
          // Allows users to select and copy text from bubbles
          child: Text(
            message.content,
            style: GoogleFonts.lato(
              // Consistent font
              color: isUserMessage
                  ? AppColors.userBubbleTextColor
                  : AppColors.modelBubbleTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4, // Line height for readability
            ),
          ),
        ),
      ),
    );
  }
}
