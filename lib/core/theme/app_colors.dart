import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFF8C8DC); // Sakura Pink
  static const Color brandDark = Color(0xFF724B55); // Mauve tối (nút bấm)
  static const Color surfacePink = Color(0xFFFBE1EC); // Nền hồng nhạt
  static const Color secondary = Color(0xFFFFFFFF); // Porcelain White
  static const Color tertiary = Color(0xFFF5F5F7); // Light Gray

  static const Color accentMastered = Color(0xFF2E7D32); // Xanh lá đậm (Chữ & Icon Mastered)
  static const Color accentMasteredTrack = Color(0xFFE8F5E9); // Xanh lá nhạt (Nền Progress Bar)
  static const Color accentMiss = Color(0xFFFF9AA2); // Đỏ san hô nhẹ
  static const Color iconBackground = Color(0xFFF6F6F6); // Nền xám nhạt cho Icon Topic

  // Background Colors
  static const Color background = Color(0xFFF5F5F7); // Xám nhạt cho nền
  static const Color surface = Colors.white; // Màu nền của Card/Dialog (Trắng sứ)

  // Text Colors
  static const Color textPrimary = Color(0xFF333333); // Xám đen đậm
  static const Color textSecondary = Color(0xFF888888); // Xám nhạt
  static const Color textLight = Colors.white;

  // Semantic Colors (Trạng thái)
  static const Color success = accentMastered;
  static const Color error = accentMiss;
  static const Color warning = Color(0xFFFFDAC1);

  // Border & Divider
  static const Color border = Color(0xFFEBEBEB);
}