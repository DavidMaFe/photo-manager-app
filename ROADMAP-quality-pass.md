# Feature: Fase de calidad antes de los planes de pago

## Overview

Retoques detectados en el uso real, antes de empezar con las suscripciones de pago. Casi todo es de la app móvil; la Fase 7 (correos) es del backend (`photo-manager-server`).

1. El logo del splash sale cortado en Android.
2. La barra de acciones del visor de fotos debe integrarse con el propio visor (diseño en la captura del usuario).
3. Las notificaciones salen siempre en inglés.
4. Al abrir la app con la sesión iniciada se ve la pantalla de login durante unos milisegundos.
5. Tras aplicar una acción a una selección de archivos, la selección unas veces se desactiva y otras no.
6. En el carrusel de miniaturas del visor, el borde blanco de la foto actual se ve como cuatro líneas en las esquinas.
7. El usuario puede elegir el color de la app entre una selección controlada, que funcione en tema claro y oscuro.
8. Los correos de restablecer la contraseña y de cuenta eliminada empiezan con un espacio en blanco muy grande: ahí debe ir el logo.
9. Al ocultar los controles del visor, la foto o el vídeo pasan a pantalla completa con una animación, y vuelven a su hueco al mostrarlos (añadido tras la Fase 4).

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
- [x] Mantener el splash nativo hasta que se resuelva la sesión guardada y el onboarding: `main.dart` difiere el primer fotograma de Flutter (`deferFirstFrame`) y `StartupSplash` (`lib/core/navigation/startup_splash.dart`) lo suelta (`allowFirstFrame`) cuando el router tiene destino. Sin paquetes nuevos (`flutter_native_splash` sigue solo en `dev_dependencies`).
- [x] Con sesión, el router anima el cambio de login a la galería: el splash se suelta cuando termina esa transición (la de la plataforma: 450 ms en Android, la de Cupertino en iOS), así que el login no se ve ni a medias.
- [x] `AuthNotifier.isLoading` trata también `AuthInitial` como carga, para que `AppRedirect` no envíe a login antes de tiempo.
- [x] Si la comprobación falla o tarda, se quita el splash igualmente a los 5 s (sin quedarse colgado).
- [x] Tests: `StartupSplash` (6) y `AuthNotifier` con `AuthInitial`, `AuthLoading` y `NotAuthenticated` (3). `AppRedirect` no cambia.
- [x] Comprobar en el S23 en arranque en frío con sesión (directo a la galería) y sin sesión (directo a login).

**Criterio de aceptación:** con la sesión iniciada no se ve nunca la pantalla de login al abrir la app.

Resultado: grabaciones del arranque en frío en el S23, fotograma a fotograma: sin sesión, splash → login; con sesión (dos arranques), splash → galería sin ningún fotograma del login. 3045 tests y analizador sin avisos.

Status: ✅ Completed

## Phase 2: Idioma del móvil y notificaciones traducidas
- [x] Un único resolvedor de idioma, `AppLocale` (`lib/core/utils/app_locale.dart`): el primer idioma del móvil que tiene la app (es o en), inglés si no hay ninguno. Lo usan `MaterialApp` (`localeListResolutionCallback`), el `Accept-Language` de las peticiones y las notificaciones. Se quita el `locale` fijo.
- [x] `SyncNotificationService` toma sus textos de `AppLocalizations` en el idioma del móvil (`AppLocale.strings`, inyectable para los tests), también desde el isolate de WorkManager. Los canales se vuelven a crear con el nombre traducido en cada inicio.
- [x] Claves `notification*` en `app_es.arb` y `app_en.arb`: títulos, cuerpos con plurales, y nombres y descripciones de los canales («copia», como en el resto de la app).
- [x] La notificación de fallo ya no muestra el error técnico (`e.toString()`): dice que se reintentará, o que hay que volver a entrar si la sesión caducó. El detalle sigue en el log.
- [x] Revisar otros textos escritos a mano: solo estaba el panel de diagnóstico de la sincronización, que **se elimina** (decisión del usuario: las sincronizaciones ya funcionan bien). `SyncLogService` queda como traza en logcat y deja de guardar en el teléfono; `clear()` borra lo que guardaban las versiones anteriores.
- [x] Tests: `AppLocale` (7) y los textos de las notificaciones en los dos idiomas (7).
- [x] Comprobar en el S23 con la app en inglés y en español (`cmd locale set-app-locales`, sin tocar el idioma del teléfono): la interfaz, la notificación «Download completed» / «Descarga completada» y los nombres de los canales («Finished», «In progress», «Backup problems» / «Terminadas», «En curso», «Problemas con la copia»).

**Criterio de aceptación:** la app y las notificaciones salen en el idioma del móvil.

Resultado: 3059 tests y analizador sin avisos. En el S23 se descargó una foto en cada idioma y se borró después; la app vuelve al idioma del sistema.

Status: ✅ Completed

## Phase 3: La selección termina al aplicar una acción
- [x] Inventario de las acciones sobre una selección:
  - galería (`ManageSelectionBar`): Guardar, A un álbum (hoja), Descargar, Compartir, Eliminar y Liberar espacio (diálogo);
  - álbum: Favoritas, Portada, Mover (hoja), Eliminar, Descargar y Compartir;
  - papelera: Restaurar y Borrar para siempre (ya cumplían la regla: al terminar se recarga sin selección; si falla, se mantiene);
  - «Revisar» de la galería: selecciona ella misma los pendientes, así que la selección termina al cerrar la hoja, se aplique o no.
- [x] Regla única: éxito o éxito parcial → se desactiva la selección; cancelar o error → se mantiene. Descargar y Compartir terminan al pulsarlas.
- [x] **Causa del «unas veces sí y otras no»:** `RefreshGallery` y `RefreshFolderContent` guardaban la selección al empezar a recargar y la volvían a poner al terminar. Si la acción la cerraba mientras tanto y los archivos seguían en la lista (descargar, compartir, añadir a un álbum, favoritas…), la selección reaparecía. Ahora usan la selección del estado al terminar la petición.
- [x] `ManageSelectionBar`: la hoja de gestión devuelve si se aplicó algo (`ManageFileModal.show` → `true`), y solo entonces se llama a `onFinished`.
- [x] Favoritas en el álbum: la selección termina cuando se guarda (`FavoritesSaved`), no al pulsar; si falla, se mantiene. Portadas ya seguía la regla.
- [x] Tests: carrera de la recarga en `GalleryBloc` y `FolderContentBloc` (fallan sin el arreglo), y en `ManageSelectionBar` aplicar con la hoja, cerrar la hoja, cancelar la confirmación y fallar; favoritas guardadas y fallidas en el álbum.
- [x] Comprobar en el S23 cada acción (probado por el usuario: cerrar la hoja, añadir a un álbum, cancelar Eliminar, favoritas en un álbum, descargar y compartir).

**Criterio de aceptación:** toda acción aplicada termina la selección; cancelar o fallar la mantiene, en todas las pantallas.

Resultado: 3067 tests y analizador sin avisos.

Status: ✅ Completed

## Phase 4: Visor: barra de acciones integrada y borde del carrusel
- [x] Carrusel: el borde de la miniatura actual se dibuja por encima (`foregroundDecoration`), con el mismo radio, y se desvanece al cambiar de foto: es un rectángulo redondeado continuo, también en las esquinas.
- [x] Diseño de la captura del usuario (`~/cambios/Nuevo · Visor dentro de un álbum@1x.png`), con estas decisiones:
  - la parte de abajo deja de ser una barra flotante: `MediaViewerBottomPanel`, a todo lo ancho sobre el negro del visor, con una línea fina arriba, el carrusel y las acciones (icono y texto, sin pastillas de fondo);
  - álbum: Favorita · Portada (solo fotos) · Compartir · Descargar · Más (Mover, Eliminar), como en el diseño;
  - Favorita en rosa si la foto es favorita y Portada en el acento del visor (`mediaAccent`, nuevo en `AppPalette`) si la foto es portada de algún álbum; en blanco si no;
  - el mismo estilo en los visores de la galería y de la papelera; su acción principal (Guardar, Restaurar) va en `mediaAccent` en lugar de con una pastilla.
- [x] El espacio reservado bajo los vídeos sigue la altura del panel (con o sin carrusel).
- [x] Tests: carrusel (3), panel y colores de las acciones (5), y los del visor del álbum con las acciones nuevas (Mover dentro de Más, Portada activa e inactiva).
- [x] Comprobar en el S23 con fotos y vídeos, en modo claro y oscuro (revisado por el usuario).

**Criterio de aceptación:** la barra del visor coincide con el diseño de la captura y el borde de la miniatura actual es continuo, también en las esquinas.

Resultado: 3077 tests y analizador sin avisos.

Status: ✅ Completed

## Phase 5: Visor a pantalla completa
- [x] Con los controles visibles, la foto o el vídeo se ajustan al hueco entre la barra de arriba y el panel de abajo (sin que nada los tape); hoy ocupan toda la pantalla y el panel opaco tapa su parte de abajo.
- [x] Al ocultar los controles (un toque en la foto, o los controles del vídeo), la barra de arriba sube y el panel baja mientras se desvanecen, y a la vez la foto o el vídeo crecen hasta la pantalla completa (unos 250 ms, curva suave). Al mostrarlos, el camino inverso.
- [x] Un componente común para los visores de la galería, el álbum y la papelera (`MediaViewerLayout`), que mide la parte de arriba y el panel y anima el hueco alrededor del `PageView` (al pasar de foto se mantiene el modo; el zoom no se pierde).
- [x] Pantalla completa de verdad: se oculta también la barra de estado al ocultar los controles, y vuelve con ellos y al salir del visor.
- [x] El vídeo deja de reservar su propio espacio bajo los controles: usa el mismo hueco animado.
- [x] Tests de widget de `MediaViewerLayout` (7): hueco con controles, sin animación al abrir, crecimiento animado a pantalla completa, controles fuera de pantalla e ignorando toques, vuelta al hueco, y barra de estado al ocultar, al mostrar y al salir.
- [x] Al pasar de un archivo a otro se mantiene el modo (antes volvían siempre los controles). Las dos medidas (arriba y panel) se aplican juntas aunque lleguen en el mismo fotograma.
- [x] Comprobar en el S23 con fotos (también con zoom) y vídeos, al deslizar entre archivos y al salir del visor (probado por el usuario).

**Criterio de aceptación:** con controles nada tapa la foto; al ocultarlos la foto o el vídeo pasan a pantalla completa con una transición suave, y al mostrarlos vuelven a su hueco.

Resultado: 3084 tests y analizador sin avisos.

Status: ✅ Completed

## Phase 6: Color de la app
- [x] Familias de Morado, Azul, Turquesa, Terracota y Grafito para claro, oscuro y el visor (`lib/config/theme/app_accent.dart`), con el mismo contraste que el morado:
  - claro: texto blanco sobre el acento ≥ 4,5:1, y el texto del acento sobre el fondo y sobre su fondo suave ≥ 4,5:1;
  - oscuro: texto blanco sobre el acento ≥ 3:1 (el del morado; azul, turquesa y terracota se oscurecieron hasta igualarlo) y el acento sobre el fondo ≥ 4,5:1;
  - visor: acción activa y «Portada de…» sobre negro ≥ 7:1;
  - el tono de cada color se separa al menos 14° del verde, el ámbar, el rojo y el rosa de estado.
- [x] Modelo: enum `AppAccent` con sus `AccentColors`; `AppPalette.lightFor/darkFor` y `AppTheme.light/dark` se construyen con el color elegido (el morado devuelve la paleta base). Nuevo rol `brand` en la paleta: el «Manager» del logotipo sigue en el morado de la marca con cualquier color.
- [x] `UiPreferencesService.accent` (`SharedPreferences`, clave `app_accent`, morado si no hay nada o es desconocido); `MaterialApp` se reconstruye al cambiar el tema o el color.
- [x] Revisado que ningún widget use el morado sin pasar por la paleta: no hay colores fijos fuera del tema; solo el logotipo, que ahora usa `brand`.
- [x] Fila «Color de la app» en Perfil, debajo de Apariencia, y hoja con las cinco muestras (en el tono del tema actual): al tocar una se aplica al momento y la hoja sigue abierta para probar otra. Textos en `app_es.arb` y `app_en.arb`.
- [x] Tests: contraste de las cinco familias en claro, oscuro y visor, distancia a los colores de estado, paletas (acento, `brand` y estados), persistencia, hoja de colores y fila del perfil.
- [x] Comprobar en el S23 los cinco colores en claro y oscuro: galería, selección, visor, sincronización, perfil y diálogos (revisado y aprobado por el usuario).

**Criterio de aceptación:** el usuario puede elegir entre los cinco colores, se aplica en toda la interfaz al momento, se recuerda al reiniciar y todos se leen bien en claro y oscuro.

Resultado: 3127 tests y analizador sin avisos.

Status: ✅ Completed

## Phase 7: Logo en los correos (backend)
- [x] Rama `feature/email-logo` en `photo-manager-server`.
- [x] PNG del logo en blanco para correo (139 × 96 px, el doble del tamaño mostrado; generado desde `splash_logo.png`) en `src/main/resources/email/logo-white.png`.
- [x] El logo va **incrustado** en el correo (`cid:logo`, `MimeMessageHelper.addInline`), no enlazado a una URL.
- [x] Cabecera nueva y común para los dos correos (`EmailDataService#layout`): el logo y el título sobre el morado de la marca sólido (tabla con `bgcolor` y estilos en línea), sin degradado.
- [x] El pie ya no dice «no respondas a este correo»: invita a responder, porque las respuestas llegan a soporte (`Reply-To`).
- [x] Tests: `AutomaticEmailsApiTest` (E2E, solo se simula el servidor SMTP): los dos correos llevan el logo como PNG en línea y la cabecera con `bgcolor` sin degradados, y las respuestas van a soporte. 915 tests. Vista previa de los dos correos revisada antes de la PR.
- [x] PR del backend (https://github.com/DavidMaFe/photo-manager-server/pull/27), fusionada y desplegada en freya (`72a4757`).
- [x] Prueba en producción: código de restablecimiento revisado por el usuario en Gmail y en Outlook (claro y oscuro).

**Criterio de aceptación:** los dos correos empiezan con el logo y el título, sin hueco en blanco, en Gmail y Outlook.

Status: ✅ Completed

## Phase 8: Versión y prueba final
- [x] **Bug detectado por el usuario:** aparecía una y otra vez «1 guardado en el móvil» sin haber descargado nada. Causa: la cola de descargas se guarda en el teléfono y una descarga terminada se queda en ella; que la tarjeta se había cerrado solo se recordaba en memoria, así que cada arranque de la app la volvía a anunciar. Ahora `DownloadProgressBloc` solo anuncia el final de una descarga que esta ejecución de la app vio en marcha, empezó o canceló; las que ya habían terminado al abrirla no se muestran (de ellas ya avisa la notificación). Tests: no se anuncia al abrir (falla sin el arreglo), se anuncia la vista en marcha y la recién empezada.
- [x] Subir la versión a 1.2.1 (`1.2.1+4`).
- [x] Tests completos y analizador sin avisos (3130 tests).
- [ ] Commit, PR y, tras la aprobación, APK release con `--dart-define-from-file=config/prod.json` en el S23 (y el APK para el Realme).
- [ ] Prueba completa en el S23 contra producción de todos los cambios.
- [ ] Borrar este roadmap.

**Criterio de aceptación:** todos los cambios funcionan en producción.

Status: 🚧 In Progress
