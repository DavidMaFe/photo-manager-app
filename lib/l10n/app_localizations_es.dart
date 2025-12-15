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
  String get cancel => 'Cancelar';

  @override
  String get forgotPassword => '¿Has olvidado tú contraseña?';

  @override
  String get notHaveAccount => '¿No tienes cuenta? ';

  @override
  String get signUp => 'Regístrate';

  @override
  String get invalidEmail => 'El formato del email es inválido';

  @override
  String get emptyField => 'Este campo no puede estar vacío';

  @override
  String get welcome => 'Bienvenido';

  @override
  String welcomeMessage(Object userName) {
    return 'Hola $userName, bienvenido';
  }

  @override
  String get errorLoadingProfile => 'Error al cargar el perfil';

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
}
