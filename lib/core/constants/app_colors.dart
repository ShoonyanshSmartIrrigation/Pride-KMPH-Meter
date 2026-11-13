import 'package:flutter/material.dart';

/// Centralized color palette matching the industrial instrument visual identity
/// as well as the ST7789 TFT display reference photograph.
class AppColors {
  AppColors._();

  // Primary Industrial Navy/Blue Palette
  static const Color primary = Color(0xFF1746A2);
  static const Color primaryDark = Color(0xFF0F3278);
  static const Color primaryLight = Color(0xFF4A7BD9);
  static const Color deepNavy = Color(0xFF142B49);
  static const Color navySurface = Color(0xFF1B365D);

  // Background & Surfaces
  static const Color surfaceLight = Color(0xFFF4F8FF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFD6E4FF);

  // Physical Instrument Display Theme (TFT Reference)
  static const Color instrumentBgLight = Color(0xFFDDF1FF);
  static const Color instrumentBgDark = Color(0xFF0D1B2A);
  static const Color instrumentBorder = Color(0xFF1746A2);
  static const Color instrumentBorderDark = Color(0xFF415A77);
  static const Color instrumentLabelDark = Color(0xFF142B49);
  static const Color instrumentLabelLight = Color(0xFFE0E1DD);

  // Speed Numerals (Exact match to specification)
  static const Color currentSpeed = Color(0xFFA020D5); // Purple / Magenta
  static const Color previousSpeed = Color(0xFFD72845); // Vivid Industrial Red
  static const Color timerText = Color(0xFF0866C9); // Precision Electric Blue
  static const Color timerYellow = Color(0xFFFFC107); // TFT Hardware Yellow Accent

  // Status Colors
  static const Color connected = Color(0xFF169B75); // Emerald Green
  static const Color measuring = Color(0xFFF59E0B); // Amber / Orange
  static const Color disconnected = Color(0xFF6B7280); // Slate Gray
  static const Color error = Color(0xFFDC2626); // Crimson Error

  // Dark Theme Accents
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF1C2742);

  // Modern Clean Theme (Reference UI Specification)
  static const Color modernNavyStart = Color(0xFF0A2E50);
  static const Color modernNavyEnd = Color(0xFF0D3D6A);
  static const Color modernBg = Color(0xFFF3F7FC);
  static const Color modernCardBg = Color(0xFFFFFFFF);
  static const Color modernCardBorder = Color(0xFFE5EEF7);
  static const Color modernTextDark = Color(0xFF0A2540);
  static const Color modernTextGrey = Color(0xFF6B7B8F);
  static const Color modernTextMuted = Color(0xFF8F9DAE);
  static const Color modernBlue = Color(0xFF0066FF);
  static const Color modernBlueDark = Color(0xFF0052D4);
  static const Color modernCyan = Color(0xFF00C6FF);
  static const Color modernGreen = Color(0xFF00C853);
  static const Color modernIconBg = Color(0xFFEBF4FE);
  static const Color modernPillBg = Color(0xFFDCEBFA);
}
