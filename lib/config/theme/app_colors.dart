import 'package:flutter/material.dart';

/// Paleta «Revelado». Usar SIEMPRE a través de Theme / AppPalette, nunca directamente en widgets.
class AppColors {
  // Claro
  static const accent = Color(0xFF5146E5); // acción principal
  static const accentInk = Color(0xFF3B31C4); // texto/icono violeta sobre fondo claro
  static const accentSoft = Color(0xFFECEBFD); // fondos violeta suaves, pastilla activa nav
  static const accentAlt = Color(0xFF6C63F2); // segundo tono del logo
  static const ink = Color(0xFF131318); // texto principal
  static const ink2 = Color(0xFF5A5A66); // texto secundario (contraste AA sobre blanco)
  static const ink3 = Color(0xFF8A8A96); // solo iconos/placeholder, nunca texto importante
  static const background = Color(0xFFF7F7F9); // fondo de pantalla
  static const surface = Color(0xFFFFFFFF); // tarjetas, hojas
  static const surface2 = Color(0xFFEFEFF3); // campos, chips, botones neutros
  static const line = Color(0xFFE4E4EA); // divisores, bordes
  static const lineSoft = Color(0xFFEFEFF3); // divisores dentro de tarjetas

  // Estados
  static const review = Color(0xFFF5A524); // por revisar (punto, contador)
  static const reviewInk = Color(0xFF8A4B00);
  static const reviewSoft = Color(0xFFFFF3DF);
  static const reviewIcon = Color(0xFFC47A00);
  static const safe = Color(0xFF17885C); // a salvo / éxito
  static const safeInk = Color(0xFF0F6544);
  static const safeSoft = Color(0xFFE5F5EE);
  static const danger = Color(0xFFD23A3A); // borrar / error
  static const dangerInk = Color(0xFFA62626);
  static const dangerSoft = Color(0xFFFDECEC);

  // Oscuro (mismos roles)
  static const darkBackground = Color(0xFF0E0E12);
  static const darkSurface = Color(0xFF18181F);
  static const darkSurface2 = Color(0xFF24242C);
  static const darkLine = Color(0xFF2E2E38);
  static const darkInk = Color(0xFFF2F2F5);
  static const darkInk2 = Color(0xFFB9B9C4);
  static const darkAccent = Color(0xFF8E86FF);
  static const darkAccentSoft = Color(0xFF26234D);
  static const darkAccentAlt = Color(0xFFB3ADFF);
  static const darkDanger = Color(0xFFFF8A8A);
}
