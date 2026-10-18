# Feature: Fase de calidad antes de los planes de pago

## Overview

Retoques detectados en el uso real, antes de empezar con las suscripciones de pago. Casi todo es de la app móvil; la Fase 6 (correos) es del backend (`photo-manager-server`).

1. El logo del splash sale cortado en Android.
2. La barra de acciones del visor de fotos debe integrarse con el propio visor (diseño en la captura del usuario).
3. Las notificaciones salen siempre en inglés.
4. Al abrir la app con la sesión iniciada se ve la pantalla de login durante unos milisegundos.
5. Tras aplicar una acción a una selección de archivos, la selección unas veces se desactiva y otras no.
6. En el carrusel de miniaturas del visor, el borde blanco de la foto actual se ve como cuatro líneas en las esquinas.
7. El usuario puede elegir el color de la app entre una selección controlada, que funcione en tema claro y oscuro.
8. Los correos de restablecer la contraseña y de cuenta eliminada empiezan con un espacio en blanco muy grande: ahí debe ir el logo.

Decisiones tomadas:
- La app y las notificaciones siguen el **idioma del móvil**: español si el teléfono está en español, inglés en cualquier otro caso. Se quita el `locale: const Locale('es')` fijo de `main.dart`.
- Color de la app:
  - cambia **solo la interfaz**; el logo, el icono, el splash y los correos siguen en morado (la marca);
  - opciones: **Morado** (por defecto), **Azul**, **Turquesa**, **Naranja/terracota** y **Grafito**;
  - se guarda **en cada móvil**, como el tema claro/oscuro, sin cambios en el backend;
  - es **para todos**; si se limita a un plan, se decide en el roadmap de las suscripciones.
- La selección se desactiva **solo cuando la acción se aplica** (éxito o éxito parcial). Si se cancela (se cierra la hoja o el diálogo) o la acción falla, la selección se mantiene para reintentar o elegir otra acción.

Causas encontradas en el análisis:
- **Splash:** desde Android 12 el sistema recorta el icono del splash con una máscara circular (se ve el círculo central, unos 2/3 del lado). `assets/branding/splash_logo.png` (1024 px) tiene la nube ocupando casi todo el cuadro, así que se cortan los bordes.
- **Notificaciones:** los textos de `lib/core/services/sync_notification_service.dart` están escritos a mano en inglés (títulos, cuerpos y nombres de los canales). Parte se muestra desde el isolate de WorkManager, sin `BuildContext`.
- **Login:** el router arranca en `RoutePaths.login`, y `AppRedirect` no trata `AuthInitial` como carga: hasta que `CheckAuthStatus` responde, se pinta el login.
- **Carrusel:** en `lib/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart` el borde va en la `decoration` (debajo del hijo) y la miniatura se recorta con el radio exterior, así que en las esquinas la imagen tapa el borde.
- **Color:** todos los widgets toman los colores de `AppPalette` (`ThemeExtension`, `context.palette`). El morado es una familia por tema: `accent`, `accentInk`, `accentSoft`, `accentAlt`, `onAccent` y los tonos del visor `mediaCover`/`mediaCoverSoft` (claro), y `darkAccent`, `darkAccentSoft`, `darkAccentAlt` (oscuro). Verde (a salvo), ámbar (por revisar), rojo (eliminar) y rosa (favorita) ya tienen significado: los colores nuevos deben distinguirse de ellos.
- **Correos:** la cabecera de `EmailDataService` (backend) es un `linear-gradient` morado con el título en blanco. Gmail, Outlook y otros clientes ignoran los degradados de CSS, así que queda un bloque blanco con texto blanco: el espacio vacío.
- **Selección:** `ManageSelectionBar._openSheet` llama a `onFinished` al cerrar la hoja aunque no se haya hecho nada; los errores mantienen la selección; las portadas, las favoritas y la papelera siguen cada una su propio camino.

## Phase 0: Splash sin recortes en Android
- [x] Generar `assets/branding/android12_splash_logo.png` y `android12_splash_logo_dark.png` (1152 × 1152, fondo transparente) con el logo dentro del círculo seguro de Android 12 (diámetro ≈ 768 px; el logo dentro de ≈ 640 px para dejar margen).
- [x] Usarlas en `flutter_native_splash.android_12` del `pubspec.yaml` y regenerar los recursos (`dart run flutter_native_splash:create`).
- [x] Comprobar que el splash anterior a Android 12 y el de iOS siguen bien (mismo logo, centrado).
- [x] Comprobar en el S23, en modo claro y oscuro, que el logo se ve entero.

**Criterio de aceptación:** el logo del splash se ve entero y centrado en Android 12+ en los dos temas.

Resultado: imágenes generadas desde `splash_logo*.png` con todo el logo dentro de un círculo de 330 px de radio (el visible es de 384 px); el logo queda en 615 × 423 px. Android 11 o anterior e iOS no cambian (no recortan). En el S23 (Android 16), arranque en frío en claro y en oscuro: el logo se ve entero.

Status: ✅ Completed

## Phase 1: Sin destello de la pantalla de login al abrir la app
- [ ] Mantener el splash nativo (`FlutterNativeSplash.preserve`) hasta que se resuelva la sesión guardada y el onboarding, y quitarlo (`FlutterNativeSplash.remove`) en cuanto el router tenga destino.
- [ ] `AuthNotifier.isLoading` trata también `AuthInitial` como carga, para que `AppRedirect` no envíe a login antes de tiempo.
- [ ] Si la comprobación falla o tarda, se quita el splash igualmente (sin quedarse colgado) y se muestra login.
- [ ] Tests: `AppRedirect` con `AuthInitial`, `AuthNotifier`, y el arranque con y sin sesión.
- [ ] Comprobar en el S23 en arranque en frío con sesión (directo a la galería) y sin sesión (directo a login).

**Criterio de aceptación:** con la sesión iniciada no se ve nunca la pantalla de login al abrir la app.

Status: ⏳ Pending

## Phase 2: Idioma del móvil y notificaciones traducidas
- [ ] Un único resolvedor de idioma (es si el móvil está en español, en en cualquier otro caso), usado por `MaterialApp` y por las notificaciones. Se quita el `locale` fijo.
- [ ] `SyncNotificationService` obtiene sus textos de `AppLocalizations` (`lookupAppLocalizations`) con el idioma del móvil, también desde el isolate de WorkManager.
- [ ] Claves nuevas en `app_es.arb` y `app_en.arb` para los títulos, cuerpos (con plurales) y nombres y descripciones de los canales de notificación.
- [ ] Revisar que no queden otros textos visibles escritos a mano en inglés o español fuera de los ARB.
- [ ] Tests del resolvedor y de los textos de las notificaciones en los dos idiomas.
- [ ] Comprobar en el S23 con el móvil en español y en inglés: sincronización, descarga y error.

**Criterio de aceptación:** la app y las notificaciones salen en el idioma del móvil.

Status: ⏳ Pending

## Phase 3: La selección termina al aplicar una acción
- [ ] Inventario de todas las acciones sobre una selección: galería, álbum, papelera, favoritas y portadas.
- [ ] Regla única: éxito o éxito parcial → se desactiva la selección; cancelar o error → se mantiene.
- [ ] `ManageSelectionBar`: la hoja de gestión devuelve si se aplicó algo, y solo entonces se llama a `onFinished`.
- [ ] Papelera (restaurar y borrar para siempre), favoritas y portadas siguen la misma regla.
- [ ] Tests de widget y de BLoC de cada caso (aplicar, cancelar, fallar).
- [ ] Comprobar en el S23 cada acción.

**Criterio de aceptación:** toda acción aplicada termina la selección; cancelar o fallar la mantiene, en todas las pantallas.

Status: ⏳ Pending

## Phase 4: Visor: barra de acciones integrada y borde del carrusel
- [ ] Carrusel: el borde de la miniatura actual se dibuja por encima (`foregroundDecoration`) y la imagen se recorta con el radio interior, para que el borde sea un rectángulo redondeado continuo.
- [ ] Revisar la captura del usuario y concretar el diseño (posición, fondo, iconos, textos, comportamiento al ocultar los controles).
- [ ] Implementarla en el visor (`file_detail_page.dart`) y en el de la papelera si aplica.
- [ ] Tests de widget.
- [ ] Comprobar en el S23 con fotos y vídeos, en modo claro y oscuro.

**Criterio de aceptación:** la barra del visor coincide con el diseño de la captura y el borde de la miniatura actual es continuo, también en las esquinas.

Status: ⏳ Pending

## Phase 5: Color de la app
- [ ] Definir las familias de color de Morado, Azul, Turquesa, Naranja/terracota y Grafito, para claro y oscuro: contraste AA del texto y los iconos sobre sus fondos, y distintas de los colores de estado.
- [ ] Modelo: enum `AppAccent` y las familias por acento; `AppPalette.light/dark` y `AppTheme` se construyen a partir del acento elegido.
- [ ] `UiPreferencesService` guarda el acento (`SharedPreferences`) y lo expone como `ValueNotifier`, como `themeMode`; `MaterialApp` se reconstruye al cambiarlo.
- [ ] Revisar que ningún widget use el morado sin pasar por la paleta (colores fijos, `AppColors.accent` directo, SVG del logo fuera de la marca).
- [ ] Selector en Perfil (junto al tema claro/oscuro): muestras de los cinco colores, con la previsualización inmediata. Textos en `app_es.arb` y `app_en.arb`.
- [ ] Tests: familias completas y contraste, persistencia, tema construido con cada acento, y el selector.
- [ ] Comprobar en el S23 los cinco colores en claro y oscuro: galería, selección, visor, sincronización, perfil y diálogos.

**Criterio de aceptación:** el usuario puede elegir entre los cinco colores, se aplica en toda la interfaz al momento, se recuerda al reiniciar y todos se leen bien en claro y oscuro.

Status: ⏳ Pending

## Phase 6: Logo en los correos (backend)
- [ ] Rama en `photo-manager-server`.
- [ ] PNG del logo para correo (fondo transparente, ≈ 2× el tamaño mostrado; los clientes de correo no muestran SVG) en `src/main/resources/email/`.
- [ ] El logo va **incrustado** en el correo (imagen `cid:`, `MimeMessageHelper.addInline`), no enlazado a una URL: se ve sin cargar imágenes externas y no depende de nginx.
- [ ] Cabecera nueva de los dos correos (restablecer la contraseña y cuenta eliminada): el logo y el título sobre un fondo que todos los clientes muestran (color sólido, o el degradado con `background-color` de respaldo), y sin el hueco en blanco. Plantilla común para los dos.
- [ ] Tests E2E que siguen pasando; prueba manual enviando los dos correos a Gmail y Outlook (claro y oscuro).
- [ ] PR del backend y despliegue en freya tras la aprobación.

**Criterio de aceptación:** los dos correos empiezan con el logo y el título, sin hueco en blanco, en Gmail y Outlook.

Status: ⏳ Pending

## Phase 7: Versión y prueba final
- [ ] Subir la versión a 1.2.1.
- [ ] Tests completos y analizador sin avisos.
- [ ] Commit, PR y, tras la aprobación, APK release con `--dart-define-from-file=config/prod.json` en el S23 (y el APK para el Realme).
- [ ] Prueba completa en el S23 contra producción de todos los cambios.
- [ ] Borrar este roadmap.

**Criterio de aceptación:** todos los cambios funcionan en producción.

Status: ⏳ Pending
