# REDESIGN.md — Photo Manager · estilo «Revelado»

Documento de traspaso para aplicar el rediseño visual y funcional a esta app Flutter.
Está escrito para que **Claude Code** (u otra persona) lo ejecute fase a fase dentro del repositorio.

---

## 0. Cómo usar este documento

**Instrucciones para Claude Code:**

1. Trabaja en una rama nueva: `git checkout -b redesign/revelado`. No toques `main`.
2. Ejecuta **una fase cada vez** (sección 10). Al terminar cada fase:
   - `flutter pub get`
   - `flutter gen-l10n` (si se tocaron los `.arb`)
   - `flutter analyze` → sin errores nuevos
   - `flutter test` → actualiza los tests de widgets que dependan de textos/estructura cambiados; no borres tests sin sustituirlos
   - commit con mensaje `redesign(fase N): …`
3. **No modifiques** las capas `domain/` y `data/` salvo donde este documento lo indique explícitamente (sección 7). El rediseño es de `presentation/`, `core/widgets`, `core/navigation`, `config/theme` y `l10n`.
4. Ningún widget debe volver a usar colores fijos (`Colors.xxx`, `Color(0x…)`, `PhotoManagerColors.primary`). Todo sale de `Theme.of(context)` o de las extensiones de tema de la sección 2.
5. Todos los textos nuevos van en **ambos** `.arb` (`app_es.arb` es la plantilla).
6. Si algo del diseño no se puede hacer con los datos disponibles, aplica la alternativa de la sección 9 y no inventes datos.

**Referencia visual:** el lienzo de diseño «Photo Manager · Diseño actual y rediseño» (artefacto privado del propietario). Las medidas de este documento son las del lienzo.

---

## 1. Resumen del rediseño

- **Estilo «Revelado»**: claro y tranquilo, las fotos son las protagonistas. Neutros suaves y **un único violeta de marca** para la acción principal.
- **Un color = un significado**: violeta = acción · ámbar = «por revisar» · verde = «a salvo» · rojo = borrar.
- **Tipografía** Plus Jakarta Sans con 6 estilos. **Iconos** Material Symbols *Rounded* (rellenos solo en estado activo).
- **4 radios** (6 · 14 · 22 · pastilla) y espaciado en múltiplos de 4.
- **Navegación**: barra inferior flotante con 4 pestañas **con etiqueta**: Fotos · Álbumes · Copia · Perfil. Notificaciones deja de ser pestaña y pasa a ser «Actividad» dentro de Copia.
- **Logo nuevo** «Diafragma-nube» (carpeta `assets/branding/`).
- **Modo oscuro** soportado desde el tema.

---

## 2. Tokens de diseño

Crear `lib/config/theme/` con estos archivos y **eliminar** `photo_manager_colors.dart` al final de la fase 3 (cuando ya no se use).

### 2.1 `app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// Paleta «Revelado». Usar SIEMPRE a través de Theme / AppPalette, nunca directamente en widgets.
class AppColors {
  // Claro
  static const accent = Color(0xFF5146E5);        // acción principal
  static const accentInk = Color(0xFF3B31C4);     // texto/icono violeta sobre fondo claro
  static const accentSoft = Color(0xFFECEBFD);    // fondos violeta suaves, pastilla activa nav
  static const accentAlt = Color(0xFF6C63F2);     // segundo tono del logo
  static const ink = Color(0xFF131318);           // texto principal
  static const ink2 = Color(0xFF5A5A66);          // texto secundario (contraste AA sobre blanco)
  static const ink3 = Color(0xFF8A8A96);          // solo iconos/placeholder, nunca texto importante
  static const background = Color(0xFFF7F7F9);    // fondo de pantalla
  static const surface = Color(0xFFFFFFFF);       // tarjetas, hojas
  static const surface2 = Color(0xFFEFEFF3);      // campos, chips, botones neutros
  static const line = Color(0xFFE4E4EA);          // divisores, bordes
  static const lineSoft = Color(0xFFEFEFF3);      // divisores dentro de tarjetas

  // Estados
  static const review = Color(0xFFF5A524);        // por revisar (punto, contador)
  static const reviewInk = Color(0xFF8A4B00);
  static const reviewSoft = Color(0xFFFFF3DF);
  static const reviewIcon = Color(0xFFC47A00);
  static const safe = Color(0xFF17885C);          // a salvo / éxito
  static const safeInk = Color(0xFF0F6544);
  static const safeSoft = Color(0xFFE5F5EE);
  static const danger = Color(0xFFD23A3A);        // borrar / error
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
```

### 2.2 `app_palette.dart` (ThemeExtension)

`ColorScheme` no tiene hueco para todos los roles; usar una extensión:

```dart
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background, surface, surface2, line, lineSoft;
  final Color ink, ink2, ink3;
  final Color accent, accentInk, accentSoft;
  final Color review, reviewInk, reviewSoft, reviewIcon;
  final Color safe, safeInk, safeSoft;
  final Color danger, dangerInk, dangerSoft;
  // constructor, copyWith, lerp (lerp con Color.lerp campo a campo)
  static const light = AppPalette(/* valores claros de AppColors */);
  static const dark = AppPalette(/* valores oscuros; review/safe iguales; dangerInk = darkDanger */);
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
```

### 2.3 `app_spacing.dart` y `app_radius.dart`

```dart
class AppSpacing { // múltiplos de 4
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 20.0, xxl = 24.0, xxxl = 32.0;
  static const screenH = 20.0;   // margen lateral de títulos y cabeceras
  static const cardH = 16.0;     // margen lateral de tarjetas
  static const gridGap = 3.0;    // hueco entre miniaturas
}

class AppRadius {
  static const thumb = 6.0;      // miniaturas
  static const field = 14.0;     // campos, chips cuadrados, selector segmentado
  static const button = 16.0;    // botones grandes
  static const card = 22.0;      // tarjetas
  static const sheet = 28.0;     // hojas inferiores (esquinas superiores)
  static const pill = 999.0;     // pastillas, chips de filtro
}
```

### 2.4 `app_typography.dart`

Fuente: **Plus Jakarta Sans** vía `google_fonts` (o empaquetada en `assets/fonts` si se quiere evitar descarga en runtime; recomendado empaquetarla para producción).

| Rol | Uso | Tamaño / peso / tracking |
|---|---|---|
| `screenTitle` → `headlineMedium` | Título de pestaña («Fotos», «Copia») | 30 / w800 / -0.6 |
| `title` → `titleLarge` | Títulos de tarjeta, hojas («Todo a salvo») | 22 / w700 |
| `section` → `titleMedium` | Secciones («Hoy», «Actividad»), barras de pantalla secundaria (18/w800) | 17 / w700 |
| `body` → `bodyLarge` | Texto normal, filas de lista | 15 / w500 (filas: w700) |
| `label` → `labelLarge` | Botones pequeños, chips, etiquetas de campo | 13 / w700 |
| `note` → `bodySmall` | Metadatos («Hace 2 h · 412 MB») | 12 / w600 / color ink2 |

Etiquetas de la barra de navegación: 11 / w700 (activa w800). Etiquetas de sección en mayúsculas («COPIA Y ESPACIO»): 12 / w800 / tracking 0.7 / ink2.

### 2.5 `app_theme.dart`

```dart
class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppPalette.light);
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness b, AppPalette p) {
    final scheme = ColorScheme(
      brightness: b,
      primary: p.accent, onPrimary: Colors.white,
      primaryContainer: p.accentSoft, onPrimaryContainer: p.accentInk,
      secondary: p.accent, onSecondary: Colors.white,
      error: p.danger, onError: Colors.white,
      surface: p.surface, onSurface: p.ink,
      surfaceContainerHighest: p.surface2,
      onSurfaceVariant: p.ink2,
      outline: p.line, outlineVariant: p.lineSoft,
    );
    final text = GoogleFonts.plusJakartaSansTextTheme(/* aplicar tabla 2.4 */);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      textTheme: text,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(backgroundColor: p.background, surfaceTintColor: Colors.transparent,
          elevation: 0, scrolledUnderElevation: 0, centerTitle: false, foregroundColor: p.ink),
      filledButtonTheme: /* alto 54, radio 16, w700 15-16, fondo accent */,
      elevatedButtonTheme: /* igual que filled (por compatibilidad), elevation 0 */,
      outlinedButtonTheme: /* NO usar en pantallas nuevas; mapear a botón secundario */,
      textButtonTheme: /* texto w700, color accentInk */,
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: p.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.accent, width: 1.5)),
        errorBorder: /* danger 1.5 */, hintStyle: TextStyle(color: p.ink3),
      ),
      switchTheme: /* activo: track accent, thumb blanco; inactivo: track line, thumb blanco; sin borde */,
      chipTheme: /* pastilla, fondo surface2, seleccionado ink con texto blanco */,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surface, showDragHandle: true,
          dragHandleColor: p.line, shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)))),
      dialogTheme: /* radio 28, fondo surface */,
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: p.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent, linearTrackColor: p.accentSoft),
      dividerTheme: DividerThemeData(color: p.lineSoft, thickness: 1, space: 1),
    );
  }
}
```

En `main.dart` → `MaterialApp.router(theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.system, …)`.
`themeMode` debe poder cambiarse desde Perfil › Apariencia (guardar en `UiPreferencesService`).

---

## 3. Dependencias

Añadir en `pubspec.yaml`:

```yaml
dependencies:
  google_fonts: ^6.2.1            # o empaquetar Plus Jakarta Sans en assets/fonts
  material_symbols_icons: ^4.2800.0
  flutter_svg: ^2.0.10
```

Iconos: `Symbols.photo_library_rounded`, etc. Usar `fill: 1` solo en el estado activo/seleccionado.
Comprobar las versiones con `flutter pub outdated` y usar las últimas compatibles con el SDK del proyecto.

---

## 4. Logo e iconos de app

Copiar la carpeta `assets/branding/` de este paquete a la raíz del proyecto:

| Archivo | Uso |
|---|---|
| `logo_mark.svg` | Símbolo sobre fondo claro (login, splash, «Acerca de») |
| `logo_mark_dark.svg` | Símbolo sobre fondo oscuro |
| `logo_mark_white.svg` | Símbolo sobre el violeta de marca |
| `logo_mark_small.svg` | Versión simplificada para tamaños < 32 px (nube + hueco hexagonal) |
| `app_icon.png` (1024²) | Icono de app iOS / Android legacy (fondo violeta a sangre; iOS redondea solo) |
| `app_icon_foreground.png` (1024², transparente) | Primer plano del icono adaptativo de Android |
| `splash_logo.png` / `splash_logo_dark.png` (1024², transparentes) | Splash nativo claro / oscuro |

Los huecos entre láminas y el hexágono central son **transparentes** (máscara), así que los SVG funcionan sobre cualquier fondo.

**Logotipo horizontal** (no es un archivo; se compone en Flutter): `Row(símbolo, gap 10–22, Text)` con el texto `Photo` en `ink` + `Manager` en `accent`, Plus Jakarta Sans w800, tracking -3 %. Crear widget `AppLogo({double markHeight, bool showWordmark, AppLogoVariant variant})` en `lib/core/widgets/app_logo.dart` que elija el SVG según el brillo del tema.

`pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/branding/

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/branding/app_icon.png"
  adaptive_icon_background: "#5146E5"
  adaptive_icon_foreground: "assets/branding/app_icon_foreground.png"
  remove_alpha_ios: true

flutter_native_splash:
  color: "#F7F7F9"
  image: "assets/branding/splash_logo.png"
  color_dark: "#0E0E12"
  image_dark: "assets/branding/splash_logo_dark.png"
  android_12:
    color: "#F7F7F9"
    image: "assets/branding/splash_logo.png"
    color_dark: "#0E0E12"
    image_dark: "assets/branding/splash_logo_dark.png"
```

Después: `dart run flutter_launcher_icons` y `dart run flutter_native_splash:create`.
Los PNG antiguos (`photo_manager_logo*.png`) se pueden borrar cuando ya no se referencien.

---

## 5. Componentes compartidos

Crear en `lib/core/widgets/` (un archivo por componente). Todos leen colores de `context.palette` / `Theme`.

| Componente | Especificación |
|---|---|
| `AppButton` | Variantes `primary` (fondo accent, texto blanco), `secondary` (accentSoft / accentInk), `neutral` (surface2 / ink), `text` (transparente / ink), `danger` (dangerSoft / dangerInk). Alto 54 (grande) o 36 (pequeño, pastilla). Radio 16 (grande) / pill (pequeño). Icono opcional a la izquierda (20 px). Estado `loading` con `CircularProgressIndicator` 20 px. Estado deshabilitado = opacidad 0.45. |
| `AppTextField` | Etiqueta encima (13/w700, gap 6) + campo alto 52, fondo surface2, sin borde; enfocado: fondo surface, borde accent 1.5 y halo `BoxShadow(spread 4, accentSoft)`. Sufijo opcional (ojo de contraseña). Error: borde danger + texto 12/w600 dangerInk debajo. Sustituye a las 5 `InputDecoration` duplicadas. |
| `OtpField` | 6 casillas 60 alto, radio 14, fondo surface2, dígito 26/w800; casilla activa con borde accent + halo. Solo dígitos, pegar código completo, autoavance. |
| `FilterPill` / `FilterPillBar` | Alto 36, padding 14, radio pill. Seleccionada: fondo ink, texto blanco. No seleccionada: surface2 / ink. Contador opcional: círculo 20 px fondo `review`, texto 11/w800 `#3D2300`. Barra con scroll horizontal, gap 8, padding lateral 20. Sustituye `FilterChips` y `FolderFilterChips`. |
| `SegmentedControl<T>` | Contenedor alto 44, fondo surface2, radio 14, padding 4; segmento activo fondo surface, radio 10, sombra `0 1 3 rgba(19,19,24,.12)`, texto 14/w700; inactivos 14/w600 ink2. Animar el desplazamiento (200 ms). |
| `AppSwitch` | 50×30, track accent (on) / line (off), thumb blanco 24. Puede ser el `Switch` de Material con `switchTheme` (sin icono ni borde). |
| `AppCard` | Fondo surface, radio 22, sin sombra ni borde. Padding por defecto 16–18. |
| `SectionLabel` | Mayúsculas 12/w800/tracking 0.7/ink2, padding `fromLTRB(24, 22, 24, 8)`. |
| `ListRow` | Alto ~64, padding 14×16, icono 22 accent a la izquierda (gap 14), título 15/w700, subtítulo 12/w600 ink2, valor opcional a la derecha 13/w600 ink2, chevron ink3. Divisor `lineSoft` con indent 52 entre filas dentro de `AppCard`. Sustituye `ProfileMenuItem`. |
| `IconCircleButton` | 44×44, círculo surface2, icono 22. Para «volver», compartir, más opciones en pantallas secundarias. |
| `SecondaryTopBar` | Alto 64, padding 12: `IconCircleButton(arrow_back)` + título 18/w800 + acciones opcionales. Sustituye los `AppBar` de pantallas secundarias. |
| `ScreenHeader` | Título de pestaña 30/w800 a la izquierda, padding `fromLTRB(20, 20, 20, 0)`, acciones a la derecha. |
| `AppNavBar` | Barra flotante: margen 16 a los lados y abajo (+ safe area), alto 68, radio 24, fondo surface al 94 % con `BackdropFilter` blur 20, sombra `0 8 24 rgba(19,19,24,.12)` + borde 1 px `rgba(19,19,24,.05)`. 4 destinos: icono 22 + etiqueta 11/w700 ink2. Activo: pastilla 52×30 fondo accentSoft detrás del icono (relleno), color accentInk, etiqueta w800. El contenido de cada pestaña debe tener padding inferior suficiente (≈ 100) para no quedar tapado. |
| `MediaThumbnail` | Radio 6. Estados: **por revisar** = punto 12 px `review` con borde blanco 2 arriba-derecha; **vídeo** = pastilla abajo-derecha `rgba(0,0,0,.55)` con `play_arrow` 15 + duración 11/w700 blanco; **seleccionable** = círculo vacío 20 px borde blanco 2 arriba-derecha; **seleccionada** = anillo interior accent 3 px, imagen encogida 7 px (animado), `check_circle` relleno accent 24 sobre fondo blanco arriba-derecha. Sustituye `FileThumbnailCard` y `TrashFileCard` (este último añade la pastilla de días, sección 6.15). |
| `MediaGrid` | 3 columnas, gap 3, padding lateral 3. **La primera miniatura de cada grupo de fecha ocupa 2×2** (usar `SliverGrid` con `SliverQuiltedGridDelegate` de `flutter_staggered_grid_view`, o construir manualmente la primera fila). Cabecera de grupo: `section` («Hoy») + fecha corta 13/w600 ink2 («jue, 1 oct») + acción opcional a la derecha («Seleccionar»), padding `fromLTRB(20, 22, 20, 10)`. |
| `StatusChip` | Pastilla alta 36 (o 30), icono 18 + texto 13/w700. Variantes `safe` / `review` / `danger` / `neutral` con sus colores *Soft* de fondo e *Ink* de texto. |
| `AppSheet` | Helper `showAppSheet(context, child)` con el tema de hoja inferior; asa 40×5 color line; padding `fromLTRB(20, 12, 20, 28)`. |
| `AppDialog` | **Un solo** diálogo: radio 28, padding 24, icono opcional en círculo 48 de color *Soft*, título 20/w800, mensaje 15/w500 ink2, botones `AppButton` (acción principal a la derecha; destructiva en variante `danger`). Sustituye `ModernDialog`, `ErrorDialog`, el `AlertDialog` de cancelar sincronización y el diálogo de propiedades. Mantener la API de `ModernDialog.show` como *wrapper* para no romper llamadas. |
| `AppLogo` | Ver sección 4. |
| `EmptyState` | Icono 40 en círculo 80 surface2, título 17/w700, texto 14/w500 ink2 centrado, botón opcional. |

`ErrorDisplay`, `ErrorSnackBar` y `ErrorBanner` se mantienen funcionalmente pero se reestilizan con la paleta (snackbar flotante oscuro, radio 16).

---

## 6. Pantallas

Medidas base: pantalla 390×844. Fondo `background` salvo que se indique. Márgenes laterales: 20 en cabeceras, 16 en tarjetas.

### 6.1 Login — `features/auth/presentation/pages/login_page.dart` + `widgets/login/*`
- Sin AppBar. Padding superior 88 (incluye safe area), lateral 24. Fondo **surface (blanco)**.
- `AppLogo` en columna: símbolo alto 72 + debajo «Photo**Manager**» 22/w800. Gap 44.
- Título «Hola de nuevo» (30/w800), subtítulo «Entra para ver y ordenar tus fotos.» (15/w500 ink2). Gap 24.
- `AppTextField` correo. `AppTextField` contraseña con el enlace «¿La has olvidado?» alineado a la derecha **en la misma línea que la etiqueta**, y botón ojo.
- `AppButton.primary` «Entrar» (gap 24). Debajo, centrado: «¿Aún no tienes cuenta? **Crear cuenta**».
- **Sin mosaico ni imagen grande.** Quitar el logo de 180 px.

### 6.2 Registro — `register_page.dart` + `widgets/register/*`
- Mismo esquema que Login: `SecondaryTopBar` sin título (solo volver), título «Crea tu cuenta», subtítulo «Guarda tus fotos y libera espacio del móvil.».
- Campos: Nombre y Apellido **en la misma fila** (2 columnas, gap 12; apellido con «(opcional)» en ink2), correo, contraseña, confirmar contraseña.
- Aviso de términos 12/w600 ink2 sobre el botón «Crear cuenta». Debe caber sin scroll en 844 de alto.

### 6.3 Recuperar contraseña (3 pasos) — `request_password_reset_page.dart`, `validate_reset_code_page.dart`, `reset_password_page.dart`
- Estructura común: `SecondaryTopBar` (volver) + **indicador de pasos** a la derecha (3 barras 22×6, radio 3; completadas accent, pendientes line).
- Icono en cuadrado 56 radio 18 fondo accentSoft (paso 1 `lock_reset`, paso 2 `mark_email_unread`, paso 3 `password`), «Paso N de 3» 13/w700 ink2, título 30/w800, texto 15/w500 ink2.
- Paso 1 «¿Has olvidado tu contraseña?» + correo + «Enviar código».
- Paso 2 «Revisa tu correo» + «Te hemos enviado un código de 6 dígitos a **{email}**» + `OtpField` + «¿No te ha llegado? **Reenviar en 0:42**» (cuenta atrás de 60 s antes de habilitar reenviar) + «Verificar código» abajo (deshabilitado hasta 6 dígitos).
- Paso 3 «Crea una contraseña nueva» + nueva + confirmar + «Guardar contraseña».
- Botón principal anclado abajo (padding inferior 32).

### 6.4 Primer inicio / permisos — `features/onboarding/presentation/pages/onboarding_page.dart`
- **Sustituye la cadena de diálogos** (`WelcomePermissionDialog`, educación y denegación por permiso) por **una pantalla**:
  - «Bienvenido, {nombre}» 13/w700 accent · título «Tres permisos y empezamos» · texto «Así podremos guardar tus fotos de forma automática y avisarte cuando termine cada copia.»
  - 3 `AppCard` (padding 18), cada una: icono en cuadrado 48 radio 16, título 15/w700, descripción 13/w500 ink2, y a la derecha **estado**: botón pequeño «Permitir» (primary si es el siguiente recomendado, neutral el resto) o «✓ Listo» (safeInk) o «Ajustes» (si está denegado permanentemente → abre ajustes del sistema).
    1. Fotos y vídeos — «Para copiarlas y liberar espacio»
    2. Notificaciones — «Te avisamos al terminar o si falla»
    3. Segundo plano — «Copias con la app cerrada»
  - Nota con candado: «Tus fotos son privadas. Puedes cambiar estos permisos cuando quieras desde Perfil.»
  - Abajo: «Continuar» (primary) y «Hacerlo más tarde» (text).
- Lógica: reutilizar `PermissionHelper` para pedir **cada permiso por separado** al pulsar su botón. `OnboardingBloc`: añadir eventos por permiso y un estado con los tres flags; `PermissionsGranted`/`OnboardingCompleted` siguen igual. Si «Fotos» no está concedido al pulsar Continuar, mostrar `AppDialog` con las limitaciones (texto actual `onboardingPermissionsRejectedMessage`).

### 6.5 Shell y navegación — `core/navigation/main_shell.dart`, `app_router.dart`, `route_names.dart`
- `AppNavBar` con 4 destinos: **Fotos** (`photo_library`) · **Álbumes** (`photo_album`) · **Copia** (`cloud_sync`) · **Perfil** (`person`).
- Eliminar la rama `notifications` del `StatefulShellRoute` (y `NotificationsPage`); la ruta `/notifications` puede redirigir a `/sync`.
- Renombrar textos visibles: «Carpetas» → «Álbumes» en toda la app (las clases y rutas `folders` pueden mantenerse).
- La barra se oculta en: visor de archivo, visor de papelera, modo selección (la sustituye la barra de acciones, 6.7) y sincronización en curso a pantalla completa (si se mantiene).
- `main.dart`: mantener `immersiveSticky` solo si es una decisión de producto; con la barra flotante se recomienda `SystemUiMode.edgeToEdge` y barras del sistema transparentes.

### 6.6 Fotos (galería) — `features/gallery/presentation/pages/gallery_page.dart` + widgets
- `ScreenHeader` «Fotos». Acciones a la derecha:
  - `StatusChip` de copia: «Al día» (safe, icono `cloud_done`) / «Copiando 35 %» (accent) / «Copia con fallos» (danger). Al pulsarlo → pestaña Copia. Fuente: último estado de `SynchronizationBloc`/`SyncSessionBloc`.
  - Avatar 36 con iniciales (fondo accent) → Perfil.
- `FilterPillBar`: Todo · Fotos · Vídeos · **Por revisar** (con contador = `pendingCount`). Corregir «Videos» → «Vídeos».
- **Tarjeta «Por revisar»** (sustituye `PendingInfoBanner`; solo si `pendingCount > 0`): `AppCard` padding 14, icono `fact_check` en cuadrado 40 fondo reviewSoft, «{n} elementos por revisar» 14/w700, «Decide si guardarlos o liberar espacio del móvil» 12/w600 ink2, botón pequeño **neutral oscuro** «Revisar» (fondo ink). Al pulsar → abre la hoja «Gestionar» (6.8) con **todos los pendientes** (`ids` de los ficheros con `isPending`; si la paginación no los trae todos, aplicar el filtro `pending` y seleccionar todo).
- `MediaGrid` agrupado por fecha (reutilizar `DateGroupingUtil`). Cabecera «Hoy · jue, 1 oct · Seleccionar».
- Quitar el FAB. Pulsación larga o «Seleccionar» → modo selección.
- Estados vacío/error con `EmptyState` («Aún no hay fotos» · «Sincroniza tu móvil para verlas aquí» · botón «Hacer copia ahora»).

### 6.7 Fotos · modo selección
- Cabecera alto 72: botón cerrar (44) · «{n} seleccionadas» 20/w800 · botón pequeño neutral «Todas» / «Ninguna».
- Miniaturas en estado seleccionable/seleccionado (5).
- **Barra de acciones flotante** (sustituye barra de navegación + FAB «Gestionar»): mismo tamaño y posición que `AppNavBar`, fondo **ink** (oscuro), radio 24, padding 8. Línea superior 12/w600 `#B9B9C4`: «{n} fotos» (ver 9 para el tamaño). 4 botones 60 de alto, radio 16, icono 22 + etiqueta 11/w700:
  1. **Guardar** (fondo accent) → abre hoja Gestionar con la opción «Guardar y liberar espacio» preseleccionada.
  2. **A un álbum** (fondo `#24242C`) → abre hoja Gestionar con «Guardar en un álbum» preseleccionada.
  3. **Liberar** → `ManageAction(serverAction: save, keepOnDevice: false)` directo, con `AppDialog` de confirmación.
  4. **Eliminar** (texto `#FF8A8A`) → `AppDialog` destructivo → `ManageAction(serverAction: delete, keepOnDevice: false)`.

### 6.8 Hoja «¿Qué hacemos con estas fotos?» — `features/file_management/presentation/widgets/manage_file_modal.dart` (reescribir)
- Sustituye `QuickActionsSection`, `AdvancedOptionsSection` y la tarjeta «Mantener en dispositivo».
- Cabecera: pila de 3 miniaturas 40×40 (radio 10, borde blanco 2, solapadas -14) + título 20/w800 «¿Qué hacemos con estas {n} fotos?» (singular: «con esta foto») + subtítulo 13/w600 ink2 (ver 9).
- **3 opciones tipo radio** (tarjetas radio 20, padding 16, gap 10). Seleccionada: fondo `#F6F5FF` (claro) y anillo accent 2. No seleccionada: anillo line 1.5.
  1. **Guardar y liberar espacio** · etiqueta «Recomendado» · «Se guardan en tu nube y se borran del móvil.» → `save`, `keepOnDevice: false`
  2. **Guardar y mantener en el móvil** · «Tendrás una copia en la nube y otra aquí.» → `save`, `keepOnDevice: true`
  3. **Guardar en un álbum** · «Elige uno existente o crea uno nuevo.» → al seleccionarla se despliegan pastillas con los álbumes (`ManageFolderBloc`) + pastilla discontinua «+ Nuevo» (abre un campo inline para el nombre). → `folder` con `folderId`, o `newFolder` con `folderName`; `keepOnDevice` = **interruptor pequeño** «Borrar del móvil después» dentro de esta opción (por defecto activado).
- Botón principal con texto dinámico: «Guardar y liberar espacio» / «Guardar» / «Guardar en {álbum}».
- Debajo, botón de texto **rojo** «Eliminar de todas partes» (icono `delete`) → `AppDialog` destructivo → `delete`.
- Mantener intactos `_dispatchManageEvent`, los listeners de estado, `LocalDeletionWarningDialog` (reestilizado con `AppDialog`) y la gestión de éxito parcial.

### 6.9 Visor — `file_management/presentation/pages/file_detail_page.dart`
- Fondo negro. Barra superior sin fondo (con degradado negro 40 % → 0 detrás para legibilidad): `IconCircleButton` volver (fondo blanco 12 %) · columna «Hoy, 10:42» 15/w700 blanco + subtítulo 12/w600 blanco 70 % (tipo · duración si es vídeo) · pastilla «Por revisar» si `isPending` (fondo review 20 %, texto `#FFC766`, punto review) · botón `info` (abre propiedades).
- **Tira de miniaturas** encima de la barra inferior: 34×46 (actual 46×46 con borde blanco 2), opacidad 0.6 en no actuales; sincronizada con el `PageView`.
- **Barra de acciones inferior** flotante (margen 16, alto 72, radio 24, fondo `rgba(36,36,44,.9)`): Compartir · Favorita · **Guardar** (pastilla accent, abre hoja 6.8) · Eliminar (rojo claro). Compartir y Favorita: ver 9.
- Se oculta/aparece con un toque (sincronizado con los controles de `VideoPlayerWidget`).
- **Propiedades**: hoja `AppSheet` (no diálogo) con filas: Estado (StatusChip), Fecha de captura (fecha completa, no relativa), Duración (vídeos), Dispositivo de origen (si existe), ID (monoespaciada, botón copiar).
- Eliminar el menú `more_vert` con «Compartir/Descargar» vacíos.

### 6.10 Álbumes — `features/folders/presentation/pages/folders_page.dart` + `folder_card.dart`
- `ScreenHeader` «Álbumes» + botón pequeño primary «+ Nuevo».
- Buscador (campo 46, radio 14, surface2, icono search) — filtrado local por nombre.
- Rejilla 2 columnas, gap columnas 14, filas 18, padding 16. **Tarjeta de álbum**: portada cuadrada radio 22 con **mosaico 2fr/1fr** (1 grande + 2 pequeñas, gap 2) usando las primeras miniaturas; debajo nombre 15/w700 y «148 · 3 subálbumes» 12/w600 ink2. Sin portada: cuadrado surface2 con icono 36 ink3. Última celda: tarjeta discontinua «Crear álbum».
- Renombrar/Eliminar: pulsación larga → menú contextual (estilo del menú de 6.14). Quitar el botón `more_vert` visible.
- Hojas «Nuevo álbum» y «Renombrar»: `AppSheet` + `AppTextField` + botón principal; mismas validaciones.
- Ver 9: portadas.

### 6.11 Dentro de un álbum — `folder_content_page.dart`, `breadcrumbs_bar.dart`, `subfolders_section.dart`
- `SecondaryTopBar` con volver + acciones (compartir, más). Debajo: migas pequeñas 13/w700 ink2 («Álbumes › …» solo la ruta padre), título 28/w800, «148 elementos · ago 2024» 13/w600 ink2.
- **Subálbumes**: fila horizontal de tarjetas 112 de ancho (portada 84 alto radio 16 + nombre 13/w700 + número 11/w600), última tarjeta discontinua «Subálbum».
- `FilterPillBar` (Todo · Fotos · Vídeos) y `MediaGrid` igual que Fotos (cabecera por mes).
- Quitar el FAB «+»; crear subálbum desde la tarjeta discontinua o el menú «más».

### 6.12 Copia — `features/synchronization/presentation/pages/synchronization_page.dart` + widgets
- `ScreenHeader` «Copia».
- **Tarjeta de estado** (`AppCard`, padding 22×20, centrada) — sustituye `SynchronizationStatusCard` (quitar el degradado):
  - Anillo 116 px, grosor 8 (`CustomPainter` o `CircularProgressIndicator` con `strokeWidth`), con icono central en círculo 64 de color *Soft*.
  - Estados: **A salvo** (anillo safe completo, `cloud_done`, «Todo a salvo», «Última copia hace 2 h · {n} elementos»); **En curso** (anillo accent con % en el centro 28/w800, «Copiando 45 de 128», «Quedan unos 3 min · 210 MB por subir» — ver 9); **Con fallos** (anillo danger, `error`, «La última copia no terminó»); **Sin copias** («Aún no has hecho ninguna copia»).
  - Botón principal «Hacer copia ahora» (icono `sync`). En curso: «Pausar» (secondary) + «Cancelar» (neutral) — ver 9 para pausar.
  - Pastillas de condiciones (alto 30, surface2, icono 16 + 12/w700): «Diaria · 03:00», «Solo WiFi», «Cargando o >15 %», y un botón `tune` → Ajustes de copia. Datos de `SyncConfigBloc`.
  - En curso: tira de 5 miniaturas 54 alto (subidas con check, actual con borde accent y barra de progreso, pendientes al 45 %).
- **Actividad** (sustituye «Historial reciente» y la pestaña Notificaciones): título de sección + «Ver todo». `AppCard` con filas (icono en cuadrado 40 radio 14 color *Soft*):
  - Completada: `check` safe · «{n} elementos guardados» · «Hoy, 03:00»
  - Fallida/parcial: `error` danger · «Copia incompleta · {n} fallos» · botón pequeño secondary «Reintentar» (lanza nueva sesión)
  - Cancelada: `cancel` ink2 · «Copia cancelada»
  - En curso: `sync` accent
  - Mapear desde `SynchronizationStatus`. Fecha con `DateFormatter`.
- **Proceso en la misma pestaña**: `SyncSessionProcessPage` deja de ser una pantalla aparte; su estado (`SyncSessionBloc`) alimenta la tarjeta de estado. Mantener el diálogo de confirmación de cancelar (con `AppDialog`). Mensaje informativo bajo la tarjeta mientras copia: «Puedes salir de la app: la copia sigue en segundo plano y te avisaremos al terminar.» (solo si el permiso de segundo plano está concedido).
- Resultado final: en vez de pantalla de éxito, la tarjeta vuelve al estado «A salvo»/«Con fallos» y se muestra un snackbar «{n} elementos guardados».

### 6.13 Perfil — `features/profile/presentation/pages/profile_page.dart` + widgets
- `ScreenHeader` «Perfil».
- Fila de usuario: avatar 64 (foto o iniciales sobre accent) · nombre 18/w800 · email 13/w600 ink2 (**ya no en azul**) · botón pequeño neutral «Editar» → Editar perfil.
- `AppCard` Almacenamiento: «Almacenamiento» 15/w700 + «**12,4 GB** de 50 GB»; barra 10 px radio 5 (ver 9 para el desglose); fila de estadísticas en 3 columnas alineadas a la izquierda: «1.248 elementos», «12 álbumes», «3 dispositivos» (20/w800 + 12/w600 ink2). Sin divisores verticales.
- `SectionLabel` «COPIA Y ESPACIO» + `AppCard` con `ListRow`: Ajustes de copia («Diaria a las 03:00 · Solo WiFi»), Mis dispositivos («3 vinculados»), Papelera («Se vacía a los 30 días»).
- `SectionLabel` «APLICACIÓN» + `AppCard`: Notificaciones (valor: «Solo fallos» / «Todas» / «Desactivadas» → abre ajustes de copia, sección Avisos), Apariencia («Automática» / «Clara» / «Oscura» → `AppSheet` con 3 opciones), Contraseña (→ Editar perfil, sección contraseña).
- Botón danger «Cerrar sesión» (ancho completo) → `AppDialog` de confirmación.

### 6.14 Mis dispositivos — `features/devices/presentation/pages/devices_page.dart`, `device_card.dart`
- `SecondaryTopBar` «Mis dispositivos». Lista de `AppCard` (padding 16, gap 12). **Quitar la barra lateral de color y los degradados.**
- Tarjeta: icono en cuadrado 48 radio 16 (`smartphone` / `phone_iphone` / `tablet_android`; fondo accentSoft para el dispositivo actual, surface2 el resto) · nombre 15/w700 + etiqueta «Este móvil» (ver 9) · «Android 14» 12/w600 ink2 · botón `more_vert` → menú (radio 18, sombra) con «Renombrar» y «Desvincular» (rojo).
- Debajo, bloque `background` radio 16 con «Copia automática» 14/w700 + `AppSwitch`.
- Renombrar: `AppSheet` con campo (sustituye `RenameDeviceDialog`). Desvincular: `AppDialog` destructivo.

### 6.15 Papelera — `features/trash/presentation/pages/trash_page.dart` + widgets
- `SecondaryTopBar` «Papelera» + botón pequeño danger «Vaciar».
- Aviso (radio 16, surface2, icono `auto_delete`): «Se borran para siempre a los 30 días. Mantén pulsado para restaurar varios.»
- Agrupar: «Se borran pronto» (≤ 3 días, pastilla de días en **danger**) y «Este mes»/resto (pastilla `rgba(0,0,0,.55)`). Pastilla abajo-izquierda: «1 día», «12 días» (texto completo en vez de «12d»).
- Selección: barra de acciones flotante (como 6.7) con **Restaurar** (accent) y **Eliminar para siempre** (rojo). Sustituye `TrashActionButtons`.
- Visor de papelera: mismo patrón que 6.9 con acciones Restaurar / Eliminar para siempre y la pastilla «Se borra en 12 días».

### 6.16 Ajustes de copia — `features/sync_config/presentation/pages/sync_configuration_page.dart` + widgets
- `SecondaryTopBar` «Ajustes de copia». **Ningún componente Material sin tematizar** (nada de `Card`, `RadioListTile`, `FilterChip` por defecto).
- `AppCard` maestra: icono `cloud_sync` en cuadrado 44 accentSoft · «Copia automática» · «Tus fotos nuevas se guardan solas» · `AppSwitch`. Si está desactivada, el resto de secciones se muestra con opacidad 0.5 y no interactivo.
- `SectionLabel` «CUÁNDO» + `AppCard`: `SegmentedControl` «Cada día» / «Una vez por semana»; si semanal, selector de día con **7 casillas** (L M X J V S D, alto 40, radio 12; seleccionada accent con texto blanco); divisor; fila «Hora» con pastilla «03:00» (abre `showTimePicker` tematizado); nota «Próxima copia: sábado 3 oct a las 03:00» (calcular).
- `SectionLabel` «CONDICIONES» + `AppCard`: «Red» → `SegmentedControl` «Solo WiFi» / «WiFi y datos»; «Batería» → «Siempre» / «Cargando o >15 %».
- `SectionLabel` «AVISOS» + `AppCard`: «Al terminar bien» y «Si algo falla» con `AppSwitch`.
- Botón «Guardar cambios» **anclado abajo** (fondo background + línea superior). Habilitado solo si hay cambios.

### 6.17 Editar perfil — `features/profile/presentation/pages/edit_profile_page.dart` + widgets
- `SecondaryTopBar` «Editar perfil».
- Avatar 96 centrado con botón cámara (círculo 36 surface, sombra suave) + «Cambiar foto» (text). Elegir foto: `AppSheet` con «Galería» / «Cámara» (traducir el «Cámara» que está fijo en el código).
- `SectionLabel` «DATOS» + `AppCard` con Nombre / Apellido (`AppTextField`).
- `SectionLabel` «CONTRASEÑA» + `AppCard` con nota «Déjala en blanco si no quieres cambiarla» y los 3 campos.
- Botón «Guardar cambios» anclado abajo.

### 6.18 Estados de carga, vacío y error (global)
- Carga inicial de rejillas: **esqueleto** (rejilla de cuadrados surface2 con *shimmer* suave) en vez de `CircularProgressIndicator` centrado.
- Vacíos con `EmptyState` (textos de los `.arb` actuales, revisados en la sección 8).
- Éxitos: snackbar flotante oscuro (sustituye los `SnackBar` verdes).

---

## 7. Cambios de funcionamiento (resumen técnico)

| Cambio | Dónde | Notas |
|---|---|---|
| 4 pestañas, sin Notificaciones | `app_router.dart`, `main_shell.dart`, `route_names.dart` | Quitar la rama 3; reindexar. `NotificationsPage` se elimina. |
| Actividad en Copia | `synchronization_page.dart` | Construida con `SynchronizationBloc` (historial). No hay backend de notificaciones. |
| Proceso de sync dentro de la pestaña | `synchronization_page.dart`, `sync_session_process_page.dart`, widgets `sync_session_*` | Proveer `SyncSessionBloc` en la rama de Copia y escuchar sus estados en la tarjeta. Los widgets `sync_session_init/fetch/uploading/complete/success/error` se sustituyen por los estados de la tarjeta. |
| Barra de acciones en selección | `gallery_page.dart`, `folder_content_page.dart`, `trash_page.dart` | `MainShell` debe ocultar `AppNavBar` cuando la página activa esté en modo selección (exponer un `ValueNotifier<bool>` o un `SelectionModeCubit` compartido). |
| Hoja Gestionar simplificada | `manage_file_modal.dart` | Mismos `ManageAction`/`ServerAction`. Parámetro nuevo `initialOption` para preseleccionar desde la barra de selección. |
| «Por revisar» = pendientes | `gallery_page.dart`, `file_filter.dart`, `.arb` | Solo cambian los textos; `FileStatus.pending` no cambia. |
| Permisos en una pantalla | `onboarding_page.dart`, `onboarding_bloc.dart` | Eventos por permiso; estado con 3 flags. |
| OTP en casillas + cuenta atrás de reenvío | `validate_reset_code_page.dart` | Timer local en la página. |
| Apariencia (tema) | `ui_preferences_service.dart`, `main.dart`, Perfil | Guardar `ThemeMode` en SharedPreferences; `MyApp` escucha cambios. |
| Propiedades en hoja | `file_detail_page.dart`, `trash_file_detail_page.dart` | Extraer a widget compartido `FilePropertiesSheet`. |
| Renombrar/borrar álbum por pulsación larga | `folder_card.dart` | Mantener los mismos eventos de `FolderBloc`. |

---

## 8. Textos (l10n)

Añadir/cambiar en **`app_es.arb` y `app_en.arb`** y ejecutar `flutter gen-l10n`. Lista orientativa (claves nuevas en *camelCase*):

**Corregir:**
- `forgotPassword`: «¿La has olvidado?» (antes «¿Has olvidado tú contraseña?»)
- `synchronized`: «Sincronizado» (errata «Sicronizado»)
- `errorValidation`: «Los datos proporcionados son inválidos.» (sin tilde en «son»)
- `folders` y `foldersTitle`: «Álbumes» · `folder`: «Álbum» · `subfolders`: «Subálbumes»
- Filtro de vídeos: usar `l10n.videos` («Vídeos»); eliminar los textos fijos de `FileFilter.displayName` y localizarlos.
- `pendingPlural`: «Por revisar»

**Nuevas (es):**
- Navegación: `navPhotos` «Fotos», `navAlbums` «Álbumes», `navBackup` «Copia», `navProfile` «Perfil»
- Login: `loginGreeting` «Hola de nuevo», `loginSubtitle` «Entra para ver y ordenar tus fotos.», `noAccountYet` «¿Aún no tienes cuenta?», `createAccountLink` «Crear cuenta»
- Registro: `registerHeadline` «Crea tu cuenta», `registerSubtitle` «Guarda tus fotos y libera espacio del móvil.»
- Recuperar: `stepOf` «Paso {current} de {total}», `checkYourEmail` «Revisa tu correo», `resendIn` «Reenviar en {time}», `newPasswordHeadline` «Crea una contraseña nueva»
- Permisos: `welcomeUser` «Bienvenido, {name}», `permissionsHeadline` «Tres permisos y empezamos», `permissionsBody` …, `permPhotosTitle` «Fotos y vídeos», `permPhotosBody` «Para copiarlas y liberar espacio», `permNotifTitle` «Notificaciones», `permNotifBody` «Te avisamos al terminar o si falla», `permBgTitle` «Segundo plano», `permBgBody` «Copias con la app cerrada», `allow` «Permitir», `done` «Listo», `privacyNote` «Tus fotos son privadas. Puedes cambiar estos permisos cuando quieras desde Perfil.», `continueLabel` «Continuar», `later` «Hacerlo más tarde»
- Fotos: `backupUpToDate` «Al día», `backupInProgress` «Copiando {percent} %», `backupFailed` «Copia con fallos», `toReviewTitle` «{count, plural, =1{1 elemento por revisar} other{{count} elementos por revisar}}», `toReviewBody` «Decide si guardarlos o liberar espacio del móvil», `review` «Revisar», `select` «Seleccionar», `selectedCount` «{count, plural, =1{1 seleccionada} other{{count} seleccionadas}}», `all` «Todas», `none` «Ninguna»
- Acciones: `actionSave` «Guardar», `actionToAlbum` «A un álbum», `actionFreeUp` «Liberar», `actionDelete` «Eliminar», `share` «Compartir», `favorite` «Favorita»
- Gestionar: `manageQuestion` «{count, plural, =1{¿Qué hacemos con esta foto?} other{¿Qué hacemos con estas {count} fotos?}}», `optSaveFree` «Guardar y liberar espacio», `optSaveFreeBody` «Se guardan en tu nube y se borran del móvil.», `recommended` «Recomendado», `optSaveKeep` «Guardar y mantener en el móvil», `optSaveKeepBody` «Tendrás una copia en la nube y otra aquí.», `optAlbum` «Guardar en un álbum», `optAlbumBody` «Elige uno existente o crea uno nuevo.», `newAlbumChip` «Nuevo», `deleteAfterSaving` «Borrar del móvil después», `deleteEverywhere` «Eliminar de todas partes», `saveToAlbum` «Guardar en {album}»
- Álbumes: `searchAlbums` «Buscar álbumes», `newAlbum` «Nuevo», `createAlbum` «Crear álbum», `albumMeta` «{count} · {subcount} subálbumes», `emptyAlbum` «Vacío», `subalbum` «Subálbum»
- Copia: `backupTitle` «Copia», `allSafe` «Todo a salvo», `lastBackupMeta` «Última copia {when} · {count} elementos», `backupNow` «Hacer copia ahora», `copyingNofM` «Copiando {done} de {total}», `pause` «Pausar», `backupIncomplete` «La última copia no terminó», `noBackupsYet` «Aún no has hecho ninguna copia», `activity` «Actividad», `seeAll` «Ver todo», `itemsSaved` «{count} elementos guardados», `incompleteWithFailures` «Copia incompleta · {count} fallos», `backupCancelled` «Copia cancelada», `retry` (existe), `backgroundInfo` «Puedes salir de la app: la copia sigue en segundo plano y te avisaremos al terminar.», `condDaily` «Diaria · {time}», `condWeekly` «{day} · {time}», `condWifi` «Solo WiFi», `condAnyNetwork` «WiFi y datos», `condBattery` «Cargando o >15 %»
- Perfil: `edit` «Editar», `storageOf` «{used} de {total}», `elements` «elementos», `albums` «álbumes», `devicesLower` «dispositivos», `sectionBackupSpace` «COPIA Y ESPACIO», `sectionApp` «APLICACIÓN», `backupSettings` «Ajustes de copia», `linkedDevices` «{count} vinculados», `trashAutoEmpty` «Se vacía a los 30 días», `appearance` «Apariencia», `themeSystem` «Automática», `themeLight` «Clara», `themeDark` «Oscura», `notifOnlyFailures` «Solo fallos», `notifAll` «Todas», `notifOff` «Desactivadas», `password` «Contraseña», `logout` «Cerrar sesión»
- Dispositivos: `thisDevice` «Este móvil», `unlink` «Desvincular»
- Papelera: `emptyTrashShort` «Vaciar», `trashInfo` «Se borran para siempre a los 30 días. Mantén pulsado para restaurar varios.», `deletingSoon` «Se borran pronto», `thisMonth` «Este mes», `daysLeft` «{count, plural, =1{1 día} other{{count} días}}», `restore` (existe), `deleteForever` «Eliminar para siempre»
- Ajustes: `autoBackup` «Copia automática», `autoBackupBody` «Tus fotos nuevas se guardan solas», `sectionWhen` «CUÁNDO», `everyDay` «Cada día», `oncePerWeek` «Una vez por semana», `day` «Día», `time` «Hora», `nextBackup` «Próxima copia: {when}», `sectionConditions` «CONDICIONES», `network` «Red», `battery` «Batería», `always` «Siempre», `sectionAlerts` «AVISOS», `alertSuccess` «Al terminar bien», `alertSuccessBody` «Un aviso con lo que se guardó», `alertFailure` «Si algo falla», `alertFailureBody` «Para que puedas reintentarlo»
- Editar perfil: `camera` «Cámara» (hoy está fijo en el código), `sectionData` «DATOS», `sectionPassword` «CONTRASEÑA», `leavePasswordEmpty` «Déjala en blanco si no quieres cambiarla»

Eliminar del `.arb` las claves que queden sin uso al final (comprobar con búsqueda en `lib/`).

---

## 9. Datos que el diseño muestra y hoy no existen

| Dato del diseño | Situación actual | Qué hacer ahora | Qué haría falta |
|---|---|---|---|
| Tamaño de archivos («Ocupan 48 MB», «Liberar 48 MB», «210 MB por subir», «412 MB») | `GalleryFile` no tiene tamaño | Ocultar los MB: subtítulo «{n} fotos seleccionadas», botón «Guardar y liberar espacio» | Campo `sizeBytes` en la API de ficheros (y en la sesión de sync) |
| Desglose del almacenamiento (Fotos / Vídeos / Otros) | Solo `storageUsedMb` y `storageTotalMb` | Barra de un solo color (accent) sin leyenda | Uso por tipo en el endpoint de perfil |
| «Este móvil» en dispositivos | `Device` no indica el actual | Comparar `device.uuid` con el UUID local de `SyncDeviceLocalDataSource` (sí es posible en cliente) | — |
| Última copia por dispositivo | `Device` no tiene fecha | Mostrar solo «Android 14» | `lastSyncAt` en `Device` |
| Tiempo restante de la copia («Quedan unos 3 min») | No se calcula | Estimar con la media de tiempo por fichero ya subido; si < 3 ficheros, no mostrar | — |
| Pausar copia | No existe | Mostrar solo «Cancelar» | Soporte de pausa/reanudación en `SyncSessionBloc` |
| Favoritos | No existe (botón vacío) | **Quitar** el botón de la barra del visor | Endpoint de favoritos |
| Compartir | No implementado | Implementar con `share_plus` descargando el original a un temporal, o quitar el botón en esta fase | — |
| Portadas de álbum | `Folder` no trae miniaturas | Primera fila del contenido (petición extra) o icono de álbum sobre surface2 | `coverFileIds` (hasta 3) en el listado de carpetas |
| Fecha del álbum («ago 2024») | No existe | Omitir | Rango de fechas en `FolderContent` |
| Dispositivo de origen en propiedades | No existe en `GalleryFile` | Omitir la fila | `deviceName` en el fichero |

---

## 10. Fases y criterios de aceptación

**Fase 1 · Base visual** ✅
- [x] Dependencias (sección 3).
- [x] `AppColors`, `AppPalette`, `AppSpacing`, `AppRadius`, tipografía y `AppTheme` claro/oscuro (sección 2).
- [x] `main.dart` usa los temas; `themeMode` desde preferencias.
- [x] La app compila y se ve con la nueva fuente y colores sin tocar todavía las pantallas.

**Fase 2 · Logo e iconos** ✅
- [x] Assets de `assets/branding/` copiados y declarados.
- [x] `AppLogo` creado.
- [x] Iconos de app y splash regenerados (sección 4).

**Fase 3 · Componentes compartidos** ✅
- [x] Todos los widgets de la sección 5 en `lib/core/widgets/`.
- [x] `ModernDialog` reimplementado sobre `AppDialog` (misma API).
- [x] Ningún `Colors.`/`Color(0x` fuera de `config/theme/` (comprobar con `grep -rn "Colors\.\|Color(0x" lib --include=*.dart | grep -v config/theme`).
- [x] `photo_manager_colors.dart` eliminado.

**Fase 4 · Pantallas** (un commit por feature)
- [x] Acceso: 6.1, 6.2, 6.3
- [ ] Fotos: 6.6, 6.9 (sin cambios de funcionamiento todavía)
- [ ] Álbumes: 6.10, 6.11
- [ ] Copia: 6.12 (solo visual de tarjeta y lista)
- [ ] Perfil y ajustes: 6.13, 6.14, 6.15, 6.16, 6.17
- [ ] Estados globales: 6.18
- [ ] Textos de la sección 8.

**Fase 5 · Cambios de funcionamiento**
- [ ] Navegación de 4 pestañas (6.5)
- [ ] Selección con barra de acciones (6.7) + hoja Gestionar nueva (6.8)
- [ ] Tarjeta «Por revisar» → Gestionar con todos los pendientes
- [ ] Proceso de sync y Actividad dentro de Copia (6.12)
- [ ] Pantalla de permisos (6.4)
- [ ] Apariencia en Perfil
- [ ] Alternativas de la sección 9 aplicadas

**En cada fase:** `flutter analyze` limpio, `flutter test` en verde (actualizando los tests de widgets afectados: `login_page_test`, `login_actions_test`, `login_inputs_test`, `synchronization_page_test`, `synchronization_status_card_test`, `synchronization_list_item_test`, `empty_/error_synchronization_state_test`), y prueba manual en un dispositivo en modo claro y oscuro.

---

## 11. Accesibilidad (obligatorio)

- Áreas táctiles ≥ 44×44 (botones de icono, casillas de día, chips).
- Contraste: texto secundario siempre `ink2` (nunca `ink3`); texto sobre `accent` siempre blanco.
- `Semantics`/`tooltip` en todos los botones solo de icono (volver, más opciones, avatar, interruptores).
- Los colores de estado nunca van solos: siempre con icono o texto (punto «por revisar» + filtro con texto; pastillas de días con número).
- Respetar el tamaño de fuente del sistema: ninguna altura fija que corte texto con escala 1.3.
