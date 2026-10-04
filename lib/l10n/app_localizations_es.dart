// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Photo Manager';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailPlaceholder => 'tu@email.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logoutButton => 'Cerrar sesión';

  @override
  String get logoutConfirmation => '¿Seguro que quieres cerrar sesión?';

  @override
  String get forgotPassword => '¿La has olvidado?';

  @override
  String get accountCreated => '¡Cuenta creada! Por favor inicia sesión';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get namePlaceholder => 'Juan';

  @override
  String get surnamePlaceholder => 'Pérez';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get errorNameRequired => 'El nombre es requerido';

  @override
  String get errorConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get errorPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get signIn => 'Inicia sesión';

  @override
  String get registerTermsDisclaimer => 'Al registrarte, aceptas nuestros Términos y Condiciones';

  @override
  String get gallery => 'Galería';

  @override
  String get all => 'Todos';

  @override
  String get photos => 'Fotos';

  @override
  String get videos => 'Vídeos';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana pasada';

  @override
  String get noDate => 'Sin fecha';

  @override
  String get noFiles => 'No hay archivos que mostrar';

  @override
  String get selectionLimitReached => 'Solo puedes seleccionar hasta 100 archivos a la vez.';

  @override
  String get newFolderTitle => 'Nuevo álbum';

  @override
  String get partialManageTitle => 'Gestión parcial';

  @override
  String get filesRemovedFromServerLocalMayRemain => 'Algunos archivos pueden permanecer en este dispositivo si fueron subidos desde otro dispositivo.';

  @override
  String get filesManaged => 'Archivos Gestionados';

  @override
  String get success => 'Éxito';

  @override
  String get ok => 'OK';

  @override
  String get dontShowAgain => 'No mostrar de nuevo';

  @override
  String correctManage(Object files) {
    return '$files archivos gestionados correctamente.\n';
  }

  @override
  String failedManage(Object files) {
    return '$files archivos fallidos.';
  }

  @override
  String get fileTypeNotSupported => 'Tipo de archivo no soportado';

  @override
  String get fileProperties => 'Propiedades del archivo';

  @override
  String get filePropertyTypeImage => 'Imagen';

  @override
  String get filePropertyTypeVideo => 'Vídeo';

  @override
  String get filePropertyStatus => 'Estado';

  @override
  String get filePropertyCapturedAt => 'Fecha de captura';

  @override
  String get filePropertyDuration => 'Duración';

  @override
  String get loadingVideoError => 'Error al cargar el vídeo';

  @override
  String get folder => 'Álbum';

  @override
  String get subfolders => 'Subálbumes';

  @override
  String get rename => 'Renombrar';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String get folderName => 'Nombre del álbum';

  @override
  String get hintFolderName => 'Ex: Vacaciones 2024';

  @override
  String get folderNameRequiredError => 'El nombre es obligatorio';

  @override
  String get folderMaxHundredCharactersError => 'Máximo 100 caracteres';

  @override
  String get renameFolder => 'Renombrar álbum';

  @override
  String get newName => 'Nuevo nombre';

  @override
  String get creatingFolder => 'Creando álbum...';

  @override
  String get renamingFolder => 'Renombrando álbum...';

  @override
  String get deletingFolder => 'Eliminando álbum...';

  @override
  String get processing => 'Procesando...';

  @override
  String get emptyFolders => 'No tienes álbumes';

  @override
  String get emptyFolder => 'Este álbum está vacío';

  @override
  String get emptyFolderDescription => 'Mueve fotos aquí para ordenarlas';

  @override
  String get createFirstFolder => 'Crea tu primer álbum para ordenar tus fotos';

  @override
  String get deleteFolder => 'Eliminar álbum';

  @override
  String deleteEmptyFolder(Object folderName) {
    return '¿Seguro que quieres eliminar el álbum $folderName?';
  }

  @override
  String deleteFolderWithFiles(Object files, Object folderName) {
    return 'El álbum $folderName contiene $files archivos. ¿Seguro que quieres eliminar todo su contenido?';
  }

  @override
  String deleteFolderWithSubfolders(Object folderName, Object subfolders) {
    return 'El álbum $folderName contiene $subfolders subálbumes. ¿Seguro que quieres eliminar todo su contenido?';
  }

  @override
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders) {
    return 'El álbum $folderName contiene $files archivos y $subfolders subálbumes. ¿Seguro que quieres eliminar todo su contenido?';
  }

  @override
  String get syncSessionCancelWarning => '¿Cancelar sincronización?';

  @override
  String get syncSessionCancelDescription => 'Se perderá el progreso actual. Los archivos subidos se mantendrán en el servidor.';

  @override
  String get syncSessionCancelConfirm => 'Sí, cancelar';

  @override
  String get total => 'Total';

  @override
  String get uploaded => 'Subidos';

  @override
  String get failed => 'Fallidos';

  @override
  String get close => 'Cerrar';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get files => 'Archivos';

  @override
  String get folders => 'Álbumes';

  @override
  String get devices => 'Dispositivos';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myDevices => 'Mis dispositivos';

  @override
  String get trash => 'Papelera';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get trashIsEmpty => 'La papelera está vacía';

  @override
  String get trashEmptyDescription => 'Los archivos eliminados aparecerán aquí y se borrarán permanentemente después de 30 días';

  @override
  String get emptyTrash => 'Vaciar';

  @override
  String get emptyTrashConfirmation => '¿Estás seguro de que quieres eliminar permanentemente todos los archivos de la papelera? Esta acción no se puede deshacer.';

  @override
  String get restore => 'Restaurar';

  @override
  String restoreFiles(Object count) {
    return 'Restaurar $count archivos';
  }

  @override
  String get restoreFileConfirmation => '¿Quieres restaurar este archivo a su ubicación original?';

  @override
  String restoreFilesConfirmation(Object count) {
    return '¿Quieres restaurar $count archivos a sus ubicaciones originales?';
  }

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get deletePermanentlyConfirmation => '¿Estás seguro de que quieres eliminar permanentemente este archivo? Esta acción no se puede deshacer.';

  @override
  String deleteFilesPermanentlyConfirmation(Object count) {
    return '¿Estás seguro de que quieres eliminar permanentemente $count archivos? Esta acción no se puede deshacer.';
  }

  @override
  String filesRestoredSuccessfully(Object count) {
    return '$count archivos restaurados correctamente';
  }

  @override
  String filesDeletedPermanently(Object count) {
    return '$count archivos eliminados permanentemente';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get permissionPhotoAccessTitle => 'Acceso a Fotos';

  @override
  String get permissionPhotoAccessMessage => 'Esta aplicación necesita acceso a tus fotos para sincronizar y administrar tu galería. Tus fotos permanecerán privadas y seguras.';

  @override
  String get permissionPhotoAccessContinue => 'Continuar';

  @override
  String get permissionPhotoAccessDeniedTitle => 'Permiso Denegado';

  @override
  String get permissionPhotoAccessDeniedMessage => 'No podemos acceder a tus fotos sin permiso. Por favor, habilita el acceso a fotos en Configuración para usar esta función.';

  @override
  String get permissionOpenSettings => 'Abrir Configuración';

  @override
  String get timeLessThanAMinute => 'Hace un momento';

  @override
  String get timeOneMinute => 'Hace 1 minuto';

  @override
  String timeMoreThanOneMinute(Object minutes) {
    return 'Hace $minutes minutos';
  }

  @override
  String get timeOneHour => 'Hace 1 hora';

  @override
  String timeMoreThanOneHour(Object hours) {
    return 'Hace $hours horas';
  }

  @override
  String timeYesterday(Object hour) {
    return 'Ayer a las $hour';
  }

  @override
  String get errorUnknown => 'Ocurrió un error inesperado. Por favor inténtalo más tarde.';

  @override
  String get errorNetworkTitle => 'Error de Conexión';

  @override
  String get errorNetwork => 'Sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get errorServerTitle => 'Error del Servidor';

  @override
  String get errorServer => 'Error del servidor. Por favor, inténtalo más tarde';

  @override
  String get errorTimeout => 'La operación tardó demasiado. Por favor, inténtalo de nuevo.';

  @override
  String get errorUnauthorizedTitle => 'No autorizado';

  @override
  String get errorUnauthorized => 'No tienes autorización. Por favor, inicia sesión.';

  @override
  String get errorInvalidCredentials => 'Email o contraseña incorrectos.';

  @override
  String get errorTokenExpired => 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';

  @override
  String get errorValidationTitle => 'Datos Inválidos';

  @override
  String get errorValidation => 'Los datos proporcionados son inválidos.';

  @override
  String get errorInvalidEmail => 'El formato del email es inválido.';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String errorRequiredField(Object fieldName) {
    return 'El campo $fieldName es obligatorio.';
  }

  @override
  String get errorNotFoundTitle => 'No Encontrado';

  @override
  String get errorNotFound => 'El recurso solicitado no fue encontrado.';

  @override
  String get errorAlreadyExists => 'El recurso ya existe.';

  @override
  String get errorEmailAlreadyExists => 'Este email ya está registrado.';

  @override
  String get errorCache => 'Error al acceder a los datos locales.';

  @override
  String get errorStorageSpaceExceededTitle => 'Almacenamiento lleno';

  @override
  String get errorStorageSpaceExceeded => 'Has excedido la cuota de almacenamiento personal.';

  @override
  String get errorPermissionDenied => 'No tienes permisos para realizar esta acción.';

  @override
  String errorCode(Object code) {
    return 'Código de error: $code';
  }

  @override
  String get errorEmailRequired => 'Por favor ingresa un correo electrónico';

  @override
  String get errorPasswordRequired => 'Por favor ingresa una contraseña';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get emailSentSuccess => 'Código enviado a tu correo electrónico';

  @override
  String get validateCodeButton => 'Verificar código';

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String get codeResent => 'Código reenviado exitosamente';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get resetPasswordButton => 'Guardar contraseña';

  @override
  String get passwordResetSuccess => 'Contraseña restablecida exitosamente';

  @override
  String get errorNewPasswordRequired => 'La nueva contraseña es requerida';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get currentPasswordPlaceholder => 'Tu contraseña actual';

  @override
  String get errorCurrentPasswordRequired => 'La contraseña actual es requerida';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado';

  @override
  String get passwordChangedSuccessfully => 'Contraseña cambiada';

  @override
  String get selectProfilePhoto => 'Seleccionar foto de perfil';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get passwordSection => 'Cambiar contraseña';

  @override
  String get leavePasswordEmptyHint => 'Déjala en blanco si no quieres cambiarla';

  @override
  String get january => 'Enero';

  @override
  String get february => 'Febrero';

  @override
  String get march => 'Marzo';

  @override
  String get april => 'Abril';

  @override
  String get may => 'Mayo';

  @override
  String get june => 'Junio';

  @override
  String get july => 'Julio';

  @override
  String get august => 'Agosto';

  @override
  String get september => 'Septiembre';

  @override
  String get october => 'Octubre';

  @override
  String get november => 'Noviembre';

  @override
  String get december => 'Diciembre';

  @override
  String get renameDevice => 'Renombrar dispositivo';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get deviceNameRequired => 'El nombre del dispositivo es obligatorio';

  @override
  String get deviceNameTooLong => 'El nombre es demasiado largo (máximo 50 caracteres)';

  @override
  String get autoSync => 'Copia automática';

  @override
  String get unlinkDevice => 'Desvincular';

  @override
  String unlinkDeviceConfirmation(Object deviceName) {
    return '¿Estás seguro de que quieres desvincular \'$deviceName\'? Este dispositivo dejará de sincronizarse con tu cuenta.';
  }

  @override
  String get deviceActionSuccess => 'Hecho';

  @override
  String get noDevices => 'No tienes dispositivos vinculados';

  @override
  String get noDevicesDescription => 'Los dispositivos aparecerán aquí cuando inicies sesión en la aplicación desde otros dispositivos.';

  @override
  String get retry => 'Reintentar';

  @override
  String get autoSyncEnabled => 'La sincronización automática está activada';

  @override
  String get monday => 'Lunes';

  @override
  String get notifyOnSuccess => 'Notificar cuando la sincronización sea exitosa';

  @override
  String get notifyOnFailure => 'Notificar cuando la sincronización falle';

  @override
  String get configurationSaved => 'Ajustes guardados';

  @override
  String get loadingConfiguration => 'Cargando configuración...';

  @override
  String get configurationLoadError => 'Error al cargar la configuración';

  @override
  String get onboardingPermissionsRejectedTitle => 'Algunos Permisos No Fueron Otorgados';

  @override
  String get onboardingPermissionsRejectedMessage => 'Has denegado algunos permisos necesarios. La aplicación funcionará con funcionalidad limitada. Puedes habilitar estos permisos más tarde desde la configuración de la aplicación:';

  @override
  String get permissionLimitationPhoto => '• No podrás sincronizar fotos ni vídeos';

  @override
  String get permissionLimitationNotification => '• No recibirás notificaciones sobre las sincronizaciones';

  @override
  String get permissionLimitationBackground => '• La sincronización automática solo funcionará con la app abierta';

  @override
  String get loginGreeting => 'Hola de nuevo';

  @override
  String get loginSubtitle => 'Entra para ver y ordenar tus fotos.';

  @override
  String get noAccountYet => '¿Aún no tienes cuenta?';

  @override
  String get createAccountLink => 'Crear cuenta';

  @override
  String get registerHeadline => 'Crea tu cuenta';

  @override
  String get registerSubtitle => 'Guarda tus fotos y libera espacio del móvil.';

  @override
  String get surnameShortLabel => 'Apellido';

  @override
  String get optionalLabel => '(opcional)';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String stepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get forgotPasswordHeadline => '¿Has olvidado tu contraseña?';

  @override
  String get forgotPasswordBody => 'Escribe tu correo y te enviaremos un código para crear una nueva.';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String codeSentTo(String email) {
    return 'Te hemos enviado un código de 6 dígitos a $email';
  }

  @override
  String get didNotReceiveCode => '¿No te ha llegado?';

  @override
  String resendIn(String time) {
    return 'Reenviar en $time';
  }

  @override
  String get newPasswordHeadline => 'Crea una contraseña nueva';

  @override
  String get newPasswordBody => 'Usa una que no hayas usado antes en esta cuenta.';

  @override
  String get navPhotos => 'Fotos';

  @override
  String get backupUpToDate => 'Al día';

  @override
  String backupInProgress(int percent) {
    return 'Copiando $percent %';
  }

  @override
  String get backupFailed => 'Copia con fallos';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterToReview => 'Por revisar';

  @override
  String toReviewTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos por revisar',
      one: '1 elemento por revisar',
    );
    return '$_temp0';
  }

  @override
  String get toReviewBody => 'Decide si guardarlos o liberar espacio del móvil';

  @override
  String get review => 'Revisar';

  @override
  String get select => 'Seleccionar';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionadas',
      one: '1 seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get selectAllShort => 'Todas';

  @override
  String get selectNone => 'Ninguna';

  @override
  String get noPhotosYet => 'Aún no hay fotos';

  @override
  String get noPhotosBody => 'Sincroniza tu móvil para verlas aquí';

  @override
  String get backupNow => 'Hacer copia ahora';

  @override
  String get openProfile => 'Abrir perfil';

  @override
  String get closeSelection => 'Salir de la selección';

  @override
  String dayAndTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get viewerInfo => 'Información';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get deleteFileTitle => '¿Eliminar este archivo?';

  @override
  String get deleteFileBody => 'Se borrará de tu nube y de este móvil. Podrás recuperarlo desde la papelera durante 30 días.';

  @override
  String get copyId => 'Copiar ID';

  @override
  String get copiedToClipboard => 'Copiado';

  @override
  String get statusSafe => 'A salvo';

  @override
  String get navAlbums => 'Álbumes';

  @override
  String get searchAlbums => 'Buscar álbumes';

  @override
  String get newAlbum => 'Nuevo';

  @override
  String get createAlbum => 'Crear álbum';

  @override
  String albumMeta(int count, int subcount) {
    String _temp0 = intl.Intl.pluralLogic(
      subcount,
      locale: localeName,
      other: '$subcount subálbumes',
      one: '1 subálbum',
    );
    return '$count · $_temp0';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Vacío',
    );
    return '$_temp0';
  }

  @override
  String get subalbum => 'Subálbum';

  @override
  String get newSubalbum => 'Nuevo subálbum';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String noAlbumsMatch(String query) {
    return 'Ningún álbum coincide con «$query»';
  }

  @override
  String get navBackup => 'Copia';

  @override
  String get allSafe => 'Todo a salvo';

  @override
  String lastBackupMeta(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return 'Última copia $when · $_temp0';
  }

  @override
  String copyingNofM(int done, int total) {
    return 'Copiando $done de $total';
  }

  @override
  String get backupIncomplete => 'La última copia no terminó';

  @override
  String backupIncompleteMeta(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fallos',
      one: '1 fallo',
    );
    return '$when · $_temp0';
  }

  @override
  String get noBackupsYet => 'Aún no has hecho ninguna copia';

  @override
  String get noBackupsBody => 'Guarda tus fotos en la nube y libera espacio del móvil.';

  @override
  String get backupCancelledTitle => 'La última copia se canceló';

  @override
  String condDaily(String time) {
    return 'Diaria · $time';
  }

  @override
  String condWeekly(String day, String time) {
    return '$day · $time';
  }

  @override
  String get condWifi => 'Solo WiFi';

  @override
  String get condAnyNetwork => 'WiFi y datos';

  @override
  String get condBattery => 'Cargando o >15 %';

  @override
  String get autoBackupOff => 'Copia automática desactivada';

  @override
  String get backupSettings => 'Ajustes de copia';

  @override
  String get activity => 'Actividad';

  @override
  String itemsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos guardados',
      one: '1 elemento guardado',
    );
    return '$_temp0';
  }

  @override
  String incompleteWithFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fallos',
      one: '1 fallo',
    );
    return 'Copia incompleta · $_temp0';
  }

  @override
  String get backupCancelled => 'Copia cancelada';

  @override
  String get backupRunning => 'Copia en curso';

  @override
  String get navProfile => 'Perfil';

  @override
  String get edit => 'Editar';

  @override
  String storageOf(String used, String total) {
    return '$used de $total';
  }

  @override
  String elementsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'elementos',
      one: 'elemento',
    );
    return '$_temp0';
  }

  @override
  String albumsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'álbumes',
      one: 'álbum',
    );
    return '$_temp0';
  }

  @override
  String devicesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dispositivos',
      one: 'dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get sectionBackupSpace => 'Copia y espacio';

  @override
  String get sectionApp => 'Aplicación';

  @override
  String dailyAt(String time) {
    return 'Diaria a las $time';
  }

  @override
  String weeklyAt(String day, String time) {
    return '$day a las $time';
  }

  @override
  String linkedDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinculados',
      one: '1 vinculado',
      zero: 'Ninguno vinculado',
    );
    return '$_temp0';
  }

  @override
  String get trashAutoEmpty => 'Se vacía a los 30 días';

  @override
  String get notifOnlyFailures => 'Solo fallos';

  @override
  String get notifOnlySuccess => 'Solo al terminar';

  @override
  String get notifAll => 'Todas';

  @override
  String get notifOff => 'Desactivadas';

  @override
  String get sectionData => 'Datos';

  @override
  String get sectionPassword => 'Contraseña';

  @override
  String get gallerySource => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get thisDevice => 'Este móvil';

  @override
  String get emptyTrashShort => 'Vaciar';

  @override
  String get trashInfo => 'Se borran para siempre a los 30 días. Mantén pulsado para restaurar varios.';

  @override
  String get deletingSoon => 'Se borran pronto';

  @override
  String get thisMonth => 'Este mes';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: 'Hoy',
    );
    return '$_temp0';
  }

  @override
  String get deleteForever => 'Eliminar para siempre';

  @override
  String deletesIn(String time) {
    return 'Se borra en $time';
  }

  @override
  String selectedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get autoBackupBody => 'Tus fotos nuevas se guardan solas';

  @override
  String get sectionWhen => 'Cuándo';

  @override
  String get everyDay => 'Cada día';

  @override
  String get oncePerWeek => 'Una vez por semana';

  @override
  String get day => 'Día';

  @override
  String get time => 'Hora';

  @override
  String nextBackup(String when) {
    return 'Próxima copia: $when';
  }

  @override
  String get sectionConditions => 'Condiciones';

  @override
  String get network => 'Red';

  @override
  String get battery => 'Batería';

  @override
  String get always => 'Siempre';

  @override
  String get sectionAlerts => 'Avisos';

  @override
  String get alertSuccess => 'Al terminar bien';

  @override
  String get alertSuccessBody => 'Un aviso con lo que se guardó';

  @override
  String get alertFailure => 'Si algo falla';

  @override
  String get alertFailureBody => 'Para que puedas reintentarlo';

  @override
  String get sectionDiagnostics => 'Diagnóstico';

  @override
  String manageQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Qué hacemos con estas $count fotos?',
      one: '¿Qué hacemos con esta foto?',
    );
    return '$_temp0';
  }

  @override
  String photosSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos seleccionadas',
      one: '1 foto seleccionada',
    );
    return '$_temp0';
  }

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get optSaveFree => 'Guardar y liberar espacio';

  @override
  String get optSaveFreeBody => 'Se guardan en tu nube y se borran del móvil.';

  @override
  String get recommended => 'Recomendado';

  @override
  String get optSaveKeep => 'Guardar y mantener en el móvil';

  @override
  String get optSaveKeepBody => 'Tendrás una copia en la nube y otra aquí.';

  @override
  String get optAlbum => 'Guardar en un álbum';

  @override
  String get optAlbumBody => 'Elige uno existente o crea uno nuevo.';

  @override
  String get newAlbumChip => 'Nuevo';

  @override
  String get deleteAfterSaving => 'Borrar del móvil después';

  @override
  String get deleteEverywhere => 'Eliminar de todas partes';

  @override
  String saveToAlbum(String album) {
    return 'Guardar en $album';
  }

  @override
  String get chooseAlbum => 'Elige un álbum';

  @override
  String get actionToAlbum => 'A un álbum';

  @override
  String get actionFreeUp => 'Liberar';

  @override
  String get freeUpTitle => '¿Liberar espacio del móvil?';

  @override
  String freeUpBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count fotos se guardarán en tu nube y se borrarán de este móvil.',
      one: 'La foto se guardará en tu nube y se borrará de este móvil.',
    );
    return '$_temp0';
  }

  @override
  String deleteFilesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count fotos?',
      one: '¿Eliminar esta foto?',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesBody => 'Se borrarán de tu nube y de este móvil. Podrás recuperarlas desde la papelera durante 30 días.';

  @override
  String get preparingBackup => 'Preparando la copia…';

  @override
  String get lookingForPhotos => 'Buscando fotos nuevas';

  @override
  String get finishingBackup => 'Terminando la copia…';

  @override
  String get cancellingBackup => 'Cancelando…';

  @override
  String remainingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan unos $count min',
      one: 'Queda alrededor de 1 min',
    );
    return '$_temp0';
  }

  @override
  String get remainingLessThanMinute => 'Queda menos de un minuto';

  @override
  String get backgroundInfo => 'Puedes salir de la app: la copia sigue en segundo plano y te avisaremos al terminar.';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get seeLess => 'Ver menos';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get welcomeGeneric => 'Te damos la bienvenida';

  @override
  String get permissionsHeadline => 'Tres permisos y empezamos';

  @override
  String get permissionsBody => 'Así podremos guardar tus fotos de forma automática y avisarte cuando termine cada copia.';

  @override
  String get permPhotosTitle => 'Fotos y vídeos';

  @override
  String get permPhotosBody => 'Para copiarlas y liberar espacio';

  @override
  String get permNotifTitle => 'Notificaciones';

  @override
  String get permNotifBody => 'Te avisamos al terminar o si falla';

  @override
  String get permBgTitle => 'Segundo plano';

  @override
  String get permBgBody => 'Copias con la app cerrada';

  @override
  String get allow => 'Permitir';

  @override
  String get done => 'Listo';

  @override
  String get permSettings => 'Ajustes';

  @override
  String get privacyNote => 'Tus fotos son privadas. Puedes cambiar estos permisos cuando quieras desde Perfil.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get later => 'Hacerlo más tarde';

  @override
  String get continueAnyway => 'Continuar igualmente';

  @override
  String get reviewPermissions => 'Revisar permisos';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Automática';

  @override
  String get themeSystemHint => 'Sigue el modo de tu teléfono';

  @override
  String get themeLight => 'Clara';

  @override
  String get themeDark => 'Oscura';

  @override
  String deviceLastBackup(String os, String when) {
    return '$os · Última copia $when';
  }

  @override
  String photosSelectedSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos · ocupan $size',
      one: '1 foto · ocupa $size',
    );
    return '$_temp0';
  }

  @override
  String freeUpSize(String size) {
    return 'Liberar $size';
  }

  @override
  String get filePropertyName => 'Nombre';

  @override
  String get filePropertyUploadedAt => 'Fecha de subida';

  @override
  String get filePropertySize => 'Tamaño';

  @override
  String get filePropertyDimensions => 'Dimensiones';

  @override
  String get filePropertyAlbum => 'Álbum';

  @override
  String get filePropertyDevice => 'Dispositivo';

  @override
  String get fileInfoLoading => 'Cargando detalles…';
}
