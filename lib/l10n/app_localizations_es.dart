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
  String get welcome => 'Bienvenido';

  @override
  String get loginTitle => 'Iniciar Sesión';

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
  String get notHaveAccount => '¿No tienes cuenta? ';

  @override
  String get signUp => 'Regístrate';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get accountCreated => '¡Cuenta creada! Por favor inicia sesión';

  @override
  String get registerTitle => 'Regístrate para comenzar';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get namePlaceholder => 'Juan';

  @override
  String get surnameLabel => 'Apellido (opcional)';

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
  String get pendingSingular => 'Pendiente';

  @override
  String get pendingPlural => 'Pendientes';

  @override
  String get pendingFilesInfoSingle => 'Tienes 1 archivo pendiente de gestionar';

  @override
  String pendingFilesInfo(Object files) {
    return 'Tienes $files archivos pendientes de gestionar';
  }

  @override
  String get noFiles => 'No hay archivos que mostrar';

  @override
  String get syncToHaveFiles => 'Sincroniza tus dispositivos para ver tus archivos';

  @override
  String get selectedFilesSingle => '1 seleccionado';

  @override
  String selectedFiles(Object files) {
    return '$files seleccionados';
  }

  @override
  String selectedFilesWithLimit(int count) {
    return '$count / 100 seleccionados';
  }

  @override
  String get selectionLimitReached => 'Solo puedes seleccionar hasta 100 archivos a la vez.';

  @override
  String get noFolders => 'No tienes ningún álbum. Crea uno nuevo.';

  @override
  String get selectFolder => 'Selecciona un álbum';

  @override
  String get quickActionsTitle => 'ACCIONES RÁPIDAS';

  @override
  String get saveAndKeepTitle => 'Guardar';

  @override
  String get saveAndKeepSubtitle => 'Guardar y mantener en dispositivo';

  @override
  String get saveAndDeleteTitle => 'Guardar y liberar espacio';

  @override
  String get saveAndDeleteSubtitle => 'Guardar y eliminar del dispositivo';

  @override
  String get saveInFolderTitle => 'A un álbum';

  @override
  String get saveInFolderSubtitle => 'Guardar en un álbum';

  @override
  String get deleteBothTitle => 'Eliminar todo';

  @override
  String get deleteBothSubtitle => 'Eliminar de todos los lugares';

  @override
  String get advancedOptionsTitle => 'OPCIONES AVANZADAS';

  @override
  String get nameFolder => 'Nombre del álbum';

  @override
  String get saveInRootTitle => 'Guardar en raíz';

  @override
  String get saveInRootSubtitle => 'Sin álbum específico';

  @override
  String get moveToFolderTitle => 'Mover a un álbum existente';

  @override
  String get moveToFolderSubtitle => 'Selecciona un álbum';

  @override
  String get newFolderTitle => 'Nuevo álbum';

  @override
  String get newFolderSubtitle => 'Escribe el nombre del álbum';

  @override
  String get deleteTitle => 'Borrar del servidor';

  @override
  String get deleteSubtitle => 'Esta acción es permanente';

  @override
  String get keepInDeviceTitle => 'Mantener el archivo en mi dispositivo';

  @override
  String get keepInDeviceSubtitle => 'El archivo seguirá ocupando espacio local';

  @override
  String get deleteFromDeviceDescription => 'El archivo se eliminará de tu dispositivo pero seguirá en el servidor';

  @override
  String manageMultipleFiles(Object files) {
    return '$files archivos';
  }

  @override
  String get manageSingleFile => '1 archivo';

  @override
  String get sameActionWarning => 'La misma acción se aplicará a todos los ficheros seleccionados';

  @override
  String applyMultiple(Object files) {
    return 'Aplicar a $files';
  }

  @override
  String get applySingle => 'Aplicar';

  @override
  String get selectAction => 'Por favor, selecciona una acción';

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
  String get selectFolderError => 'Debes seleccionar un álbum';

  @override
  String get newFolderNameError => 'Debes escribir un nombre para el nuevo álbum';

  @override
  String get invalidActionError => 'Acción inválida';

  @override
  String fileCountLabel(Object currentFile, Object totalFiles) {
    return '$currentFile de $totalFiles';
  }

  @override
  String get fileTypeNotSupported => 'Tipo de archivo no soportado';

  @override
  String get timePassedInMinutesSingular => 'Hace 1 minuto';

  @override
  String timePassedInMinutesPlural(Object minutes) {
    return 'Hace $minutes minutos';
  }

  @override
  String get timePassedInHoursSingular => 'Hace 1 hora';

  @override
  String timePassedInHoursPlural(Object hours) {
    return 'Hace $hours horas';
  }

  @override
  String get timePassedInDaysSingular => 'Hace 1 día';

  @override
  String timePassedInDaysPlural(Object days) {
    return 'Hace $days días';
  }

  @override
  String get fileProperties => 'Propiedades del archivo';

  @override
  String get filePropertyType => 'Tipo';

  @override
  String get filePropertyTypeImage => 'Imagen';

  @override
  String get filePropertyTypeVideo => 'Vídeo';

  @override
  String get filePropertyStatus => 'Estado';

  @override
  String get filePropertyStatusManaged => 'Gestionado';

  @override
  String get filePropertyStatusPending => 'Pendiente';

  @override
  String get filePropertyCapturedAt => 'Fecha de captura';

  @override
  String get filePropertyDuration => 'Duración';

  @override
  String get fileDetailManageFile => 'Gestionar';

  @override
  String get fileShare => 'Compartir archivo';

  @override
  String get fileDownload => 'Descargar archivo';

  @override
  String get loadingVideoError => 'Error al cargar el vídeo';

  @override
  String get foldersTitle => 'Álbumes';

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
  String get syncCurrentState => 'Estado actual';

  @override
  String get syncLast => 'Última sincronización';

  @override
  String get syncEmpty => 'Sin sincronizaciones';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get synchronized => 'Sincronizado';

  @override
  String get syncPending => 'Pendiente';

  @override
  String syncFiles(Object syncFiles) {
    return '$syncFiles archivos sincronizados';
  }

  @override
  String get notSyncYet => 'Aún no has sincronizado';

  @override
  String get syncStart => 'Presiona el botón de sincronizar para empezar';

  @override
  String get syncErrorLoad => 'Error al cargar las sincronizaciones';

  @override
  String get syncHistoric => 'Historial Reciente';

  @override
  String get syncSessionTitle => 'Sincronización';

  @override
  String get syncSessionInit => 'Iniciando sincronización...';

  @override
  String get syncSessionConnecting => 'Conectando con el servidor';

  @override
  String get syncSessionFetchingFiles => 'Obteniendo archivos de la galería...';

  @override
  String get syncSessionWaitWarning => 'Esto puede tardar unos segundos';

  @override
  String get syncSessionUploadingFiles => 'Subiendo archivos...';

  @override
  String syncSessionFiles(Object totalFiles, Object uploadedFiles) {
    return '$uploadedFiles/$totalFiles archivos';
  }

  @override
  String get syncSessionCancel => 'Cancelar sincronización';

  @override
  String get syncSessionCancelWarning => '¿Cancelar sincronización?';

  @override
  String get syncSessionCancelDescription => 'Se perderá el progreso actual. Los archivos subidos se mantendrán en el servidor.';

  @override
  String get syncSessionCancelShortDescription => 'La sincronización está en progreso. ¿Deseas cancelar?';

  @override
  String get syncSessionCancelConfirm => 'Sí, cancelar';

  @override
  String get syncSessionCompleting => 'Completando sincronización...';

  @override
  String get syncSessionSave => 'Guardando información';

  @override
  String get syncSessionCompleted => 'Sincronización completada';

  @override
  String get syncSessionFinished => 'Sincronización finalizada';

  @override
  String get syncSessionError => 'Error en la sincronización';

  @override
  String get total => 'Total';

  @override
  String get uploaded => 'Subidos';

  @override
  String get failed => 'Fallidos';

  @override
  String infoFiles(Object info) {
    return '$info archivos';
  }

  @override
  String get goBack => 'Volver';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get emptyNotifications => 'Sin notificaciones';

  @override
  String get noNotificationsYet => 'Aún no tienes notificaciones';

  @override
  String get errorLoadingProfile => 'Error al cargar el perfil';

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
  String get editProfileSubtitle => 'Cambiar nombre y apellidos';

  @override
  String get myDevices => 'Mis dispositivos';

  @override
  String myDevicesSubtitle(Object devices) {
    return '$devices dispositivos vinculados';
  }

  @override
  String get trash => 'Papelera';

  @override
  String get trashSubtitle => 'Ver archivos eliminados';

  @override
  String get syncSettings => 'Ajustes de sincronización';

  @override
  String get syncSettingsSubtitle => 'Sincronización automática cada 6 horas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Gestionar notificaciones';

  @override
  String get trashIsEmpty => 'La papelera está vacía';

  @override
  String get trashEmptyDescription => 'Los archivos eliminados aparecerán aquí y se borrarán permanentemente después de 30 días';

  @override
  String daysRemaining(Object days) {
    return '${days}d';
  }

  @override
  String filesSelected(Object count) {
    return '$count seleccionados';
  }

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
  String deleteFilesPermanently(Object count) {
    return 'Eliminar $count permanentemente';
  }

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
  String get selectAll => 'Seleccionar todo';

  @override
  String get deselectAll => 'Deseleccionar todo';

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
  String get errorUnknownTitle => 'Error Desconocido';

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
  String get errorValidation => 'Los datos proporcionados són inválidos.';

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
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordSubtitle => 'Ingresa tu correo electrónico para recibir un código de verificación';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get emailSentSuccess => 'Código enviado a tu correo electrónico';

  @override
  String get validateCodeTitle => 'Verificar código';

  @override
  String validateCodeSubtitle(String email) {
    return 'Ingresa el código de 6 dígitos enviado a $email';
  }

  @override
  String get codeLabel => 'Código de verificación';

  @override
  String get codePlaceholder => '123456';

  @override
  String get validateCodeButton => 'Verificar código';

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String get codeResent => 'Código reenviado exitosamente';

  @override
  String get errorCodeRequired => 'El código es requerido';

  @override
  String get errorCodeInvalid => 'El código debe tener 6 dígitos';

  @override
  String get resetPasswordTitle => 'Nueva contraseña';

  @override
  String get resetPasswordSubtitle => 'Ingresa tu nueva contraseña';

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
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get currentPasswordPlaceholder => 'Tu contraseña actual';

  @override
  String get errorCurrentPasswordRequired => 'La contraseña actual es requerida';

  @override
  String get errorCurrentPasswordIncorrect => 'La contraseña actual es incorrecta';

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
  String get basicInfoSection => 'Información básica';

  @override
  String get passwordSection => 'Cambiar contraseña';

  @override
  String get leavePasswordEmptyHint => 'Déjala en blanco si no quieres cambiarla';

  @override
  String get savingChanges => 'Guardando cambios...';

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
  String get renameDeviceDescription => 'Introduce un nuevo nombre para tu dispositivo';

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
  String get devicesLoadError => 'No se pudieron cargar los dispositivos';

  @override
  String get retry => 'Reintentar';

  @override
  String get syncConfigurationTitle => 'Configuración de Sincronización';

  @override
  String get syncConfigurationDescription => 'Configura cómo y cuándo se sincronizarán automáticamente tus archivos';

  @override
  String get enableAutoSync => 'Habilitar sincronización automática';

  @override
  String get autoSyncEnabled => 'La sincronización automática está activada';

  @override
  String get autoSyncDisabled => 'La sincronización automática está desactivada';

  @override
  String get syncFrequencyTitle => 'Frecuencia de sincronización';

  @override
  String get syncFrequencyDaily => 'Diariamente';

  @override
  String get syncFrequencyWeekly => 'Semanalmente';

  @override
  String get syncFrequencyAt => 'a las';

  @override
  String get syncTimeTitle => 'Hora de sincronización';

  @override
  String get syncTimeDescription => 'Selecciona la hora a la que deseas que se ejecute la sincronización';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get syncDayOfWeekTitle => 'Día de la semana';

  @override
  String get syncDayOfWeekDescription => 'Selecciona el día en el que deseas que se ejecute la sincronización';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get networkPreferenceTitle => 'Preferencia de red';

  @override
  String get networkPreferenceWifiOnly => 'Solo WiFi';

  @override
  String get networkPreferenceWifiOnlyDescription => 'La sincronización solo se ejecutará cuando estés conectado a WiFi';

  @override
  String get networkPreferenceAnyNetwork => 'Cualquier red';

  @override
  String get networkPreferenceAnyNetworkDescription => 'La sincronización se ejecutará en WiFi o datos móviles';

  @override
  String get batteryPreferenceTitle => 'Preferencia de batería';

  @override
  String get batteryPreferenceAny => 'Cualquier nivel de batería';

  @override
  String get batteryPreferenceAnyDescription => 'La sincronización se ejecutará sin importar el nivel de batería';

  @override
  String get batteryPreferenceCharging => 'Cargando o batería >15%';

  @override
  String get batteryPreferenceChargingDescription => 'La sincronización solo se ejecutará cuando el dispositivo esté cargando o tenga más del 15% de batería';

  @override
  String get notifyOnSuccess => 'Notificar cuando la sincronización sea exitosa';

  @override
  String get notifyOnSuccessDescription => 'Recibirás una notificación cuando la sincronización se complete correctamente';

  @override
  String get notifyOnFailure => 'Notificar cuando la sincronización falle';

  @override
  String get notifyOnFailureDescription => 'Recibirás una notificación cuando la sincronización falle';

  @override
  String get saveConfiguration => 'Guardar configuración';

  @override
  String get savingConfiguration => 'Guardando configuración...';

  @override
  String get configurationSaved => 'Ajustes guardados';

  @override
  String get configurationSavedDescription => 'Tu configuración de sincronización automática ha sido guardada correctamente';

  @override
  String get configurationSaveError => 'Error al guardar la configuración';

  @override
  String get loadingConfiguration => 'Cargando configuración...';

  @override
  String get configurationLoadError => 'Error al cargar la configuración';

  @override
  String get syncInProgressError => 'Sincronización en progreso';

  @override
  String get syncInProgressErrorDescription => 'Ya hay una sincronización en progreso. Por favor, espera a que termine antes de iniciar una nueva.';

  @override
  String get syncInProgressDialogTitle => 'Sincronización en progreso';

  @override
  String get syncInProgressDialogMessage => 'Una sincronización automática está en progreso en segundo plano. Por favor, espera a que termine antes de iniciar una sincronización manual.';

  @override
  String get understood => 'Entendido';

  @override
  String get onboardingWelcomeTitle => '¡Bienvenido a Photo Manager!';

  @override
  String get onboardingWelcomeMessage => 'Para brindarte la mejor experiencia, necesitamos tu permiso para acceder a tus fotos, enviarte notificaciones y ejecutar sincronizaciones automáticas en segundo plano.\n\nEstos permisos nos permiten:\n\n• Sincronizar automáticamente tus fotos y vídeos\n• Mantener tus archivos respaldados de forma segura\n• Notificarte sobre el progreso de la sincronización\n• Ejecutar sincronizaciones mientras la app está cerrada';

  @override
  String get onboardingWelcomeButton => 'Comenzar';

  @override
  String get onboardingGetStarted => 'Empezar configuración';

  @override
  String get permissionNotificationTitle => 'Notificaciones';

  @override
  String get permissionNotificationMessage => 'Te enviaremos notificaciones para informarte sobre el progreso de tus sincronizaciones automáticas y cuando se completen exitosamente o fallen.';

  @override
  String get permissionNotificationContinue => 'Permitir notificaciones';

  @override
  String get permissionNotificationDeniedTitle => 'Notificaciones Deshabilitadas';

  @override
  String get permissionNotificationDeniedMessage => 'Sin permiso de notificaciones, no podrás recibir actualizaciones sobre el estado de tus sincronizaciones. Puedes habilitar las notificaciones más tarde en Configuración.';

  @override
  String get permissionBackgroundTitle => 'Sincronización en Segundo Plano';

  @override
  String get permissionBackgroundMessage => 'Para que la sincronización automática funcione correctamente, la aplicación necesita ejecutarse en segundo plano. Esto permite que tus fotos se sincronicen incluso cuando la app esté cerrada.';

  @override
  String get permissionBackgroundMessageAndroid => 'Para que la sincronización automática funcione correctamente, necesitamos que:\n\n• La aplicación pueda ejecutarse en segundo plano\n• Se desactive la optimización de batería para esta app\n\nEsto permite que tus fotos se sincronicen incluso cuando la app esté cerrada.';

  @override
  String get permissionBackgroundMessageIOS => 'Para que la sincronización automática funcione correctamente, necesitamos que:\n\n• Habilites la actualización en segundo plano\n• Permitas que la app se ejecute en segundo plano\n\nEsto permite que tus fotos se sincronicen incluso cuando la app esté cerrada.';

  @override
  String get permissionBackgroundContinue => 'Permitir sincronización en segundo plano';

  @override
  String get permissionBackgroundDeniedTitle => 'Sincronización en Segundo Plano Deshabilitada';

  @override
  String get permissionBackgroundDeniedMessage => 'Sin permiso para ejecutar en segundo plano, la sincronización automática solo funcionará cuando tengas la aplicación abierta. Puedes habilitar esto más tarde en Configuración.';

  @override
  String get onboardingPermissionsRejectedTitle => 'Algunos Permisos No Fueron Otorgados';

  @override
  String get onboardingPermissionsRejectedMessage => 'Has denegado algunos permisos necesarios. La aplicación funcionará con funcionalidad limitada. Puedes habilitar estos permisos más tarde desde la configuración de la aplicación:';

  @override
  String get onboardingPermissionsRejectedButton => 'Entendido';

  @override
  String get onboardingPermissionsRetryButton => 'Intentar de nuevo';

  @override
  String get permissionLimitationPhoto => '• No podrás sincronizar fotos ni vídeos';

  @override
  String get permissionLimitationNotification => '• No recibirás notificaciones sobre las sincronizaciones';

  @override
  String get permissionLimitationBackground => '• La sincronización automática solo funcionará con la app abierta';

  @override
  String get onboardingPermissionsAllGrantedTitle => '¡Todo Listo!';

  @override
  String get onboardingPermissionsAllGrantedMessage => 'Todos los permisos han sido otorgados correctamente. Ya puedes empezar a usar Photo Manager con todas sus funciones.';

  @override
  String get onboardingPermissionsAllGrantedButton => 'Ir a la galería';

  @override
  String get errorGalleryPermissionTitle => 'Permiso de Galería Requerido';

  @override
  String get errorGalleryPermission => 'La aplicación necesita acceso a tu galería para funcionar. Por favor, habilita el permiso en Configuración.';

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
}
