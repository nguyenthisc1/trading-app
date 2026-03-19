import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme — TradingView-inspired palette
  static const Color darkBackground = Color(0xFF131722);
  static const Color darkSurface = Color(0xFF1E222D);
  static const Color darkCard = Color(0xFF2A2E39);
  static const Color darkBorder = Color(0xFF363A45);
  static const Color darkDivider = Color(0xFF2A2E39);

  // Light theme
  static const Color lightBackground = Color(0xFFF0F3FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F9FD);
  static const Color lightBorder = Color(0xFFE0E3EB);
  static const Color lightDivider = Color(0xFFE0E3EB);

  // Text
  static const Color darkTextPrimary = Color(0xFFD1D4DC);
  static const Color darkTextSecondary = Color(0xFF787B86);
  static const Color darkTextHint = Color(0xFF4C525E);
  static const Color lightTextPrimary = Color(0xFF131722);
  static const Color lightTextSecondary = Color(0xFF787B86);
  static const Color lightTextHint = Color(0xFFB2B5BE);

  // Semantic colors (same in both themes)
  static const Color bullish = Color(0xFF26A69A);  // green candle
  static const Color bearish = Color(0xFFEF5350);  // red candle
  static const Color bullishLight = Color(0xFF00897B);
  static const Color bearishLight = Color(0xFFD32F2F);

  // Brand
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color accent = Color(0xFF26A69A);

  // Indicators
  static const Color indicatorSma = Color(0xFF2196F3);
  static const Color indicatorEma = Color(0xFFFF9800);
  static const Color indicatorBbUpper = Color(0xFF9C27B0);
  static const Color indicatorBbLower = Color(0xFF9C27B0);
  static const Color indicatorRsi = Color(0xFF4CAF50);
  static const Color indicatorMacd = Color(0xFF2196F3);
  static const Color indicatorSignal = Color(0xFFFF5722);
  static const Color indicatorHistogram = Color(0xFF607D8B);
  static const Color volume = Color(0xFF455A64);

  // Sentiment
  static const Color sentimentBullish = Color(0xFF26A69A);
  static const Color sentimentBearish = Color(0xFFEF5350);
  static const Color sentimentNeutral = Color(0xFF787B86);

  // Chart overlay
  static const Color crosshair = Color(0xFF787B86);
  static const Color priceLabel = Color(0xFF2196F3);
}
