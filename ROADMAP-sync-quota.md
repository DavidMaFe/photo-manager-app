# Feature: Copias que no caben en la cuota

## Overview

Qué hace una copia (manual o en segundo plano) cuando lo pendiente de subir no cabe en el espacio libre del plan.

**Hoy:**
- La app sube en orden (de lo más reciente a lo más antiguo) hasta el primer archivo que no cabe.
- Ese archivo se envía **entero** y el servidor lo rechaza al final (400 `USER_NOT_HAVE_STORAGE_SPACE`): un vídeo de 2 GB viaja para nada.
- Después la copia **se para**: los archivos pequeños que venían detrás y sí cabían no se suben.
- No se avisa antes de empezar.

**Después:**
- Antes de enviar cada archivo, la app comprueba que cabe, con su **tamaño exacto en el servidor**. La app lo conoce porque ya lo ha cifrado: el original cifrado, más la miniatura y la versión de 2048 px, lo mismo que cuenta el backend (`File#storedBytes`).
  - Si no cabe, se salta sin enviarlo y la copia sigue con el siguiente.
  - Los vídeos se descartan antes de cifrarlos: su tamaño cifrado nunca es menor que el original.
- Si el servidor lo rechaza de todas formas (otro dispositivo subió a la vez), la app relee el espacio libre y sigue con lo que quepa.
- La copia termina con normalidad y dice cuántos archivos y cuánto espacio se quedaron fuera, con el enlace a los planes. En segundo plano, con una notificación.
- Al empezar una copia manual, si lo pendiente no cabe entero, la app avisa sin bloquear: «se subirá lo que quepa».

**Decisiones del usuario:**
- Se sigue subiendo de lo más reciente a lo más antiguo, saltando lo que no cabe. Los archivos ya subidos (estén o no organizados en álbumes) ya cuentan en la cuota y no cambian.
- El backend no cambia: sigue siendo quien decide.

## Phase 0: Comprobar el espacio antes de enviar
- [x] `StorageBudget` (dominio de `sync_session`): el espacio libre del plan (`limits.storageBytes - storedBytes` de `GET /api/profile/plan/`). Métodos:
  - `fits(bytes)`;
  - `spend(bytes)`, tras cada subida;
  - `refresh(plan)`, tras un rechazo del servidor.

  Sin plan (no se pudo leer), no limita: decide el servidor.
- [x] `UploadFileUseCase`:
  - con un `StorageBudget`, después de cifrar suma los tres objetos y, si no caben, lanza `FileDoesNotFitFailure(storedBytes)` sin llamar al servidor;
  - con éxito, gasta lo subido.
- [x] Vídeos: si el tamaño original ya no cabe, se descartan sin cifrarlos. Las imágenes se cifran y se comprueban exactas, porque con JPEG XL pueden ocupar menos que el original.
- [x] Tests del dominio y del caso de uso: el archivo no cabe y no hay llamada al servidor; sí cabe; el presupuesto se gasta; sin plan no hay límite.

**Criterio de aceptación:** un archivo que no cabe nunca se envía.

Status: ✅ Completed

## Phase 1: Copia manual
- [x] `SyncSessionBloc`:
  - lee el plan al empezar y crea el `StorageBudget`;
  - si lo pendiente (suma de tamaños originales) supera el espacio libre, el estado de subida lo indica y la página lo avisa sin bloquear;
  - un `FileDoesNotFitFailure` salta el archivo y sigue;
  - un `USER_NOT_HAVE_STORAGE_SPACE` del servidor relee el plan, salta el archivo y sigue (ya no para ni cancela la sesión).
- [x] Al terminar, `SyncSessionSuccess` lleva los archivos y bytes que no cupieron. La página lo dice, con el enlace a los planes, como ya hace con los vídeos demasiado grandes.
- [x] Textos en español e inglés.
- [x] Tests del bloc y de la página. Para llegar al bucle de subida en los tests, el permiso de fotos se inyecta en el bloc (`requestPhotoAccess`, por defecto el diálogo de siempre).

**Criterio de aceptación:** con poco espacio libre, la copia manual sube todo lo que cabe, termina y dice qué se quedó fuera.

Status: ✅ Completed

## Phase 2: Copia en segundo plano
- [x] `BackgroundSyncService`: la misma lógica. `USER_NOT_HAVE_STORAGE_SPACE` deja de parar la copia (sale de `_planLimitCodes`).
- [x] Al terminar con archivos que no cupieron, una notificación con cuántos y cuánto espacio, que abre los planes.
- [x] Evento de monitorización `SYNC_STORAGE_FULL` (archivos y bytes que no cupieron, en segundo plano o no), para verlo en el panel «App» de Grafana.
- [x] Tests del servicio (nuevos: el servicio no tenía). La red y la batería se inyectan para poder probarlo.
- [x] La notificación sale si están activadas las notificaciones de fallo (`notifyOnFailure`). Al tocarla se abren los planes, con la app abierta o cerrada (`main.dart`, payload `plans`). El evento se registra siempre.

**Criterio de aceptación:** la copia en segundo plano sube lo que cabe y avisa del resto.

Status: ✅ Completed

## Phase 3: Publicación y cierre
- [ ] `CLAUDE.md` de la app: qué hace una copia cuando no cabe todo.
- [ ] Versión nueva, AAB y pruebas internas.
- [ ] Prueba en el S23 con una cuenta de prueba con la cuota rebajada. El usuario la ajusta en freya con un `UPDATE users SET storage_quota_bytes = …` sobre esa cuenta.
- [ ] PR a `main` y borrar este roadmap.

**Criterio de aceptación:** probado en el S23.

Status: 🚧 In Progress
