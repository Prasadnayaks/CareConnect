// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:careconnect_ui/theme/app_colors.dart';
import 'package:careconnect_ui/pages/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'CareConnect Home',
          style: GoogleFonts.lato(
            color: AppColors.appBarTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0.5,
        centerTitle: true,
        // No back button needed if this is a primary navigation destination
        // If you want a drawer or other actions, they can be added here.
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.support_agent_rounded, // Or your app's main icon
                size: screenWidth * 0.3,
                color: AppColors.accentColor.withOpacity(0.8),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Ready to talk?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'CareConnect is here to listen and support you. Start a conversation whenever you need.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  color: AppColors.textColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white),
                label: Text(
                  'Start a New Chat',
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // You can add more elements here later, like:
              // - Quick links to resources
              // - Mood tracker (future feature)
              // - Previous conversation snippets (future feature)
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Your safe space for thoughts and feelings.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.textColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
