import 'package:flutter/material.dart';

/// Paleta «Revelado». Usar SIEMPRE a través de Theme / AppPalette, nunca directamente en widgets.
class AppColors {
  // Claro
  static const accent = Color(0xFF5146E5); // acción principal
  static const accentInk = Color(0xFF3B31C4); // texto/icono violeta sobre fondo claro
  static const accentSoft = Color(0xFFECEBFD); // fondos violeta suaves, pastilla activa nav
  static const accentAlt = Color(0xFF6C63F2); // segundo tono del logo
  static const onAccent = Color(0xFFFFFFFF); // texto/icono sobre accent o danger
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
  static const onReview = Color(0xFF3D2300); // texto sobre review (contador)
  static const safe = Color(0xFF17885C); // a salvo / éxito
  static const safeInk = Color(0xFF0F6544);
  static const safeSoft = Color(0xFFE5F5EE);
  static const danger = Color(0xFFD23A3A); // borrar / error
  static const dangerInk = Color(0xFFA62626);
  static const dangerSoft = Color(0xFFFDECEC);
  static const favorite = Color(0xFFE5466F); // corazón activo (visor, pastilla «Favoritas»)
  static const favoriteInk = Color(0xFFFF8FAB); // «Favorita» activa sobre la barra oscura del visor (claro y oscuro)
  static const coverBadgeBg = Color(0xEBFFFFFF); // rgba(255,255,255,.92), etiqueta «Portada» sobre miniaturas

  // Sombras
  static const shadow = Color(0x1F131318); // rgba(19,19,24,.12)
  static const shadowSoft = Color(0x0D131318); // rgba(19,19,24,.05), borde de la barra flotante
  static const darkShadow = Color(0x66000000);
  static const darkShadowSoft = Color(0x14FFFFFF);

  // Sobre fotos y vídeos (iguales en claro y oscuro)
  static const media = Color(0xFF000000); // fondo del visor
  static const onMedia = Color(0xFFFFFFFF); // texto/iconos sobre fotos
  static const scrim = Color(0x8C000000); // rgba(0,0,0,.55), pastillas sobre fotos
  static const mediaChrome = Color(0xE624242C); // rgba(36,36,44,.9), barras flotantes oscuras
  static const mediaChromeRaised = Color(0xFF24242C); // botones dentro de esas barras
  static const onMediaMuted = Color(0xFFB9B9C4); // texto secundario en esas barras
  static const mediaDanger = Color(0xFFFF8A8A); // «Eliminar» sobre fondo oscuro
  static const mediaReview = Color(0xFFFFC766); // «Por revisar» sobre fondo oscuro
  static const mediaCover = Color(0xFFD6D2FF); // «Portada de…» sobre fondo oscuro
  static const mediaCoverSoft = Color(0x3D8E86FF); // rgba(142,134,255,.24), su pastilla

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
  // Fondos *Soft* y textos *Ink* de estado en oscuro (contraste AA sobre su fondo)
  static const darkReviewSoft = Color(0xFF3A2C12);
  static const darkReviewInk = Color(0xFFFFC766);
  static const darkSafeSoft = Color(0xFF12322A);
  static const darkSafeInk = Color(0xFF6FD3A8);
  static const darkDangerSoft = Color(0xFF3D1C1F);
  static const darkFavorite = Color(0xFFFF5C85);
  static const darkCoverBadgeBg = Color(0xEB18181F); // rgba(24,24,31,.92)
}
