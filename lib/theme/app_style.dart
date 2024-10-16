import 'package:flutter/material.dart';
import 'app_colors.dart';  // Import your colors here

class AppStyles {
  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Box Decorations
  static final BoxDecoration containerBoxDecoration = BoxDecoration(
    color: AppColors.primaryColor,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  );

  static final BoxDecoration cardBoxDecoration = BoxDecoration(
    color: AppColors.secondaryColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.borderColor),
  );

  // Add more styles as needed
}
