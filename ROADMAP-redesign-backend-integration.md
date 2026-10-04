# Feature: Integración del backend del rediseño «Revelado»

## Overview

El rediseño visual está terminado (fases 1–5 de `REDESIGN.md`), pero varias pantallas usan las alternativas de la sección 9 porque faltaban datos. `photo-manager-server` ya expone esos datos (rama `feature/redesign-support`, y `feature/favoritas-portadas` para favoritas y portadas). Este roadmap sustituye cada alternativa por el dato real; las favoritas y las portadas elegidas siguen `FAVORITOS_PORTADAS.md` (fase 5).

Reglas comunes a todas las fases:
- Clean Architecture: entidad en `domain/entities`, modelo `fromJson`/`toJson` en `data/models`, caso de uso en `domain/use_cases`, registro en `core/injection_container.dart`.
- Los campos nuevos de la API son opcionales al parsear (`as T?` con valor por defecto), así la app sigue funcionando contra un backend sin desplegar.
- Textos nuevos en `app_es.arb` (plantilla) y `app_en.arb`, y después `flutter gen-l10n`.
- Sin colores fijos: todo sale de `Theme.of(context)` / `context.palette`.
- Tests en todas las capas: modelo (`fromJson` con y sin campos nuevos), data source (HTTP mockeado), repositorio, caso de uso, BLoC (`blocTest`) y widgets/páginas.
- Al terminar cada fase: `flutter analyze` limpio, `flutter test` en verde y commit `redesign-api(fase N): …`.

## Contratos de la API (referencia)

Todas las fechas llegan **en hora local del usuario y sin zona** (`2026-10-03T03:00:00`), y se parsean con `DateTime.parse` sin conversiones. La zona se envía en la cabecera `X-Timezone` (IANA, p. ej. `Europe/Madrid`); si falta o no es válida, el servidor usa `Europe/Madrid`. `capturedAt` es la hora local del móvil y nunca se convierte. Las fechas pueden ser `null`, incluido `capturedAt`.

| Endpoint | Campos nuevos o cambios |
| --- | --- |
| `GET /api/file/list/` | En cada fichero: `sizeBytes`, `isFavorite`, `durationSeconds` (la app lee la errata `durationSecionds`). Parámetro `favorite=true`, que también filtra `totalCount` y `totalPendingCount` |
| `GET /api/file/pending-ids/` | **Nuevo.** `{ "fileIds": [..], "totalSizeBytes": n }`, sin paginar; filtros opcionales `type` y `folder` |
| `GET /api/file/{fileId}/info/` | **Nuevo.** `id`, `originalFilename`, `type`, `status`, `mimeType`, `width`, `height`, `durationSeconds`, `sizeBytes`, `capturedAt`, `uploadedAt`, `deletedAt`, `isFavorite`, `folderId`, `folderName`, `deviceId`, `deviceName`. Fichero inexistente o de otro usuario → 400 `FILE_NOT_FOUND` |
| `POST /api/file/favorite/` | **Nuevo.** Body `{ "fileIds": [..], "favorite": true }` → `{ "updated": [..], "failed": [..] }`. Fija un valor (no alterna). Ficheros en la papelera, inexistentes o de otro usuario → `failed` |
| `GET /api/folder/list/` | `coverFileIds` (solo las portadas **elegidas**, 0–3, en orden), `fallbackCoverFileIds` (3 fotos más recientes del subárbol, solo si no hay elegidas), `hasCustomCovers`, `oldestCapturedAt`, `newestCapturedAt` |
| `GET /api/folder/{id}/` | Los mismos campos en `folderInfo` y en cada `subfolders[]`; `files` ordenados por `capturedAt DESC`, con `isFavorite` y `coverOf` (álbumes de los que el fichero es portada, de la raíz hacia abajo) en cada fichero |
| `GET /api/folder/{folderId}/covers/` | **Nuevo.** `{ "covers": [{ fileId, position, sourceFolderId, sourceFolderName, sourceFolderPath }] }`. `sourceFolderPath` es la ruta relativa al álbum como lista de nombres (`["Playa", "Atardeceres"]`; vacía si la foto está en el propio álbum) |
| `PUT /api/folder/{folderId}/covers/` | **Nuevo.** Body `{ "fileIds": [..] }` con el orden final (0–3, sin repetir); sirve para quitar y reordenar. Responde `{ "covers": [..] }` |
| `GET /api/file/{fileId}/cover-targets/` | **Nuevo.** Lista de la raíz a la carpeta directa: `[{ folderId, name, depth, containsDirectly, covers: [..] }]`. Foto sin álbum → `[]` |
| `PUT /api/folder/cover/batch/` | **Nuevo.** Body `{ fileId, changes: [{ folderId, action: "add" \| "remove" \| "replace", replaceFileId? }] }` → `{ "folders": [{ folderId, covers }] }`. Todo o nada |
| `GET` / `PUT /api/profile/` | `storage: { photosBytes, videosBytes, trashBytes, usedBytes, quotaBytes }`, donde `photosBytes + videosBytes + trashBytes = usedBytes`. `stats.fileCount` excluye la papelera |
| `GET /api/device/list/` | `lastSyncAt` con valor (fin de la última sesión completada) |
| `GET /api/sync_session/list/` | `completedAt`, `cancelledAt`, `totalSizeBytes` |

Regla de portadas (servidor):
- Una portada es una **foto** (los vídeos dan 400 `FOLDER_COVER_VIDEO_NOT_ALLOWED`) que no está en la papelera y está en el álbum o en cualquiera de sus subálbumes.
- `coverFileIds` no se rellena: con 1 portada elegida, el mosaico muestra 1 foto. Sin elegidas, la app usa `fallbackCoverFileIds`.
- Si una portada sale del árbol del álbum (se mueve, va a la papelera o se borra su carpeta), el servidor la borra y renumera las demás. Restaurarla no la devuelve.
- Errores 400: `FOLDER_NOT_FOUND`, `FOLDER_COVERS_LIMIT_EXCEEDED`, `FOLDER_COVER_DUPLICATED`, `FOLDER_COVER_FILE_NOT_VALID`, `FOLDER_COVER_VIDEO_NOT_ALLOWED`, `FOLDER_COVER_REPLACE_NOT_VALID`, `VALIDATION_ERROR`.
- Los IDs llegan como números en las respuestas; en las peticiones se aceptan números o texto.

## Phase 0: Base: zona horaria y modelo de fichero
- [x] Dependencia `flutter_timezone` para obtener el identificador IANA del dispositivo (requiere aprobación)
- [x] Servicio `TimezoneService` en `core/` que lee la zona una vez al arrancar y la cachea, con `Europe/Madrid` como valor por defecto si falla
- [x] Cabecera `X-Timezone` en todos los métodos de `HttpHeadersUtil` y en `AuthenticatedHttpClient` (también en multipart)
- [x] `GalleryFileModel`: leer `durationSeconds` (corrige la errata `durationSecionds`); los vídeos muestran su duración
- [x] `GalleryFile.capturedAt` nullable: el servidor puede enviar `null`. Revisar `DateGroupingUtil`, `FilePropertiesSheet` y las miniaturas para que no fallen
- [x] `GalleryFile.sizeBytes` (`int`, por defecto 0) en entidad, modelo y `copyWith`
- [x] Repasar los `DateTime.parse` de los modelos (`folder_model`, `trash_file_model`, `synchronization_model`, `sync_session_model`, `manage_folder_model`) para que acepten `null` donde la API lo permite
- [x] Tests: cabecera presente con zona válida y por defecto; `GalleryFileModel.fromJson` con duración, `sizeBytes` y `capturedAt` nulo; agrupación por fecha con `capturedAt` nulo

Acceptance criteria: todas las peticiones llevan `X-Timezone`; los vídeos de la galería muestran su duración; un fichero sin `capturedAt` no rompe la galería.

Status: ✅ Completed

## Phase 1: Copia y dispositivos
- [x] `Synchronization`: `completedAt`, `cancelledAt` (nullable) y `totalSizeBytes` en entidad y modelo
- [x] Actividad y tarjeta de estado: usar `completedAt` (o `cancelledAt`) como hora de la copia cuando exista, con `startedAt` como respaldo («Hoy, 03:00»)
- [x] Mostrar el tamaño de cada copia terminada en la lista de Actividad («412 MB»)
- [x] `Device.lastSyncAt` (nullable) en entidad y modelo
- [x] `DeviceCard`: «Android 14 · Última copia hoy, 03:00»; sin fecha, solo el sistema (comportamiento actual)
- [x] Textos nuevos en los `.arb`
- [x] `FileSizeFormatter` en `core/utils` (adelantado desde la fase 2, lo necesita el tamaño de la copia)
- [x] Tests: modelos con y sin campos nuevos; widgets de Actividad, tarjeta de estado y `DeviceCard`

Acceptance criteria: una copia completada muestra su hora de fin y su tamaño; cada dispositivo muestra la fecha de su última copia.

Status: ✅ Completed

## Phase 2: Revisar pendientes y liberar espacio
- [x] Data source y repositorio: `getPendingFileIds({FileType? type, String? folderId})` → entidad `PendingFiles { fileIds, totalSizeBytes }`
- [x] Caso de uso `GetPendingFileIdsUseCase`
- [x] `GalleryBloc._onReviewPendingFiles`: obtener todos los IDs en una llamada y seleccionarlos **sin el límite de `kMaxFileSelection`** (la selección manual mantiene el límite de 100). Cargar solo la primera página de ficheros para la cuadrícula
- [x] El estado de selección guarda el tamaño seleccionado: el `totalSizeBytes` de «Revisar», o la suma de `sizeBytes` en la selección manual (galería y contenido de álbum)
- [x] Hoja Gestionar: subtítulo «{n} fotos · ocupan {tamaño}» y botón «Liberar {tamaño}», en lugar de las alternativas sin MB
- [x] Utilidad de formato de bytes (`FileSizeFormatter`) en `core/utils`, reutilizada por las fases 1, 3 y 6 (hecha en la fase 1)
- [x] Tests: data source, caso de uso, `GalleryBloc` (más de 100 pendientes → todos seleccionados), formateador y hoja Gestionar con tamaño

- [x] `ManageFilesUseCase` envía más de 100 ficheros en lotes de 100 (el backend no limita `/manage/`); con `newFolder` y varios lotes crea antes el álbum y envía todos los lotes a él

Acceptance criteria: con 120 pendientes, «Revisar» hace una sola llamada, selecciona los 120 y la hoja muestra cuánto espacio se libera.

Status: ✅ Completed

## Phase 3: Propiedades del fichero
- [x] Entidad `FileInfo` y modelo con todos los campos de `/api/file/{fileId}/info/`
- [x] Data source, repositorio y caso de uso `GetFileInfoUseCase` (feature `file_management`)
- [x] `FilePropertiesSheet` carga la información al abrirse (estado de carga y de error con reintento) y muestra: nombre original, tamaño, dimensiones, duración, fecha de captura, fecha de subida, álbum y dispositivo de origen, además del estado y el ID actuales. Las filas sin dato se ocultan
- [x] Mismo comportamiento en el visor de la papelera (`trash_file_detail_page.dart`)
- [x] Tests: modelo, data source (incluido 400 `FILE_NOT_FOUND`), caso de uso y widget de la hoja (carga, datos, error)

Acceptance criteria: Propiedades muestra el dispositivo de origen y el tamaño; un fichero sin dispositivo oculta esa fila.

Status: ✅ Completed

## Phase 4: Fechas de álbum
- [x] `Folder`: `oldestCapturedAt` y `newestCapturedAt` (nullable) en entidad y modelo (listado, `folderInfo` y `subfolders`)
- [x] Subtítulo del álbum con el rango de fechas («ago 2024» o «ene – ago 2024»); se omite si las fechas son nulas
- [x] Cabecera del contenido del álbum y tarjetas de subcarpetas con los mismos datos
- [x] Tests: modelos con y sin campos nuevos; formateo del rango (mismo mes, mismo año, años distintos); `FolderCard` con y sin fechas

Acceptance criteria: cada álbum muestra su rango de fechas, incluidos los álbumes que solo tienen subcarpetas.

Status: ✅ Completed

## Phase 5: Favoritas y portadas (`FAVORITOS_PORTADAS.md`)
Se implementa siguiendo las fases 1–5 de `FAVORITOS_PORTADAS.md`, en su rama `feature/favoritas-portadas`. El backend ya implementa el contrato de su sección 2, con estas diferencias que la capa `data` debe respetar:
- [x] Favoritas: `POST /api/file/favorite/` responde `{ updated, failed }` con IDs numéricos (convertir con `toString()`)
- [x] `sourceFolderPath` (lista de nombres) en cada portada: la app la une con « › » para «De Playa › Atardeceres»
- [x] `fallbackCoverFileIds` solo contiene fotos; un álbum con solo vídeos no tiene mosaico
- [x] Nuevos códigos de error a localizar: `FOLDER_COVER_VIDEO_NOT_ALLOWED`, `FOLDER_COVER_REPLACE_NOT_VALID`
- [ ] El flag `AppConfig.favoritesAndCoversEnabled` puede activarse también en `prod.json` en cuanto se despliegue el backend de `feature/favoritas-portadas`

Acceptance criteria: los criterios de las fases de `FAVORITOS_PORTADAS.md`.

Status: ✅ Completed (falta la prueba manual de FAVORITOS_PORTADAS §9 y activar el flag en prod tras desplegar el backend)

## Phase 6: Desglose del almacenamiento
- [x] Entidad `StorageUsage { photosBytes, videosBytes, trashBytes, usedBytes, quotaBytes }` en `UserProfile`, nullable si la API no la envía
- [x] `StorageBar`: barra segmentada (fotos, vídeos, papelera) con leyenda y tamaños; sin `storage`, la barra de un solo color actual
- [x] Tests: modelo con y sin `storage`; `StorageBar` con desglose, sin desglose y con uso 0

Acceptance criteria: Perfil muestra cuánto ocupan fotos, vídeos y papelera, y los tres segmentos suman el uso total.

Status: ✅ Completed

## Phase 7: Cierre
- [x] Actualizar la sección 9 de `REDESIGN.md`: todas las alternativas sustituidas por datos reales
- [x] «210 MB por subir» en la copia en curso, calculado en cliente con el tamaño de los ficheros pendientes (era la última alternativa por falta de datos)
- [ ] Prueba manual en dispositivo, en modo claro y oscuro, contra el backend de `feature/favoritas-portadas`
- [x] Revisar la cobertura (`coverage.sh`): 84,5 % de líneas (umbral 80 %); corregida la lectura del porcentaje con el `lcov` actual

Acceptance criteria: ninguna pantalla usa ya una alternativa de la sección 9 por falta de datos.

Status: 🚧 In Progress (falta la prueba manual en dispositivo)
