import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);
  
  static const Color secondary = Color(0xFF8BC34A);
  static const Color secondaryDark = Color(0xFF689F38);
  static const Color secondaryLight = Color(0xFFAED581);
  
  static const Color important = Color.fromARGB(255, 206, 0, 0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFBF0); // Beige cálido agrícola
  static const Color cardHover = Color(0xFFFFF8E1); // Beige más claro en hover
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);
  
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Colores vitales (datos de salud)
  static const Color healthNormal = Color(0xFF4CAF50);
  static const Color healthWarning = Color(0xFFFF9800);
  static const Color healthCritical = Color(0xFFF44336);
  
  static const Color farmGreen = Color(0xFF66BB6A);
  static const Color soilBrown = Color(0xFF8D6E63);
  static const Color skyBlue = Color(0xFF64B5F6);
  static const Color sunYellow = Color(0xFFFFD54F);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
