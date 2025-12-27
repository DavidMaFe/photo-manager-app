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
  String get gallery => 'Galería';

  @override
  String get all => 'Todos';

  @override
  String get photos => 'Fotos';

  @override
  String get videos => 'Vídeos';

  @override
  String get pending => 'Pendientes';

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
