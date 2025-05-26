// lib/main.dart
import 'package:careconnect_ui/pages/welcome_page.dart';
import 'package:careconnect_ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:careconnect_ui/services/chat_service.dart';
import 'package:careconnect_ui/pages/chat_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatService(),
      child: MaterialApp(
        title: 'CareConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            background: AppColors.backgroundColor,
            secondary: AppColors.accentColor,
          ),
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme.copyWith(
                  bodyLarge:
                      const TextStyle(color: AppColors.textColor, fontSize: 16),
                  bodyMedium: const TextStyle(
                      color: AppColors.textColor, fontSize: 16), // Default text
                  titleLarge: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold), // AppBar title
                ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors
                .primaryColor, // Or Colors.transparent if you want body color to show
            iconTheme: IconThemeData(color: AppColors.iconColor),
            titleTextStyle: TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputBackgroundColor,
            hintStyle: const TextStyle(color: AppColors.hintTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide:
                  const BorderSide(color: AppColors.accentColor, width: 1.5),
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.iconColor),
        ),
        home: const WelcomePage(),
      ),
    );
  }
}
