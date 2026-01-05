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
  String get logoutButton => 'Salir';

  @override
  String get logoutConfirmation => '¿Estás seguro de que quieres salir?';

  @override
  String get forgotPassword => '¿Has olvidado tú contraseña?';

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
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get errorNameRequired => 'El nombre es requerido';

  @override
  String get errorConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get errorPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get registerButton => 'Crear Cuenta';

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
  String get noFolders => 'No tienes ninguna carpeta. Crea una nueva.';

  @override
  String get selectFolder => 'Selecciona una carpeta';

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
  String get saveInFolderTitle => 'A carpeta';

  @override
  String get saveInFolderSubtitle => 'Guardar en carpeta';

  @override
  String get deleteBothTitle => 'Eliminar todo';

  @override
  String get deleteBothSubtitle => 'Eliminar de todos los lugares';

  @override
  String get advancedOptionsTitle => 'OPCIONES AVANZADAS';

  @override
  String get nameFolder => 'Nombre de la carpeta';

  @override
  String get saveInRootTitle => 'Guardar en raíz';

  @override
  String get saveInRootSubtitle => 'Sin carpeta específica';

  @override
  String get moveToFolderTitle => 'Mover a carpeta existente';

  @override
  String get moveToFolderSubtitle => 'Selecciona una carpeta';

  @override
  String get newFolderTitle => 'Crear una nueva carpeta';

  @override
  String get newFolderSubtitle => 'Escribe el nombre de la carpeta';

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
  String get selectAll => 'Seleccionar todo';

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
  String correctManage(Object files) {
    return '$files archivos gestionados correctamente.\n';
  }

  @override
  String failedManage(Object files) {
    return '$files archivos fallidos.';
  }

  @override
  String get selectFolderError => 'Debes seleccionar una carpeta';

  @override
  String get newFolderNameError => 'Debes escribir un nombre para la nueva carpeta';

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
  String get foldersTitle => 'Carpetas';

  @override
  String get folder => 'Carpeta';

  @override
  String get subfolders => 'Subcarpetas';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String get folderName => 'Nombre de la carpeta';

  @override
  String get hintFolderName => 'Ex: Vacaciones 2024';

  @override
  String get folderNameRequiredError => 'El nombre es obligatorio';

  @override
  String get folderMaxHundredCharactersError => 'Máximo 100 caracteres';

  @override
  String get renameFolder => 'Renombrar carpeta';

  @override
  String get newName => 'Nuevo nombre';

  @override
  String get creatingFolder => 'Creando carpeta...';

  @override
  String get renamingFolder => 'Renombrando carpeta...';

  @override
  String get deletingFolder => 'Eliminando carpeta...';

  @override
  String get processing => 'Procesando...';

  @override
  String get emptyFolders => 'No tienes carpetas';

  @override
  String get emptyFolder => 'Esta carpeta está vacía';

  @override
  String get emptyFolderDescription => 'Mueve archivos aquí para organizarlos';

  @override
  String get createFirstFolder => 'Toca el botón + para crear tu primera carpeta';

  @override
  String get deleteFolder => 'Eliminar carpeta';

  @override
  String deleteEmptyFolder(Object folderName) {
    return '¿Estás seguro de que quieres eliminar la carpeta $folderName?';
  }

  @override
  String deleteFolderWithFiles(Object files, Object folderName) {
    return 'La carpeta $folderName contiene $files archivos. ¿Estás seguro de que quieres eliminar todo el contenido?';
  }

  @override
  String deleteFolderWithSubfolders(Object folderName, Object subfolders) {
    return 'La carpeta $folderName contiene $subfolders carpetas. ¿Estás seguro de que quieres eliminar todo el contenido?';
  }

  @override
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders) {
    return 'La carpeta $folderName contiene $files archivos y $subfolders carpetas. ¿Estás seguro de que quieres eliminar todo el contenido?';
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
  String get synchronized => 'Sicronizado';

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
  String get cancel => 'Cancelar';

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
  String get syncSettings => 'Ajustes de sincronización';

  @override
  String get syncSettingsSubtitle => 'Sincronización automática cada 6 horas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Gestionar notificaciones';

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
}
