import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

// BORRADOR: los términos y la política de privacidad deben revisarse por un abogado antes de abrir la app a otros
// usuarios. Los datos entre corchetes se completan entonces.
//
// Al cambiar los términos o la política, sube su versión en LegalVersions y en app.legal.* del backend.

const String _controller = '[NOMBRE DEL RESPONSABLE]';
const String _contactEmail = '[EMAIL DE CONTACTO]';
const String _serverProvider = '[PROVEEDOR DEL SERVIDOR]';

final Map<LegalDocumentType, LegalDocument> legalDocumentsEs = {
  LegalDocumentType.protection: const LegalDocument(
    type: LegalDocumentType.protection,
    title: 'Cómo protegemos tus fotos',
    sections: [
      LegalSection(blocks: [
        LegalParagraph('Photo Manager cifra tus fotos y vídeos de extremo a extremo. Se cifran en tu móvil antes de '
            'subirlos y solo se descifran en tus dispositivos. Nadie más puede verlos: ni nosotros, ni el '
            'administrador del servidor, ni los proveedores donde se guardan.'),
      ]),
      LegalSection(heading: 'Cómo funciona', blocks: [
        LegalBullets([
          'Al crear la cuenta, tu móvil genera una clave maestra que protege todos tus archivos.',
          'Esa clave se guarda en el servidor cifrada con tu contraseña. El servidor nunca recibe tu contraseña: tu '
              'móvil la convierte en una clave de acceso que no sirve para descifrar nada.',
          'Tu móvil también genera una clave de recuperación, que te mostramos como 24 palabras. Es la copia de '
              'seguridad de tu clave maestra.',
          'Cada dispositivo con la sesión iniciada guarda la clave maestra en su almacenamiento seguro.',
        ]),
      ]),
      LegalSection(heading: 'Lo que no podemos ver', blocks: [
        LegalBullets([
          'El contenido de tus fotos y vídeos, ni sus miniaturas.',
          'Los nombres originales de los archivos.',
          'Los datos EXIF, como la cámara o la ubicación GPS.',
          'Tu contraseña y tus 24 palabras.',
        ]),
      ]),
      LegalSection(heading: 'Lo que sí vemos', blocks: [
        LegalParagraph('Para que la app funcione, el servidor necesita algunos datos sin cifrar:'),
        LegalBullets([
          'Tu email, nombre y apellidos, y tu imagen de perfil si la añades.',
          'De cada archivo: si es foto o vídeo, su tamaño, la fecha en que se hizo y la de subida, sus dimensiones y '
              'la duración de los vídeos.',
          'Cómo los organizas: álbumes y sus nombres, favoritos, papelera y portadas.',
          'Una huella cifrada de cada archivo, que sirve para detectar duplicados sin conocer su contenido.',
        ]),
      ]),
      LegalSection(heading: 'La otra cara del cifrado', blocks: [
        LegalParagraph('Como no tenemos tus claves, no podemos recuperar tus fotos por ti. Si olvidas tu '
            'contraseña, necesitarás tus 24 palabras o un dispositivo con la sesión iniciada. Consulta "Si olvidas tu '
            'contraseña" y "Las 24 palabras".'),
      ]),
    ],
  ),
  LegalDocumentType.forgotPassword: const LegalDocument(
    type: LegalDocumentType.forgotPassword,
    title: 'Si olvidas tu contraseña',
    sections: [
      LegalSection(blocks: [
        LegalParagraph('Tu contraseña protege la clave que descifra tus fotos. Por eso, cambiarla sin conocerla '
            'depende de lo que tengas a mano. Hay tres situaciones:'),
      ]),
      LegalSection(heading: '1. Tienes otro dispositivo con la sesión iniciada', blocks: [
        LegalParagraph('En ese dispositivo, ve a Perfil > Seguridad > "He olvidado mi contraseña". Te pedirá la '
            'huella o el PIN del dispositivo y podrás poner una contraseña nueva.'),
        LegalParagraph('No pierdes nada: todas tus fotos siguen accesibles.'),
      ]),
      LegalSection(heading: '2. Tienes tus 24 palabras', blocks: [
        LegalParagraph('En la pantalla de inicio de sesión, pulsa "¿Has olvidado tu contraseña?". Recibirás un '
            'código por email. Después, introduce tus 24 palabras y elige una contraseña nueva.'),
        LegalParagraph('No pierdes nada: todas tus fotos siguen accesibles.'),
      ]),
      LegalSection(heading: '3. No tienes ninguna de las dos cosas', blocks: [
        LegalParagraph('Puedes cambiar la contraseña con el código del email, pero las fotos que ya tenías quedan '
            'bloqueadas: nadie puede descifrarlas sin la clave antigua.'),
        LegalBullets([
          'Tus fotos bloqueadas no se borran. Se conservan mientras exista tu cuenta.',
          'Puedes seguir usando la app y subir fotos nuevas con una clave nueva.',
          'Si más adelante encuentras tus 24 palabras o un dispositivo con la sesión iniciada, podrás desbloquearlas '
              'desde Perfil > Seguridad > "Recuperar fotos bloqueadas".',
        ]),
      ]),
      LegalSection(heading: 'Para no llegar a la situación 3', blocks: [
        LegalBullets([
          'Guarda tus 24 palabras en un lugar seguro nada más crear la cuenta.',
          'Responde a los recordatorios que te pedirán comprobarlas de vez en cuando.',
          'Si puedes, mantén la sesión iniciada en más de un dispositivo.',
        ]),
      ]),
    ],
  ),
  LegalDocumentType.recoveryWords: const LegalDocument(
    type: LegalDocumentType.recoveryWords,
    title: 'Las 24 palabras',
    sections: [
      LegalSection(heading: 'Qué son', blocks: [
        LegalParagraph('Son tu clave de recuperación escrita como 24 palabras. Con ellas se puede abrir la clave que '
            'descifra tus fotos sin tu contraseña. Las genera tu móvil al crear la cuenta y nunca salen de él sin '
            'cifrar: nosotros no las conocemos.'),
      ]),
      LegalSection(heading: 'Por qué son tan importantes', blocks: [
        LegalParagraph('Si olvidas tu contraseña y no tienes otro dispositivo con la sesión iniciada, las 24 palabras '
            'son la única forma de recuperar tus fotos. Ni nosotros ni nadie puede generarlas de nuevo ni '
            'recuperarlas por ti.'),
      ]),
      LegalSection(heading: 'Cómo guardarlas', blocks: [
        LegalBullets([
          'En el gestor de contraseñas de Google, con el botón que te ofrecemos al crear la cuenta.',
          'En el PDF que puedes descargar, guardado en un lugar seguro o impreso.',
          'Escritas a mano en papel, guardado en casa.',
          'Mejor en dos sitios distintos.',
        ]),
        LegalParagraph('Evita las capturas de pantalla sin protección y no se las des a nadie. Quien tenga tus 24 '
            'palabras y acceso a tu email podría cambiar tu contraseña.'),
      ]),
      LegalSection(heading: 'Cuándo se usan', blocks: [
        LegalBullets([
          'Al restablecer la contraseña con el código del email.',
          'Para desbloquear fotos que quedaron bloqueadas tras cambiar la contraseña sin ellas.',
        ]),
      ]),
      LegalSection(heading: 'Recordatorios', blocks: [
        LegalParagraph('A los 2 días de crear la cuenta, a las 2 semanas y después cada 3 meses, la app te pedirá '
            'algunas palabras para comprobar que sigues teniéndolas. En el móvil donde se crearon también puedes '
            'verlas en Perfil > Seguridad > "Mis 24 palabras".'),
      ]),
    ],
  ),
  LegalDocumentType.terms: const LegalDocument(
    type: LegalDocumentType.terms,
    title: 'Términos y condiciones de uso',
    version: LegalVersions.terms,
    sections: [
      LegalSection(heading: '1. El servicio', blocks: [
        LegalParagraph('Photo Manager es un servicio para guardar una copia de seguridad de tus fotos y vídeos y '
            'organizarlos. Lo presta $_controller ("nosotros"). Al crear una cuenta aceptas estos términos y la '
            'Política de privacidad.'),
      ]),
      LegalSection(heading: '2. Tu cuenta', blocks: [
        LegalBullets([
          'Debes tener al menos 14 años. Si eres menor, necesitas el permiso de tus padres o tutores.',
          'Los datos de tu cuenta deben ser ciertos y el email debe ser tuyo.',
          'La cuenta es personal. Eres responsable de lo que se haga con ella.',
        ]),
      ]),
      LegalSection(heading: '3. Cifrado de extremo a extremo', blocks: [
        LegalParagraph('Tus fotos y vídeos se cifran en tu dispositivo antes de subirlos. No conocemos tu '
            'contraseña, tus 24 palabras ni las claves que descifran tus archivos, así que no podemos ver tus '
            'archivos ni recuperarlos por ti.'),
        LegalParagraph('Solo puedes acceder a tus archivos con al menos una de estas tres cosas: tu contraseña, tus 24 '
            'palabras o un dispositivo con la sesión iniciada.'),
      ]),
      LegalSection(heading: '4. Tus responsabilidades', blocks: [
        LegalBullets([
          'Guardar tus 24 palabras en un lugar seguro y no compartirlas.',
          'No compartir tu contraseña y proteger tus dispositivos con un bloqueo de pantalla.',
          'Conservar otra copia de los archivos que no te puedas permitir perder.',
        ]),
      ]),
      LegalSection(heading: '5. Archivos bloqueados y exención de responsabilidad', blocks: [
        LegalParagraph('Si pierdes a la vez tu contraseña, tus 24 palabras y el acceso a todos tus dispositivos con '
            'sesión, tus archivos quedarán bloqueados y nadie, tampoco nosotros, podrá descifrarlos.'),
        LegalParagraph('Los archivos bloqueados no se borran. Se conservan mientras exista tu cuenta, y podrás '
            'desbloquearlos si recuperas tus 24 palabras o un dispositivo con la sesión iniciada.'),
        LegalParagraph('En la medida en que lo permita la ley, no somos responsables de la pérdida de acceso ni de '
            'la imposibilidad de recuperar tus archivos cuando se deba a que no tienes tu contraseña, tus 24 '
            'palabras ni un dispositivo con sesión.'),
      ]),
      LegalSection(heading: '6. Uso aceptable', blocks: [
        LegalParagraph('Como no podemos ver tus archivos, eres el único responsable de su contenido. No puedes usar '
            'el servicio para guardar contenido ilegal ni que infrinja derechos de otras personas, ni para atacarlo, '
            'sobrecargarlo o acceder a cuentas ajenas. Podemos suspender las cuentas que incumplan estos términos.'),
      ]),
      LegalSection(heading: '7. Espacio y papelera', blocks: [
        LegalBullets([
          'Cada cuenta tiene un espacio máximo, que puedes consultar en la app.',
          'Los archivos que envías a la papelera se borran definitivamente a los 30 días.',
        ]),
      ]),
      LegalSection(heading: '8. Disponibilidad', blocks: [
        LegalParagraph('Hacemos lo posible para que el servicio esté disponible y sus datos protegidos, con copias '
            'de seguridad cifradas, pero no podemos garantizar que funcione siempre sin interrupciones ni errores.'),
      ]),
      LegalSection(heading: '9. Baja', blocks: [
        LegalParagraph('Puedes pedir que borremos tu cuenta escribiendo a $_contactEmail desde el email de la '
            'cuenta. La borraremos, junto con tus archivos y claves, en un plazo máximo de 30 días. Las copias de '
            'seguridad cifradas pueden conservarlos 30 días más.'),
      ]),
      LegalSection(heading: '10. Cambios en los términos', blocks: [
        LegalParagraph('Si cambiamos estos términos, publicaremos una versión nueva y la app te pedirá aceptarla '
            'la próxima vez que inicies sesión.'),
      ]),
      LegalSection(heading: '11. Tus derechos como consumidor', blocks: [
        LegalParagraph('Nada de lo anterior limita los derechos que te reconoce la legislación de consumo ni nuestra '
            'responsabilidad en caso de dolo o negligencia grave.'),
      ]),
      LegalSection(heading: '12. Ley aplicable y contacto', blocks: [
        LegalParagraph('Estos términos se rigen por la ley española. Si eres consumidor, son competentes los '
            'tribunales de tu domicilio. Para cualquier consulta, escribe a $_contactEmail.'),
      ]),
    ],
  ),
  LegalDocumentType.privacy: const LegalDocument(
    type: LegalDocumentType.privacy,
    title: 'Política de privacidad',
    version: LegalVersions.privacy,
    sections: [
      LegalSection(heading: '1. Responsable', blocks: [
        LegalParagraph('El responsable del tratamiento de tus datos es $_controller. Puedes contactar escribiendo a '
            '$_contactEmail.'),
      ]),
      LegalSection(heading: '2. Datos que tratamos', blocks: [
        LegalBullets([
          'Cuenta: email, nombre, apellidos y, si la añades, imagen de perfil.',
          'Datos de tus archivos que no van cifrados: tipo (foto o vídeo), tamaño, fecha de captura y de subida, '
              'dimensiones y duración; álbumes y sus nombres, favoritos, papelera y portadas; y una huella cifrada '
              'para detectar duplicados.',
          'Dispositivos: nombre, modelo, sistema operativo, versión de la app e identificador.',
          'Sesión y seguridad: fechas de acceso, tokens de sesión y la dirección IP de las peticiones.',
          'Tus claves, siempre cifradas: el servidor no puede abrirlas.',
          'La versión de los términos y de esta política que aceptaste, y la fecha.',
        ]),
      ]),
      LegalSection(heading: '3. Lo que no podemos ver', blocks: [
        LegalParagraph('El contenido de tus fotos y vídeos, sus miniaturas, los nombres originales, los datos EXIF y la '
            'ubicación GPS van cifrados de extremo a extremo. Tampoco recibimos tu contraseña ni tus 24 palabras.'),
      ]),
      LegalSection(heading: '4. Para qué y con qué base legal', blocks: [
        LegalBullets([
          'Prestarte el servicio: guardar, organizar y sincronizar tus archivos y enviarte los códigos para '
              'restablecer la contraseña. Base: la ejecución del contrato (art. 6.1.b del RGPD).',
          'Proteger el servicio y evitar abusos, por ejemplo limitando los intentos por dirección IP. Base: nuestro '
              'interés legítimo (art. 6.1.f).',
          'Cumplir obligaciones legales. Base: la obligación legal (art. 6.1.c).',
        ]),
        LegalParagraph('No usamos tus datos para publicidad ni los vendemos.'),
      ]),
      LegalSection(heading: '5. Dónde están tus datos y quién nos ayuda', blocks: [
        LegalBullets([
          'Servidor de la aplicación: $_serverProvider, en la Unión Europea.',
          'Archivos cifrados: Cloudflare R2, con los datos en la jurisdicción de la Unión Europea.',
          'Copias de seguridad cifradas: Backblaze B2, en una región de la Unión Europea.',
          'Emails (códigos para restablecer la contraseña): Google (Gmail).',
        ]),
        LegalParagraph('Cloudflare, Backblaze y Google son empresas de Estados Unidos. Cuando acceden a datos desde '
            'fuera de la Unión Europea, la transferencia se ampara en el Marco de Privacidad de Datos UE-EE. UU. o en '
            'las cláusulas contractuales tipo de la Comisión Europea.'),
      ]),
      LegalSection(heading: '6. Cuánto tiempo los conservamos', blocks: [
        LegalBullets([
          'Mientras tengas la cuenta.',
          'Los archivos de la papelera se borran a los 30 días.',
          'Los tokens de sesión caducan a los 30 días.',
          'Si pides la baja, borramos tus datos en un plazo máximo de 30 días; las copias de seguridad cifradas los '
              'conservan 30 días más.',
        ]),
      ]),
      LegalSection(heading: '7. Tus derechos', blocks: [
        LegalParagraph('Puedes ejercer tus derechos de acceso, rectificación, supresión, oposición, limitación del '
            'tratamiento y portabilidad escribiendo a $_contactEmail desde el email de tu cuenta.'),
        LegalParagraph('Si crees que no hemos tratado bien tus datos, puedes reclamar ante la Agencia Española de '
            'Protección de Datos (www.aepd.es).'),
      ]),
      LegalSection(heading: '8. Seguridad', blocks: [
        LegalParagraph('Además del cifrado de extremo a extremo, las comunicaciones van cifradas (HTTPS) y las claves '
            'de acceso se guardan como hashes que no se pueden revertir.'),
      ]),
      LegalSection(heading: '9. Menores', blocks: [
        LegalParagraph('El servicio no está dirigido a menores de 14 años.'),
      ]),
      LegalSection(heading: '10. Cambios en esta política', blocks: [
        LegalParagraph('Si cambiamos esta política, publicaremos una versión nueva y la app te pedirá aceptarla la '
            'próxima vez que inicies sesión.'),
      ]),
    ],
  ),
};
