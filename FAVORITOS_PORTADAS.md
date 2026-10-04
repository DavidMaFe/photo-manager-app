# FAVORITOS_PORTADAS.md — Favoritas y portadas de álbum

Documento de traspaso para implementar dos funcionalidades nuevas en Photo Manager.
**Requisito previo:** `REDESIGN.md` (estilo «Revelado») ya está aplicado. Este documento usa sus componentes (`MediaThumbnail`, `MediaGrid`, `FilterPillBar`, `AppSheet`, `AppDialog`, `AppButton`, barra de acciones de selección, visor nuevo…) y su paleta (`context.palette`).

Referencia visual: lienzo «Photo Manager · Diseño actual y rediseño», fila **«Nuevo · Favoritas y portadas de álbum»**, y las pantallas Fotos, Fotos en selección, Visor, Álbumes y Dentro de un álbum (actualizadas).

---

## 0. Instrucciones para Claude Code

1. Rama nueva: `git checkout -b feature/favoritas-portadas`.
2. Sigue las fases de la sección 9, una cada vez. Tras cada fase: `flutter gen-l10n` (si hay textos), `flutter analyze`, `flutter test`, commit `feat(fase N): …`.
3. Respeta la arquitectura limpia del proyecto: entidad → repositorio (interfaz en `domain`) → caso de uso → implementación en `data` → BLoC → UI. Registrar todo en `core/injection_container.dart`.
4. **El backend aún no tiene estos endpoints** (sección 2). Implementa la capa `data` contra el contrato propuesto y deja un *flag* `AppConfig.favoritesAndCoversEnabled` (por defecto `false` en `prod.json`, `true` en `dev.json`) que oculta toda la UI nueva mientras el backend no esté listo. Si el usuario indica que el backend ya existe con otra forma, adapta solo los `*RemoteDataSource` y modelos.
5. Textos nuevos en `app_es.arb` y `app_en.arb`.
6. Nada de colores fijos: los nuevos van en `AppColors`/`AppPalette` (sección 3).

---

## 1. Requisitos

### 1.1 Favoritas
- Marcar y desmarcar una foto o vídeo como favorita desde:
  - el **visor** (botón «Favorita» de la barra inferior),
  - la **barra de acciones de selección** (en Fotos y dentro de un álbum), para varias a la vez.
- Indicador de favorita en **todas las rejillas de miniaturas**: Fotos, Fotos en selección, Dentro de un álbum y su modo selección.
- **Filtro «Favoritas»** en la pestaña Fotos (pastilla con corazón, segunda posición: Todo · Favoritas · Fotos · Vídeos · Por revisar).
- La papelera **no** muestra el indicador (los archivos borrados conservan la marca en servidor y la recuperan al restaurarse).

### 1.2 Portadas de álbum
- Cada álbum tiene **de 0 a 3 portadas**, **ordenadas** (la primera es la grande del mosaico).
- Una foto puede ser portada del **álbum que la contiene directamente y de cualquiera de sus álbumes ancestros** (recursivo). Ejemplo: una foto de `Vacaciones 2024 › Playa › Atardeceres` puede ser portada de Atardeceres, Playa y/o Vacaciones 2024. **No** de álbumes hermanos ni de otros árboles.
- Se puede poner/quitar como portada en **varios álbumes a la vez** desde una hoja con el árbol de ancestros.
- Si un álbum ya tiene 3 portadas y se marca, el usuario **elige cuál sustituir**.
- Acceso: **visor abierto desde un álbum** (botón «Portada») y **selección dentro de un álbum** (acción «Portada», máximo 3 fotos seleccionadas).
- Gestión en el álbum: tarjeta «Portada · 3 de 3 · Editar» → hoja para **quitar** portadas y **reordenarlas** arrastrando.
- Sin portadas elegidas, el álbum usa sus fotos más recientes (comportamiento actual).
- Si una foto que es portada **sale del árbol** del álbum (se mueve a otro álbum, va a la papelera o se borra), **deja de ser portada** de los álbumes que ya no la contienen. Esto debe garantizarlo el backend; el cliente solo refresca.

---

## 2. Contrato de API propuesto

Mantiene el estilo actual (`$baseUrl/api/...`, `Authorization: Bearer`, cuerpos JSON, `ErrorHandler` para los fallos).

### 2.1 Favoritas
| Método y ruta | Cuerpo | Respuesta |
|---|---|---|
| `POST /api/file/favorite/` | `{ "fileIds": ["…"], "favorite": true }` | `{ "updated": ["…"], "failed": [] }` |
| `GET /api/file/list/?favorite=true&…` | — | igual que hoy (paginado) |

Añadir a cada fichero de `/api/file/list/` y de `/api/folder/{id}/` el campo **`"isFavorite": bool`**.

### 2.2 Portadas
| Método y ruta | Cuerpo | Respuesta |
|---|---|---|
| `GET /api/file/{fileId}/cover-targets/` | — | Lista **ordenada de la raíz a la carpeta directa**: `[{ "folderId", "name", "depth", "containsDirectly": bool, "covers": [{ "fileId", "position", "sourceFolderId", "sourceFolderName" }] }]` |
| `PUT /api/folder/cover/batch/` | `{ "fileId": "…", "changes": [ { "folderId": "…", "action": "add" \| "remove" \| "replace", "replaceFileId": "…?" } ] }` | `{ "folders": [ { "folderId", "covers": [...] } ] }` |
| `GET /api/folder/{id}/covers/` | — | `{ "covers": [ { "fileId", "position", "sourceFolderId", "sourceFolderName" } ] }` |
| `PUT /api/folder/{id}/covers/` | `{ "fileIds": ["a","b","c"] }` (orden final; sirve para quitar y reordenar) | `{ "covers": [...] }` |

Reglas del servidor: máximo 3 por carpeta (error de validación si se supera sin `replace`), `fileId` debe pertenecer al subárbol de `folderId`, limpieza automática cuando el fichero sale del subárbol.

Para pintar los mosaicos, añadir a cada carpeta de `/api/folder/list/` y a `subfolders`/`folderInfo` de `/api/folder/{id}/`:
`"coverFileIds": ["…"]` (ordenado, 0–3). Si viene vacío, el servidor puede devolver las 3 más recientes en `"fallbackCoverFileIds"`.

Para la portada en el selector, cada fichero de `/api/folder/{id}/` incluye `"coverOf": ["folderId", …]` (álbumes del árbol de los que es portada), o como mínimo `"isCoverOfCurrent": bool`.

---

## 3. Diseño: tokens nuevos

Añadir a `AppColors` y a `AppPalette` (claro / oscuro):

| Token | Claro | Oscuro | Uso |
|---|---|---|---|
| `favorite` | `#E5466F` | `#FF5C85` | corazón activo en el visor y en la pastilla «Favoritas» |
| `favoriteInk` | `#FF8FAB` | `#FF8FAB` | etiqueta «Favorita» activa sobre la barra oscura del visor |
| `coverBadgeBg` | `rgba(255,255,255,0.92)` | `rgba(24,24,31,0.92)` | fondo de la etiqueta «Portada» sobre miniaturas |

El indicador de favorita sobre miniaturas es **siempre blanco** (no rosa) con sombra, para que se lea sobre cualquier foto.

Icono de portada: `Symbols.auto_awesome_mosaic_rounded` (relleno). Favorita: `Symbols.favorite_rounded` (relleno = activo, contorno = inactivo).

---

## 4. Especificación de UI

### 4.1 `MediaThumbnail` — nuevos estados
Añadir parámetros `bool isFavorite = false` y `bool isCover = false`.
- **Favorita:** icono corazón relleno blanco, 18 px (20 px en la miniatura grande 2×2), esquina **inferior izquierda**, margen 6 (8 en la grande). Sombra `Shadow(color: black45, blurRadius: 4, offset: (0,1))`. En estado seleccionado, el margen se suma al encogido (≈ 12–14 px).
- **Portada** (solo dentro de un álbum, cuando la foto es portada de **ese** álbum): pastilla esquina **superior izquierda**, alto 22, padding `0 8 0 5`, fondo `coverBadgeBg`, icono mosaico 14 relleno + texto «Portada» 10/w800 color `accentInk`. En selección: alto 20, icono 12, texto 9.
- Convivencia de esquinas: arriba-izquierda = Portada · arriba-derecha = por revisar / círculo de selección · abajo-izquierda = favorita (y días en papelera) · abajo-derecha = duración de vídeo.
- `Semantics` de la miniatura: añadir «favorita» y «portada» a la etiqueta.

### 4.2 Fotos (`gallery_page.dart`)
- `FilterPillBar`: nueva pastilla **Favoritas** (corazón 17 px relleno color `favorite` + texto). Necesita `FileFilter.favorites` (sección 5.1).
- Miniaturas con `isFavorite`.
- Estado vacío del filtro: icono corazón, «Aún no tienes favoritas», «Toca el corazón al ver una foto para guardarla aquí».

### 4.3 Barra de acciones de selección
- **En Fotos:** sin cambios de botones (Guardar · A un álbum · Liberar · Eliminar). La marca de favorita en lote se hace desde el visor o dentro de álbumes. *(Si el usuario prefiere tener «Favoritas» también aquí, se añade como 5.º botón; preguntar antes de hacerlo.)*
- **Dentro de un álbum** (nuevo modo selección del álbum):
  - Cabecera: «{n} seleccionadas» + subtítulo «en {álbum}» 12/w600 ink2 + botón «Todas».
  - Línea superior de la barra: «{n} fotos · hasta 3 pueden ser portada».
  - Botones: **Portada** (fondo accent, icono mosaico) · **Favoritas** · **Mover** · **Eliminar** (rojo).
  - **Portada** deshabilitado (opacidad 0.45) con más de 3 seleccionadas o si alguna seleccionada es vídeo *(confirmar con el usuario si los vídeos pueden ser portada; por defecto, no)*. Al tocarlo deshabilitado: snackbar «Elige hasta 3 fotos para usar como portada».
  - **Favoritas**: si todas las seleccionadas ya son favoritas → «Quitar de favoritas» (icono contorno); si no → marca todas.

### 4.4 Visor (`file_detail_page.dart`)
- Botón **Favorita** en la barra inferior. Activo: icono relleno `favorite`, etiqueta w800 `favoriteInk`, `aria-pressed`/`Semantics(toggled: true)`. Inactivo: icono contorno blanco, etiqueta w700 blanca.
- Cambio **optimista**: alterna al instante, llama a la API y revierte con snackbar si falla. Pequeña animación de escala (1 → 1.25 → 1, 220 ms) al activar.
- **Visor abierto desde un álbum** (nuevo parámetro `FileViewerContext.album(folderId, folderPath)`):
  - Subtítulo de la cabecera: ruta del álbum «Vacaciones 2024 › Playa › Atardeceres».
  - Si la foto es portada de algún álbum del árbol: pastilla bajo la cabecera, fondo `rgba(142,134,255,0.24)`, texto `#D6D2FF` 12/w700, icono mosaico 16: «Portada de Playa» (si es de varios: «Portada de 2 álbumes»).
  - Barra inferior de **5** botones (margen lateral 12): Compartir · Favorita · **Portada** (pastilla accent 52×30, abre 4.5) · Mover · Eliminar.
  - Si el archivo es vídeo, el botón Portada no aparece (ver nota de 4.3).
- Visor abierto desde Fotos: barra de 4 botones como en REDESIGN (Compartir · Favorita · Guardar · Eliminar).

### 4.5 Hoja «Usar como portada» (nuevo `cover_picker_sheet.dart`)
`AppSheet` casi a pantalla completa (top 48), contenido desplazable.
- Cabecera: miniatura 48 radio 12 de la foto + «Usar como portada» 20/w800 + «Marca los álbumes donde quieres que aparezca. Máx. 3 por álbum.» 13/w600 ink2.
- **Árbol** (`cover-targets`), de la raíz a la carpeta directa, cada nivel sangrado 22 px con conector en «L» (línea 2 px `line`, esquina redondeada 8).
- **Fila** (tarjeta radio 18, padding 12×14):
  - Casilla 26 px (`check_box` / `check_box_outline_blank`, color accent).
  - Nombre 15/w700. Si `containsDirectly`: etiqueta «La foto está aquí» (10/w800, surface2, radio 6).
  - Línea de estado 12/w600:
    - ya era portada y sigue marcada → «Ya es portada · desmarca para quitarla» (ink2)
    - se va a añadir con hueco → «Se añade · {n+1} de 3» (accentInk)
    - se va a añadir sin hueco → «Lleno · elige cuál sustituir» (reviewInk)
    - se va a quitar → «Se quita de la portada» (dangerInk)
    - sin cambios y no es portada → «{n} de 3 portadas» (ink2)
  - A la derecha, **3 huecos** 26×26 radio 6 con las portadas actuales (vacío = borde discontinuo 1.5 `#C9C9D2`); la foto actual, si está o va a estar, con doble anillo (blanco 2 + accent 2).
  - Estilo de la tarjeta: con cambio pendiente → fondo `#F6F5FF` (oscuro: `accentSoft`) + anillo accent 2; sin cambio → anillo `line` 1.5.
- **Sustitución:** si se marca un álbum con 3 portadas, la fila se expande y muestra las 3 portadas (rejilla 3 columnas, cuadradas, radio 12, gap 8) como grupo de radio. La elegida muestra velo `rgba(19,19,24,.45)` con icono `swap_horiz` 22 y «Sustituir» 11/w800, y doble anillo. Hasta elegir una, el botón principal está deshabilitado y la fila muestra el estado en ámbar.
- Nota inferior (icono info): «Solo aparecen el álbum de la foto y los que lo contienen.»
- Botón principal: «Guardar · {n} cambios» (deshabilitado sin cambios) → `PUT /api/folder/cover/batch/`. Secundario: «Cancelar».
- Tras guardar: cerrar, snackbar «Portada actualizada en {n} álbumes», refrescar el álbum abierto, la lista de álbumes y la pastilla del visor.
- **Desde selección múltiple (2–3 fotos):** misma hoja; la cabecera muestra la pila de miniaturas y el árbol es el de los **ancestros comunes** de todas las fotos (intersección). Si una fila no tiene hueco suficiente para todas, el selector de sustitución permite elegir tantas como falten. Si las fotos no comparten ningún álbum, no se abre la hoja: snackbar «Estas fotos no comparten álbum».

### 4.6 Dentro de un álbum (`folder_content_page.dart`)
- Bajo el título y los metadatos: **tarjeta de portada** (radio 18, fondo surface, padding `10 12 10 10`): mosaico 52 px de las portadas actuales · «Portada» 14/w700 · «{n} de 3 fotos · {m} de {subálbum}» 12/w600 ink2 (si alguna viene de un subálbum; si no hay portadas: «Automática · fotos recientes») · «Editar» 13/w700 accentInk. Toca → 4.7.
- Cabecera de grupo de fecha con «Seleccionar» a la derecha → modo selección del álbum (4.3).
- Miniaturas con `isFavorite` e `isCover` (portada de **este** álbum).
- El visor se abre con el contexto de álbum (4.4).

### 4.7 Hoja «Portada de {álbum}» (nuevo `album_covers_sheet.dart`)
- Título «Portada de {álbum}» 20/w800 + «{n} de 3 fotos · arrastra para cambiar el orden» 13/w600 ink2.
- Vista previa del mosaico 132×132 radio 22 tal como saldrá en Álbumes + texto «Así se ve en Álbumes» / «La primera foto es la grande. Con 1 o 2 fotos el mosaico se adapta.»
- Lista reordenable (`ReorderableListView`, fondo `background`, radio 20): asa `drag_indicator` · miniatura 52 radio 10 · «Principal» / «Segunda» / «Tercera» 14/w700 · origen 12/w600 ink2 («De este álbum» / «De Playa › Atardeceres») · botón 40 círculo `dangerSoft` con `close` `dangerInk` → quitar (sin confirmación; se puede deshacer con «Deshacer» en el snackbar).
- Nota: «Para añadir otra, abre una foto de este álbum o de sus subálbumes y pulsa «Portada». Sin portadas, se usan las fotos más recientes.»
- Botón «Listo»: si hubo cambios → `PUT /api/folder/{id}/covers/` con el orden final; si no, solo cierra.
- 0 portadas: vista previa con las recientes atenuadas al 50 % y texto «Automática».

### 4.8 Álbumes (`folders_page.dart`, `folder_card.dart`)
Mosaico de la tarjeta según el número de portadas (`coverFileIds`, o `fallbackCoverFileIds` si vacío):
- **3:** 2fr/1fr — grande a la izquierda (2 filas), dos pequeñas apiladas.
- **2:** dos columnas iguales.
- **1:** foto completa.
- **0 y sin fallback:** icono de álbum sobre surface2 (como hoy).
Gap 2, radio 22. Lo mismo para las tarjetas de subálbum (radio 16) y la miniatura de la tarjeta de portada (radio 12).

---

## 5. Implementación por capas

### 5.1 Favoritas
- **Domain**
  - `GalleryFile`: añadir `final bool isFavorite;` (+ `copyWith`). Igual en la entidad de ficheros de `FolderContent`.
  - `FileFilter.favorites` (displayName localizado; mapear a `favorite=true` en la query).
  - Repositorio nuevo `FavoritesRepository { Future<FavoriteResult> setFavorite(List<String> ids, bool favorite); }` y caso de uso `SetFavoriteUseCase`.
- **Data**
  - `GalleryFileModel.fromJson`: `isFavorite: json['isFavorite'] as bool? ?? false`.
  - `FavoritesRemoteDataSource` → `POST /api/file/favorite/`.
  - Query `favorite=true` en `GalleryRemoteDataSource` cuando el filtro sea `favorites`.
- **Presentation**
  - `GalleryBloc`: evento `ToggleFavorite(ids, favorite)` con actualización optimista de `files` y `groupedFiles`, reversión si falla y emisión de un efecto para el snackbar. Si el filtro activo es `favorites` y se desmarca, retirar la miniatura con animación.
  - `FolderContentBloc`: mismo evento.
  - Visor: recibe el bloc correspondiente o un callback `onFavoriteChanged`; mantiene el estado local del archivo actual.
  - Sincronizar entre vistas con `AppEventBus` (`FavoritesChangedEvent(ids, favorite)`), ya existente en `core/events/`.

### 5.2 Portadas
- **Domain**
  - `Folder`: `final List<String> coverFileIds;` (+ `fallbackCoverFileIds`).
  - Entidades `AlbumCover { fileId, position, sourceFolderId, sourceFolderName }` y `CoverTarget { folderId, name, depth, containsDirectly, covers }`.
  - `CoverChange { folderId, CoverChangeAction action (add/remove/replace), String? replaceFileId }`.
  - `CoversRepository`: `getCoverTargets(fileIds)` · `applyCoverChanges(fileIds, changes)` · `getAlbumCovers(folderId)` · `setAlbumCovers(folderId, orderedFileIds)`.
  - Casos de uso: `GetCoverTargetsUseCase`, `ApplyCoverChangesUseCase`, `GetAlbumCoversUseCase`, `SetAlbumCoversUseCase`.
  - Validación en dominio: `ApplyCoverChangesUseCase` rechaza (`ValidationFailure`) un `add` sobre un álbum con 3 portadas sin `replace`, y más de 3 fotos.
- **Data**
  - `FolderModel.fromJson`: `coverFileIds`, `fallbackCoverFileIds`.
  - Ficheros de `FolderContentModel`: `isFavorite`, `coverOf`.
  - `CoversRemoteDataSource` con los 4 endpoints de 2.2. Para varias fotos, `getCoverTargets` hace una llamada por foto y calcula la intersección en el repositorio.
- **Presentation**
  - `CoverPickerCubit` (estado: `targets`, `pendingChanges: Map<folderId, CoverChange>`, `replaceSelection`, `status`), con métodos `toggle(folderId)`, `chooseReplacement(folderId, fileId)`, `save()`. Getter `changeCount` y `canSave`.
  - `AlbumCoversCubit` (estado: lista ordenada, `dirty`), con métodos `remove`, `undoRemove`, `reorder`, `save`.
  - Tras guardar: emitir `CoversChangedEvent(folderIds)` en `AppEventBus`; `FolderBloc` y `FolderContentBloc` recargan los álbumes afectados.
  - Visor: con contexto de álbum, cargar `coverOf` del archivo (de `FolderContent`) para pintar la pastilla.

### 5.3 Rutas
No hacen falta rutas nuevas: ambas hojas se abren con `showAppSheet`. El visor recibe el contexto por `extra` (`{'files', 'initialIndex', 'albumContext'}`); actualizar `app_router.dart` para la ruta del visor dentro de carpetas (`fileDetailFromFolder`).

---

## 6. Textos (l10n)

**es** (añadir también en `en`):

| Clave | Texto |
|---|---|
| `filterFavorites` | Favoritas |
| `favorite` | Favorita *(si existe del REDESIGN, reutilizar)* |
| `addToFavorites` | Añadir a favoritas |
| `removeFromFavorites` | Quitar de favoritas |
| `favoritesEmptyTitle` | Aún no tienes favoritas |
| `favoritesEmptyBody` | Toca el corazón al ver una foto para guardarla aquí |
| `favoritesAdded` | `{count, plural, =1{Añadida a favoritas} other{{count} añadidas a favoritas}}` |
| `favoritesRemoved` | `{count, plural, =1{Quitada de favoritas} other{{count} quitadas de favoritas}}` |
| `favoriteError` | No se pudo actualizar. Inténtalo de nuevo. |
| `cover` | Portada |
| `coverBadge` | Portada |
| `coverOf` | Portada de {album} |
| `coverOfMany` | Portada de {count} álbumes |
| `useAsCover` | Usar como portada |
| `useAsCoverBody` | Marca los álbumes donde quieres que aparezca. Máx. 3 por álbum. |
| `photoIsHere` | La foto está aquí |
| `coverAlreadyHint` | Ya es portada · desmarca para quitarla |
| `coverWillAdd` | Se añade · {count} de 3 |
| `coverFullChoose` | Lleno · elige cuál sustituir |
| `coverWillRemove` | Se quita de la portada |
| `coverCount` | {count} de 3 portadas |
| `replace` | Sustituir |
| `coverTreeNote` | Solo aparecen el álbum de la foto y los que lo contienen. |
| `saveChangesCount` | `{count, plural, =1{Guardar · 1 cambio} other{Guardar · {count} cambios}}` |
| `coverUpdated` | `{count, plural, =1{Portada actualizada} other{Portada actualizada en {count} álbumes}}` |
| `upToThreeCovers` | {count} fotos · hasta 3 pueden ser portada |
| `chooseUpToThree` | Elige hasta 3 fotos para usar como portada |
| `noSharedAlbum` | Estas fotos no comparten álbum |
| `inAlbum` | en {album} |
| `albumCoverTitle` | Portada de {album} |
| `albumCoverSubtitle` | {count} de 3 fotos · arrastra para cambiar el orden |
| `albumCoverCard` | {count} de 3 fotos |
| `albumCoverFromSub` | {count} de {album} |
| `albumCoverAuto` | Automática · fotos recientes |
| `previewInAlbums` | Así se ve en Álbumes |
| `previewInAlbumsBody` | La primera foto es la grande. Con 1 o 2 fotos el mosaico se adapta. |
| `coverMain` | Principal |
| `coverSecond` | Segunda |
| `coverThird` | Tercera |
| `fromThisAlbum` | De este álbum |
| `fromAlbum` | De {path} |
| `removeCover` | Quitar de portada |
| `addCoverHint` | Para añadir otra, abre una foto de este álbum o de sus subálbumes y pulsa «Portada». Sin portadas, se usan las fotos más recientes. |
| `done` | Listo *(reutilizar si existe)* |
| `undo` | Deshacer |
| `move` | Mover |

---

## 7. Accesibilidad

- Botón Favorita: `Semantics(button: true, toggled: isFavorite, label: l10n.favorite)`.
- Indicadores en miniaturas: incluidos en la etiqueta semántica de la miniatura, no como nodos separados.
- Casillas del árbol: `Semantics(checked:, label: '{álbum}, {estado}')`; opciones de sustitución como grupo de radio con etiqueta «Sustituir portada {n} de {álbum}».
- Lista reordenable: además del arrastre, acciones semánticas «Subir» / «Bajar» (`CustomSemanticsAction`).
- Áreas táctiles ≥ 44 px (la casilla de 26 px va dentro de una fila táctil completa).

---

## 8. Tests

- **Unit:**
  - `SetFavoriteUseCase` y `ApplyCoverChangesUseCase`: límite de 3, `replace` obligatorio y más de 3 fotos.
  - Intersección de ancestros para varias fotos.
  - Modelos con `isFavorite`, `coverFileIds` y `coverOf`, incluida la ausencia del campo (por defecto `false` / `[]`).
- **Bloc** (`bloc_test`):
  - `GalleryBloc.ToggleFavorite`: actualización optimista y reversión.
  - `CoverPickerCubit`: marcar, sustituir, `changeCount` y guardar.
  - `AlbumCoversCubit`: quitar, deshacer, reordenar y guardar.
- **Widget:**
  - `MediaThumbnail` con favorita, portada y selección a la vez (sin solapes).
  - Hoja de portada con un álbum lleno: el botón está deshabilitado hasta elegir sustitución.
  - Mosaico de la tarjeta de álbum con 0, 1, 2 y 3 portadas.
- **Fixtures:** añadir JSON de `cover-targets` y de `folder` con `coverFileIds` en `test/fixtures/json/`.

---

## 9. Fases

**Fase 1 · Modelo y datos**
- [x] Campos nuevos en entidades y modelos (`isFavorite`, `coverFileIds`, `fallbackCoverFileIds`, `coverOf`) con valores por defecto si no vienen.
- [x] Repositorios, casos de uso y data sources de favoritas y portadas (sección 2) + DI.
- [x] Flag `favoritesAndCoversEnabled`.
- [x] Tests unitarios.

**Fase 2 · Favoritas**
- [ ] Tokens `favorite`/`favoriteInk`.
- [ ] `MediaThumbnail.isFavorite` en todas las rejillas (excepto papelera).
- [ ] Filtro «Favoritas» en Fotos + estado vacío.
- [ ] Botón Favorita en el visor (optimista + animación).
- [ ] Acción «Favoritas» en la selección dentro de álbum.
- [ ] `FavoritesChangedEvent` en el bus de eventos.

**Fase 3 · Mosaicos de portada**
- [ ] Mosaico adaptativo 0/1/2/3 en tarjetas de álbum, subálbum y tarjeta de portada.

**Fase 4 · Portadas: gestión**
- [ ] Contexto de álbum en el visor (ruta, pastilla «Portada de…», barra de 5 botones).
- [ ] Hoja «Usar como portada» con árbol, estados y sustitución (una foto).
- [ ] Modo selección dentro de álbum con acción «Portada» (hasta 3, ancestros comunes).
- [ ] Tarjeta de portada en el álbum + hoja «Portada de {álbum}» (quitar, deshacer, reordenar).
- [ ] Etiqueta «Portada» en miniaturas del álbum.
- [ ] `CoversChangedEvent` y refresco de álbumes.

**Fase 5 · Cierre**
- [ ] Textos `.arb` completos y `flutter gen-l10n`.
- [ ] Accesibilidad (sección 7).
- [ ] Tests de bloc y widget (sección 8).
- [ ] Prueba manual en claro y oscuro: marcar y desmarcar favoritas desde las tres entradas; portada en álbum directo, en ancestro y en varios a la vez; sustitución con álbum lleno; quitar y reordenar; mover una foto portada a otro álbum y comprobar que deja de serlo.

---

## 10. Decisiones abiertas (confirmar con el usuario si surgen)

1. ¿Los **vídeos** pueden ser portada? Por defecto no (se usaría un fotograma). Si sí, el backend debe devolver una miniatura estática.
2. ¿Botón **Favoritas** también en la barra de selección de la pestaña Fotos? Por defecto no, para mantener 4 botones.
3. Al **restaurar** de la papelera una foto que era portada, ¿vuelve a serlo? Por defecto no.
