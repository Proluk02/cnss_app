// lib/core/constantes.dart

import 'package:flutter/material.dart';

// COULEURS PRINCIPALES
const Color kPrimaryColor = Color(0xFF1b4f72); // Bleu CNSS
const Color kSecondaryColor = Color(0xFF117a65); // Vert CNSS
const Color kAccentColor = Color(0xFFf39c12); // Orange/jaune
const Color kSuccessColor = Color(0xFF28b463); // Vert succès
const Color kErrorColor = Color(0xFFcb4335); // Rouge erreur
const Color kWarningColor = Color(0xFFf1c40f); // Jaune alerte
const Color kGreyText = Color(0xFF7b7b7b);
const Color kBackgroundColor = Color(0xFFf2f5fa); // Gris très clair
const Color kDarkText = Color(0xFF2C3E50);

// TYPOGRAPHIE
const double kFontSizeTitle = 22.0;
const double kFontSizeSubtitle = 16.0;
const double kFontSizeLabel = 14.0;

// RADIUS & PADDINGS
const double kCardRadius = 16.0;
const double kButtonRadius = 18.0;
const double kDefaultPadding = 20.0;
const double kFieldSpacing = 14.0;
const double kInputRadius = 12.0;

// SHADOWS
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x23000000), blurRadius: 8, offset: Offset(0, 4)),
];

// EXEMPLE DE GRADIENT
const LinearGradient kAppBarGradient = LinearGradient(
  colors: [kPrimaryColor, kSecondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// STYLE POUR CHARTS
const Color kLineChartColor = Color(0xFF1565C0);

// AUTRES (icônes, transitions...)
const Duration kAnimationFast = Duration(milliseconds: 200);

// EXEMPLE DE THEME POUR TEXT (à utiliser dans vos TextStyle)
const TextStyle kTitleStyle = TextStyle(
  fontSize: kFontSizeTitle,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const TextStyle kSubtitleStyle = TextStyle(
  fontSize: kFontSizeSubtitle,
  fontWeight: FontWeight.w500,
  color: Colors.black87,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: kFontSizeLabel,
  color: kGreyText,
);
