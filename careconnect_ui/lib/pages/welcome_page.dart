// lib/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:careconnect_ui/theme/app_colors.dart'; // Use your app's colors
import 'package:careconnect_ui/pages/chat_page.dart';

import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          AppColors.backgroundColor, // Or a specific welcome page background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // 8% of screen width
            vertical: screenHeight * 0.05, // 5% of screen height
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Placeholder for your logo/icon
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.psychology_alt_rounded, // Example Icon
                  size: screenWidth * 0.15, // Responsive size
                  color: AppColors.accentColor,
                ),
              ),
              const Spacer(flex: 2),
              // App Icon / Main Visual Element (Smaller, centered if preferred)
              Icon(
                Icons.support_agent_rounded, // Example Icon for CareConnect
                size: screenWidth * 0.25, // Responsive size
                color: AppColors.primaryColor,
              ),
              SizedBox(height: screenHeight * 0.03),

              Text(
                'Meet CareConnect,',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.075, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  height: 1.2,
                ),
              ),
              Text(
                'your empathetic AI companion.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.065, // Responsive font size
                  fontWeight: FontWeight.w500, // Slightly less bold
                  color: AppColors.textColor.withOpacity(0.8),
                  height: 1.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              Text(
                'From daily chats to exploring your feelings, CareConnect is your supportive space—always learning, always with you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04, // Responsive font size
                  color: AppColors.textColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  // UPDATE THIS LINE:
                  Navigator.pushReplacement(
                    // Use pushReplacement if you don't want WelcomePage in back stack
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HomePage()), // Navigate to HomePage
                  );
                },
                child: Text(
                  'Get Started',
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
