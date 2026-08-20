import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_gl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('gl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'TanApp'**
  String get appTitle;

  /// No description provided for @errorInesperado.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error inesperado'**
  String get errorInesperado;

  /// No description provided for @cuentaDesactivada.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está desactivada. Contacta con el administrador.'**
  String get cuentaDesactivada;

  /// No description provided for @validatorRequiredField.
  ///
  /// In es, this message translates to:
  /// **'{field} es obligatorio'**
  String validatorRequiredField(String field);

  /// No description provided for @validatorEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'El email es obligatorio'**
  String get validatorEmailRequired;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un email válido'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos 8 caracteres'**
  String get validatorPasswordTooShort;

  /// No description provided for @validatorPasswordTooShortEstricta.
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos {minimo} caracteres'**
  String validatorPasswordTooShortEstricta(int minimo);

  /// No description provided for @validatorPasswordSinLetraYNumero.
  ///
  /// In es, this message translates to:
  /// **'Debe combinar letras y números'**
  String get validatorPasswordSinLetraYNumero;

  /// No description provided for @validatorPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get validatorPasswordMismatch;

  /// No description provided for @validatorOtpLength.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código de 6 dígitos'**
  String get validatorOtpLength;

  /// No description provided for @validatorOtpDigitsOnly.
  ///
  /// In es, this message translates to:
  /// **'El código solo contiene números'**
  String get validatorOtpDigitsOnly;

  /// No description provided for @validatorProvinciaRequired.
  ///
  /// In es, this message translates to:
  /// **'La provincia es obligatoria'**
  String get validatorProvinciaRequired;

  /// No description provided for @validatorConcelloRequired.
  ///
  /// In es, this message translates to:
  /// **'El concello es obligatorio'**
  String get validatorConcelloRequired;

  /// No description provided for @confirmDialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmDialogConfirm;

  /// No description provided for @confirmDialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get confirmDialogCancel;

  /// No description provided for @passwordFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordFieldLabel;

  /// No description provided for @passwordRequisitoLongitud.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {minimo} caracteres'**
  String passwordRequisitoLongitud(int minimo);

  /// No description provided for @passwordRequisitoLetraNumero.
  ///
  /// In es, this message translates to:
  /// **'Combina letras y números'**
  String get passwordRequisitoLetraNumero;

  /// No description provided for @fieldNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get fieldNombre;

  /// No description provided for @fieldPrimerApellido.
  ///
  /// In es, this message translates to:
  /// **'Primer apellido'**
  String get fieldPrimerApellido;

  /// No description provided for @fieldSegundoApellidoOpcional.
  ///
  /// In es, this message translates to:
  /// **'Segundo apellido (opcional)'**
  String get fieldSegundoApellidoOpcional;

  /// No description provided for @fieldSegundoApellido.
  ///
  /// In es, this message translates to:
  /// **'Segundo apellido'**
  String get fieldSegundoApellido;

  /// No description provided for @fieldTelefonoOpcional.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get fieldTelefonoOpcional;

  /// No description provided for @fieldTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get fieldTelefono;

  /// No description provided for @fieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldContrasena.
  ///
  /// In es, this message translates to:
  /// **'La contraseña'**
  String get fieldContrasena;

  /// No description provided for @fieldProvincia.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get fieldProvincia;

  /// No description provided for @fieldConcello.
  ///
  /// In es, this message translates to:
  /// **'Concello'**
  String get fieldConcello;

  /// No description provided for @fieldDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección completa'**
  String get fieldDireccion;

  /// No description provided for @fieldNombreEmpresa.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la empresa'**
  String get fieldNombreEmpresa;

  /// No description provided for @comoLlegar.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get comoLlegar;

  /// No description provided for @mapa.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapa;

  /// No description provided for @llamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get llamar;

  /// No description provided for @filtroTodasProvincias.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filtroTodasProvincias;

  /// No description provided for @filtroTodosConcellos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filtroTodosConcellos;

  /// No description provided for @fieldConfirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get fieldConfirmarContrasena;

  /// No description provided for @errorCargarProvincias.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las provincias: {error}'**
  String errorCargarProvincias(String error);

  /// No description provided for @errorCargarConcellos.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los concellos: {error}'**
  String errorCargarConcellos(String error);

  /// No description provided for @googleContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get googleContinuar;

  /// No description provided for @googleConectando.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get googleConectando;

  /// No description provided for @googleRegistrarse.
  ///
  /// In es, this message translates to:
  /// **'Regístrate con Google'**
  String get googleRegistrarse;

  /// No description provided for @o.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get o;

  /// No description provided for @drawerMiCuenta.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get drawerMiCuenta;

  /// No description provided for @drawerDashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get drawerDashboard;

  /// No description provided for @drawerSistema.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get drawerSistema;

  /// No description provided for @drawerConfiguracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get drawerConfiguracion;

  /// No description provided for @drawerCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get drawerCerrarSesion;

  /// No description provided for @drawerCerrarSesionMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar sesión?'**
  String get drawerCerrarSesionMensaje;

  /// No description provided for @loginTagline.
  ///
  /// In es, this message translates to:
  /// **'Información funeraria'**
  String get loginTagline;

  /// No description provided for @loginTaglineCliente.
  ///
  /// In es, this message translates to:
  /// **'Acceso para funerarias y tanatorios'**
  String get loginTaglineCliente;

  /// No description provided for @bienvenidaOpcionParticularTitulo.
  ///
  /// In es, this message translates to:
  /// **'Quiero estar informado'**
  String get bienvenidaOpcionParticularTitulo;

  /// No description provided for @bienvenidaOpcionParticularSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Sigue esquelas, avisos y funerales de tu zona'**
  String get bienvenidaOpcionParticularSubtitulo;

  /// No description provided for @bienvenidaOpcionClienteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Soy una funeraria o tanatorio'**
  String get bienvenidaOpcionClienteTitulo;

  /// No description provided for @bienvenidaOpcionClienteSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Accede o da de alta tu negocio en TanApp'**
  String get bienvenidaOpcionClienteSubtitulo;

  /// No description provided for @loginRecordarme.
  ///
  /// In es, this message translates to:
  /// **'Recordarme'**
  String get loginRecordarme;

  /// No description provided for @loginOlvidasteContrasena.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginOlvidasteContrasena;

  /// No description provided for @loginYaTengoCodigo.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes un código?'**
  String get loginYaTengoCodigo;

  /// No description provided for @loginIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginIniciarSesion;

  /// No description provided for @loginNoTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get loginNoTienesCuenta;

  /// No description provided for @loginRegistrate.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegistrate;

  /// No description provided for @loginEresFunerariaPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Eres una funeraria o tanatorio y todavía no tienes cuenta?'**
  String get loginEresFunerariaPregunta;

  /// No description provided for @loginSolicitarAlta.
  ///
  /// In es, this message translates to:
  /// **'Solicitar alta'**
  String get loginSolicitarAlta;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// No description provided for @registerYaTengoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta, iniciar sesión'**
  String get registerYaTengoCuenta;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordIntro.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu email y te enviaremos un código para restablecer tu contraseña.'**
  String get forgotPasswordIntro;

  /// No description provided for @forgotPasswordEnviarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get forgotPasswordEnviarCodigo;

  /// No description provided for @tengoCodigoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Introducir código'**
  String get tengoCodigoTitulo;

  /// No description provided for @tengoCodigoIntro.
  ///
  /// In es, this message translates to:
  /// **'Si ya has recibido un código de acceso por correo, escribe tu email para continuar.'**
  String get tengoCodigoIntro;

  /// No description provided for @tengoCodigoContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get tengoCodigoContinuar;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordInfo.
  ///
  /// In es, this message translates to:
  /// **'Elige la contraseña con la que vas a acceder a TanApp a partir de ahora. Debe tener al menos 8 caracteres.'**
  String get resetPasswordInfo;

  /// No description provided for @resetPasswordNuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get resetPasswordNuevaContrasena;

  /// No description provided for @resetPasswordGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get resetPasswordGuardar;

  /// No description provided for @resetPasswordActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get resetPasswordActualizada;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get verifyOtpTitle;

  /// No description provided for @verifyOtpSentTo.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un código de 6 dígitos a {email}'**
  String verifyOtpSentTo(String email);

  /// No description provided for @verifyOtpVerificar.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get verifyOtpVerificar;

  /// No description provided for @verifyOtpReenviar.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get verifyOtpReenviar;

  /// No description provided for @verifyOtpReenviarCooldown.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código ({segundos}s)'**
  String verifyOtpReenviarCooldown(int segundos);

  /// No description provided for @verifyOtpCodigoReenviado.
  ///
  /// In es, this message translates to:
  /// **'Código reenviado'**
  String get verifyOtpCodigoReenviado;

  /// No description provided for @verifyOtpNoSePudoReenviar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reenviar el código'**
  String get verifyOtpNoSePudoReenviar;

  /// No description provided for @verifyOtpCodigoIncorrecto.
  ///
  /// In es, this message translates to:
  /// **'Código incorrecto'**
  String get verifyOtpCodigoIncorrecto;

  /// No description provided for @errorGenerico.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGenerico(String error);

  /// No description provided for @accountTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get accountTitle;

  /// No description provided for @accountNoSePudoCargarPerfil.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar tu perfil'**
  String get accountNoSePudoCargarPerfil;

  /// No description provided for @accountFotoPerfil.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get accountFotoPerfil;

  /// No description provided for @accountDatosPersonales.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get accountDatosPersonales;

  /// No description provided for @accountFotoActualizada.
  ///
  /// In es, this message translates to:
  /// **'Foto actualizada'**
  String get accountFotoActualizada;

  /// No description provided for @accountNoSePudoSubirFoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la foto'**
  String get accountNoSePudoSubirFoto;

  /// No description provided for @accountDatosActualizados.
  ///
  /// In es, this message translates to:
  /// **'Datos actualizados'**
  String get accountDatosActualizados;

  /// No description provided for @accountCambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get accountCambiarContrasena;

  /// No description provided for @accountContrasenaActual.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get accountContrasenaActual;

  /// No description provided for @accountContrasenaActualIncorrecta.
  ///
  /// In es, this message translates to:
  /// **'La contraseña actual no es correcta'**
  String get accountContrasenaActualIncorrecta;

  /// No description provided for @accountNoSePudoVerificarIdentidad.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar tu identidad'**
  String get accountNoSePudoVerificarIdentidad;

  /// No description provided for @accountContrasenaActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get accountContrasenaActualizada;

  /// No description provided for @accountActualizarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contraseña'**
  String get accountActualizarContrasena;

  /// No description provided for @accountGuardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get accountGuardarCambios;

  /// No description provided for @accountNotificacionesPush.
  ///
  /// In es, this message translates to:
  /// **'Deseo recibir notificaciones de las publicaciones en mi móvil.'**
  String get accountNotificacionesPush;

  /// No description provided for @accountDarseDeBajaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Darse de baja'**
  String get accountDarseDeBajaTitulo;

  /// No description provided for @accountDarseDeBajaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Al darte de baja tu cuenta se desactiva y se cierra tu sesión. Solo un administrador puede reactivarla.'**
  String get accountDarseDeBajaAyuda;

  /// No description provided for @accountDarseDeBajaMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres darte de baja? Tu cuenta se desactivará y se cerrará tu sesión.'**
  String get accountDarseDeBajaMensaje;

  /// No description provided for @accountCuentaPersonalTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta personal'**
  String get accountCuentaPersonalTitulo;

  /// No description provided for @accountCuentaPersonalAyuda.
  ///
  /// In es, this message translates to:
  /// **'Como cliente también puedes tener tu propia cuenta personal, separada de la de tu negocio, para seguir clientes y zonas y dejar condolencias como cualquier otro usuario.'**
  String get accountCuentaPersonalAyuda;

  /// No description provided for @accountCuentaPersonalEntrar.
  ///
  /// In es, this message translates to:
  /// **'Entrar en tu cuenta personal'**
  String get accountCuentaPersonalEntrar;

  /// No description provided for @terminosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Antes de continuar'**
  String get terminosTitulo;

  /// No description provided for @terminosHeAceptado.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto: {titulo}'**
  String terminosHeAceptado(String titulo);

  /// No description provided for @terminosContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get terminosContinuar;

  /// No description provided for @terminosVerEnCuenta.
  ///
  /// In es, this message translates to:
  /// **'Términos y privacidad'**
  String get terminosVerEnCuenta;

  /// No description provided for @importacionWebTitulo.
  ///
  /// In es, this message translates to:
  /// **'Importar datos automáticamente'**
  String get importacionWebTitulo;

  /// No description provided for @importacionWebConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Autorizo a TanApp a rastrear la web indicada más abajo para proponer esquelas automáticamente a partir de su contenido público. Cada propuesta la seguiré revisando y publicando yo mismo/a antes de que sea visible para el público; TanApp no publica nada sin mi revisión.'**
  String get importacionWebConsentimiento;

  /// No description provided for @importacionWebAceptoCheckbox.
  ///
  /// In es, this message translates to:
  /// **'Acepto y autorizo el rastreo de mi web'**
  String get importacionWebAceptoCheckbox;

  /// No description provided for @importacionWebUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL de mi web'**
  String get importacionWebUrlLabel;

  /// No description provided for @importacionWebUrlInvalida.
  ///
  /// In es, this message translates to:
  /// **'Introduce una URL válida (debe empezar por http:// o https://)'**
  String get importacionWebUrlInvalida;

  /// No description provided for @importacionWebGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar y autorizar'**
  String get importacionWebGuardar;

  /// No description provided for @importacionWebActualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar URL'**
  String get importacionWebActualizar;

  /// No description provided for @importacionWebDesactivar.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get importacionWebDesactivar;

  /// No description provided for @importacionWebActiva.
  ///
  /// In es, this message translates to:
  /// **'Activa desde {fecha}'**
  String importacionWebActiva(String fecha);

  /// No description provided for @importacionWebDesactivada.
  ///
  /// In es, this message translates to:
  /// **'Desactivada'**
  String get importacionWebDesactivada;

  /// No description provided for @usuarioFichaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ficha de usuario'**
  String get usuarioFichaTitulo;

  /// No description provided for @usuarioCambiosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get usuarioCambiosGuardados;

  /// No description provided for @usuarioNoSePudoAsignarRol.
  ///
  /// In es, this message translates to:
  /// **'No se pudo asignar el rol'**
  String get usuarioNoSePudoAsignarRol;

  /// No description provided for @usuarioQuitarRolTitulo.
  ///
  /// In es, this message translates to:
  /// **'Quitar rol'**
  String get usuarioQuitarRolTitulo;

  /// No description provided for @usuarioQuitarRolMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar el rol \"{rol}\" a este usuario?'**
  String usuarioQuitarRolMensaje(String rol);

  /// No description provided for @usuarioQuitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get usuarioQuitar;

  /// No description provided for @usuarioNoSePudoQuitarRol.
  ///
  /// In es, this message translates to:
  /// **'No se pudo quitar el rol'**
  String get usuarioNoSePudoQuitarRol;

  /// No description provided for @usuarioYaTieneTodosLosRoles.
  ///
  /// In es, this message translates to:
  /// **'Ya tiene todos los roles asignados'**
  String get usuarioYaTieneTodosLosRoles;

  /// No description provided for @usuarioEmailValidado.
  ///
  /// In es, this message translates to:
  /// **'Email validado'**
  String get usuarioEmailValidado;

  /// No description provided for @usuarioNoSePudoValidarEmail.
  ///
  /// In es, this message translates to:
  /// **'No se pudo validar el email'**
  String get usuarioNoSePudoValidarEmail;

  /// No description provided for @usuarioEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar usuario'**
  String get usuarioEliminarTitulo;

  /// No description provided for @usuarioEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar a \"{nombre}\"? Esta acción no se puede deshacer.'**
  String usuarioEliminarMensaje(String nombre);

  /// No description provided for @usuarioEliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get usuarioEliminar;

  /// No description provided for @usuarioNoSePudoEliminar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el usuario'**
  String get usuarioNoSePudoEliminar;

  /// No description provided for @suplantarUsuario.
  ///
  /// In es, this message translates to:
  /// **'Suplantar usuario'**
  String get suplantarUsuario;

  /// No description provided for @suplantarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Vas a iniciar sesión como \"{nombre}\" para ver la app tal cual la ve. Podrás volver a tu cuenta de administrador en cualquier momento. ¿Continuar?'**
  String suplantarMensaje(String nombre);

  /// No description provided for @suplantarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Suplantar'**
  String get suplantarConfirmar;

  /// No description provided for @suplantacionBannerTexto.
  ///
  /// In es, this message translates to:
  /// **'Estás viendo la app como {nombre}'**
  String suplantacionBannerTexto(String nombre);

  /// No description provided for @suplantacionVolver.
  ///
  /// In es, this message translates to:
  /// **'Volver a mi cuenta'**
  String get suplantacionVolver;

  /// No description provided for @cuentaPropiaBannerTexto.
  ///
  /// In es, this message translates to:
  /// **'Estás en tu cuenta personal de seguidor'**
  String get cuentaPropiaBannerTexto;

  /// No description provided for @cuentaPropiaVolver.
  ///
  /// In es, this message translates to:
  /// **'Volver a mi cuenta de cliente'**
  String get cuentaPropiaVolver;

  /// No description provided for @usuarioIdiomaPreferido.
  ///
  /// In es, this message translates to:
  /// **'Idioma preferido'**
  String get usuarioIdiomaPreferido;

  /// No description provided for @errorCargarIdiomas.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los idiomas: {error}'**
  String errorCargarIdiomas(String error);

  /// No description provided for @usuarioTipoCliente.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cliente'**
  String get usuarioTipoCliente;

  /// No description provided for @errorCargarTiposCliente.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los tipos de cliente: {error}'**
  String errorCargarTiposCliente(String error);

  /// No description provided for @usuarioActivo.
  ///
  /// In es, this message translates to:
  /// **'Usuario activo'**
  String get usuarioActivo;

  /// No description provided for @usuarioImportacionWebSinConfigurar.
  ///
  /// In es, this message translates to:
  /// **'Este cliente no ha configurado ninguna URL de importación automática.'**
  String get usuarioImportacionWebSinConfigurar;

  /// No description provided for @usuarioImportacionWebActiva.
  ///
  /// In es, this message translates to:
  /// **'Importación automática activa'**
  String get usuarioImportacionWebActiva;

  /// No description provided for @usuarioEscaneoEsquelaIaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Escaneo de esquelas con IA'**
  String get usuarioEscaneoEsquelaIaTitulo;

  /// No description provided for @usuarioEscaneoEsquelaIaActiva.
  ///
  /// In es, this message translates to:
  /// **'Escaneo con IA activo para este usuario'**
  String get usuarioEscaneoEsquelaIaActiva;

  /// No description provided for @validacionEmail.
  ///
  /// In es, this message translates to:
  /// **'Validación de email'**
  String get validacionEmail;

  /// No description provided for @usuarioTerminosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get usuarioTerminosTitulo;

  /// No description provided for @usuarioTerminosAceptados.
  ///
  /// In es, this message translates to:
  /// **'Aceptados'**
  String get usuarioTerminosAceptados;

  /// No description provided for @usuarioTerminosPendientes.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get usuarioTerminosPendientes;

  /// No description provided for @terminosTipoUso.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get terminosTipoUso;

  /// No description provided for @terminosTipoPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get terminosTipoPrivacidad;

  /// No description provided for @terminosCampoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get terminosCampoTitulo;

  /// No description provided for @terminosCampoCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get terminosCampoCuerpo;

  /// No description provided for @terminosContenidoGuardadoEnIdioma.
  ///
  /// In es, this message translates to:
  /// **'Contenido en {idioma} guardado'**
  String terminosContenidoGuardadoEnIdioma(String idioma);

  /// No description provided for @terminosColDocumento.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get terminosColDocumento;

  /// No description provided for @terminosColFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get terminosColFecha;

  /// No description provided for @terminosVerTexto.
  ///
  /// In es, this message translates to:
  /// **'Ver texto'**
  String get terminosVerTexto;

  /// No description provided for @terminosRolCliente.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get terminosRolCliente;

  /// No description provided for @terminosRolUsuarioOrdinario.
  ///
  /// In es, this message translates to:
  /// **'Usuario ordinario'**
  String get terminosRolUsuarioOrdinario;

  /// No description provided for @verDetalle.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get verDetalle;

  /// No description provided for @ocultarDetalle.
  ///
  /// In es, this message translates to:
  /// **'Ocultar detalle'**
  String get ocultarDetalle;

  /// No description provided for @marcarComoValidado.
  ///
  /// In es, this message translates to:
  /// **'Marcar como validado'**
  String get marcarComoValidado;

  /// No description provided for @validado.
  ///
  /// In es, this message translates to:
  /// **'Validado'**
  String get validado;

  /// No description provided for @roles.
  ///
  /// In es, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @anadirRol.
  ///
  /// In es, this message translates to:
  /// **'Añadir rol'**
  String get anadirRol;

  /// No description provided for @sesiones.
  ///
  /// In es, this message translates to:
  /// **'Sesiones'**
  String get sesiones;

  /// No description provided for @ocultarSesiones.
  ///
  /// In es, this message translates to:
  /// **'Ocultar sesiones'**
  String get ocultarSesiones;

  /// No description provided for @verSesiones.
  ///
  /// In es, this message translates to:
  /// **'Ver sesiones'**
  String get verSesiones;

  /// No description provided for @sinSesionesRegistradas.
  ///
  /// In es, this message translates to:
  /// **'Sin sesiones registradas'**
  String get sinSesionesRegistradas;

  /// No description provided for @sesionColInicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get sesionColInicio;

  /// No description provided for @sesionColFin.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get sesionColFin;

  /// No description provided for @sesionColEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get sesionColEstado;

  /// No description provided for @sesionColRecordar.
  ///
  /// In es, this message translates to:
  /// **'Recordar'**
  String get sesionColRecordar;

  /// No description provided for @sesionColDispositivo.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo'**
  String get sesionColDispositivo;

  /// No description provided for @deslizaParaVerMas.
  ///
  /// In es, this message translates to:
  /// **'Desliza para ver más'**
  String get deslizaParaVerMas;

  /// No description provided for @sesionEnCurso.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get sesionEnCurso;

  /// No description provided for @sesionAbierta.
  ///
  /// In es, this message translates to:
  /// **'Abierta'**
  String get sesionAbierta;

  /// No description provided for @sesionCerrada.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get sesionCerrada;

  /// No description provided for @si.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get si;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @errorCargarSesiones.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las sesiones: {error}'**
  String errorCargarSesiones(String error);

  /// No description provided for @elegirSedeTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Con qué sede vas a trabajar?'**
  String get elegirSedeTitulo;

  /// No description provided for @elegirSedeMensaje.
  ///
  /// In es, this message translates to:
  /// **'Elige la sede con la que vas a trabajar en esta sesión. Podrás cambiarla más adelante cuando quieras.'**
  String get elegirSedeMensaje;

  /// No description provided for @sedeLimiteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Límite de sesiones alcanzado'**
  String get sedeLimiteTitulo;

  /// No description provided for @sedeLimiteMensaje.
  ///
  /// In es, this message translates to:
  /// **'Ya hay 2 sesiones abiertas trabajando como \"{sede}\". Si continúas, se cerrará la más antigua.'**
  String sedeLimiteMensaje(String sede);

  /// No description provided for @sedeLimiteConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar la más antigua y continuar'**
  String get sedeLimiteConfirmar;

  /// No description provided for @sedeActualTexto.
  ///
  /// In es, this message translates to:
  /// **'Sede: {sede}'**
  String sedeActualTexto(String sede);

  /// No description provided for @sedeActualCambiar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar sede'**
  String get sedeActualCambiar;

  /// No description provided for @solicitudTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de alta de cliente'**
  String get solicitudTitulo;

  /// No description provided for @solicitudEnviadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada'**
  String get solicitudEnviadaTitulo;

  /// No description provided for @solicitudEnviadaMensaje.
  ///
  /// In es, this message translates to:
  /// **'Hemos recibido tu solicitud. Un administrador la revisará y te contactaremos en breve.'**
  String get solicitudEnviadaMensaje;

  /// No description provided for @solicitudEnviadaProcesoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa ahora?'**
  String get solicitudEnviadaProcesoTitulo;

  /// No description provided for @solicitudEnviadaPaso1.
  ///
  /// In es, this message translates to:
  /// **'Revisamos tu solicitud (normalmente en 1-2 días laborables).'**
  String get solicitudEnviadaPaso1;

  /// No description provided for @solicitudEnviadaPaso2.
  ///
  /// In es, this message translates to:
  /// **'Cuando se apruebe, te llegará un correo con tu código de acceso.'**
  String get solicitudEnviadaPaso2;

  /// No description provided for @solicitudEnviadaPaso3.
  ///
  /// In es, this message translates to:
  /// **'Abre la app, en la pantalla de inicio de sesión pulsa \"¿Ya tienes un código?\", introduce tu email y el código para fijar tu contraseña y entrar.'**
  String get solicitudEnviadaPaso3;

  /// No description provided for @volverAlInicio.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get volverAlInicio;

  /// No description provided for @solicitudIntro.
  ///
  /// In es, this message translates to:
  /// **'Solicita el alta de tu funeraria o tanatorio en TanApp. Un administrador revisará tu solicitud antes de darte acceso.'**
  String get solicitudIntro;

  /// No description provided for @fieldRazonSocial.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get fieldRazonSocial;

  /// No description provided for @fieldNifCif.
  ///
  /// In es, this message translates to:
  /// **'NIF / CIF'**
  String get fieldNifCif;

  /// No description provided for @fieldNombreContacto.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la persona de contacto'**
  String get fieldNombreContacto;

  /// No description provided for @fieldEmailContacto.
  ///
  /// In es, this message translates to:
  /// **'Email de contacto'**
  String get fieldEmailContacto;

  /// No description provided for @fieldTelefonoContacto.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de contacto'**
  String get fieldTelefonoContacto;

  /// No description provided for @fieldObservacionesOpcional.
  ///
  /// In es, this message translates to:
  /// **'Observaciones (opcional)'**
  String get fieldObservacionesOpcional;

  /// No description provided for @enviarSolicitud.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get enviarSolicitud;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @cambiosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get cambiosGuardados;

  /// No description provided for @comunicacionNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva comunicación'**
  String get comunicacionNueva;

  /// No description provided for @comunicacionEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar comunicación'**
  String get comunicacionEditar;

  /// No description provided for @comunicacionTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de comunicación'**
  String get comunicacionTipo;

  /// No description provided for @comunicacionCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get comunicacionCodigo;

  /// No description provided for @comunicacionRemitente.
  ///
  /// In es, this message translates to:
  /// **'Remitente'**
  String get comunicacionRemitente;

  /// No description provided for @comunicacionActiva.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get comunicacionActiva;

  /// No description provided for @comunicacionTextosPorIdioma.
  ///
  /// In es, this message translates to:
  /// **'Textos por idioma'**
  String get comunicacionTextosPorIdioma;

  /// No description provided for @comunicacionTextoGuardadoEnIdioma.
  ///
  /// In es, this message translates to:
  /// **'Texto en {idioma} guardado'**
  String comunicacionTextoGuardadoEnIdioma(String idioma);

  /// No description provided for @comunicacionNoSePudoGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar'**
  String get comunicacionNoSePudoGuardar;

  /// No description provided for @comunicacionAsunto.
  ///
  /// In es, this message translates to:
  /// **'Asunto'**
  String get comunicacionAsunto;

  /// No description provided for @comunicacionCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Cuerpo'**
  String get comunicacionCuerpo;

  /// No description provided for @comunicacionGuardarTexto.
  ///
  /// In es, this message translates to:
  /// **'Guardar texto'**
  String get comunicacionGuardarTexto;

  /// No description provided for @comunicacionEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar comunicación'**
  String get comunicacionEliminarTitulo;

  /// No description provided for @comunicacionEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String comunicacionEliminarMensaje(String nombre);

  /// No description provided for @configuracionComunicacionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Configuración > Comunicaciones'**
  String get configuracionComunicacionesTitulo;

  /// No description provided for @noHayComunicacionesDadasDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No hay comunicaciones dadas de alta'**
  String get noHayComunicacionesDadasDeAlta;

  /// No description provided for @inactiva.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get inactiva;

  /// No description provided for @tiposCliente.
  ///
  /// In es, this message translates to:
  /// **'Tipos de Clientes'**
  String get tiposCliente;

  /// No description provided for @configuracionTiposClienteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Configuración > Tipos de Clientes'**
  String get configuracionTiposClienteTitulo;

  /// No description provided for @tiposActo.
  ///
  /// In es, this message translates to:
  /// **'Tipos de acto'**
  String get tiposActo;

  /// No description provided for @configuracionTiposActoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Configuración > Tipos de acto'**
  String get configuracionTiposActoTitulo;

  /// No description provided for @noHayTiposActoDadosDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No hay tipos de acto dados de alta'**
  String get noHayTiposActoDadosDeAlta;

  /// No description provided for @actoTipoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo tipo de acto'**
  String get actoTipoNuevo;

  /// No description provided for @actoTipoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar tipo de acto'**
  String get actoTipoEditar;

  /// No description provided for @actoTipoActivo.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get actoTipoActivo;

  /// No description provided for @actoTipoEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tipo de acto'**
  String get actoTipoEliminarTitulo;

  /// No description provided for @actoTipoEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String actoTipoEliminarMensaje(String nombre);

  /// No description provided for @configuracionIa.
  ///
  /// In es, this message translates to:
  /// **'Configuración IA'**
  String get configuracionIa;

  /// No description provided for @configuracionIaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Configuración > IA'**
  String get configuracionIaTitulo;

  /// No description provided for @configuracionIaImportacionWebLabel.
  ///
  /// In es, this message translates to:
  /// **'Importación de esquelas con IA'**
  String get configuracionIaImportacionWebLabel;

  /// No description provided for @configuracionIaImportacionWebDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Si la desactivas, ningún cliente podrá activar la importación automática de su web ni ver propuestas, aunque ya la tuviera configurada.'**
  String get configuracionIaImportacionWebDescripcion;

  /// No description provided for @configuracionIaEscaneoEsquelaLabel.
  ///
  /// In es, this message translates to:
  /// **'Escaneo de esquelas con IA'**
  String get configuracionIaEscaneoEsquelaLabel;

  /// No description provided for @configuracionIaEscaneoEsquelaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Si está activado, al escanear una esquela la foto se analiza con IA en vez del reconocimiento de texto local. Si la desactivas (o falla), se sigue usando el escaneo local de siempre.'**
  String get configuracionIaEscaneoEsquelaDescripcion;

  /// No description provided for @noHayTiposClienteDadosDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No hay tipos de cliente dados de alta'**
  String get noHayTiposClienteDadosDeAlta;

  /// No description provided for @clienteTipoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo tipo de cliente'**
  String get clienteTipoNuevo;

  /// No description provided for @clienteTipoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar tipo de cliente'**
  String get clienteTipoEditar;

  /// No description provided for @clienteTipoActivo.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get clienteTipoActivo;

  /// No description provided for @clienteTipoEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tipo de cliente'**
  String get clienteTipoEliminarTitulo;

  /// No description provided for @clienteTipoEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String clienteTipoEliminarMensaje(String nombre);

  /// No description provided for @clienteTipoTraduccionesPorIdioma.
  ///
  /// In es, this message translates to:
  /// **'Traducciones por idioma'**
  String get clienteTipoTraduccionesPorIdioma;

  /// No description provided for @clienteTipoGuardarTraduccion.
  ///
  /// In es, this message translates to:
  /// **'Guardar traducción'**
  String get clienteTipoGuardarTraduccion;

  /// No description provided for @clienteTipoTraduccionGuardadaEnIdioma.
  ///
  /// In es, this message translates to:
  /// **'Traducción en {idioma} guardada'**
  String clienteTipoTraduccionGuardadaEnIdioma(String idioma);

  /// No description provided for @clienteTipoNoSePudoGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar'**
  String get clienteTipoNoSePudoGuardar;

  /// No description provided for @solicitudSeleccionarTipoCliente.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el tipo de cliente'**
  String get solicitudSeleccionarTipoCliente;

  /// No description provided for @solicitudTipoClienteObligatorio.
  ///
  /// In es, this message translates to:
  /// **'El tipo de cliente es obligatorio para aprobar la solicitud'**
  String get solicitudTipoClienteObligatorio;

  /// No description provided for @gestionUsuariosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Gestión de usuarios'**
  String get gestionUsuariosTitulo;

  /// No description provided for @buscarPorNombreEmail.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o email'**
  String get buscarPorNombreEmail;

  /// No description provided for @soloActivos.
  ///
  /// In es, this message translates to:
  /// **'Solo activos'**
  String get soloActivos;

  /// No description provided for @todosLosRoles.
  ///
  /// In es, this message translates to:
  /// **'Todos los roles'**
  String get todosLosRoles;

  /// No description provided for @noSeHanEncontradoUsuarios.
  ///
  /// In es, this message translates to:
  /// **'No se han encontrado usuarios'**
  String get noSeHanEncontradoUsuarios;

  /// No description provided for @pendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pendiente;

  /// No description provided for @solicitudesClientesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes de clientes'**
  String get solicitudesClientesTitulo;

  /// No description provided for @estadoTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get estadoTodas;

  /// No description provided for @estadoPendientes.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get estadoPendientes;

  /// No description provided for @estadoAprobadas.
  ///
  /// In es, this message translates to:
  /// **'Aprobadas'**
  String get estadoAprobadas;

  /// No description provided for @estadoRechazadas.
  ///
  /// In es, this message translates to:
  /// **'Rechazadas'**
  String get estadoRechazadas;

  /// No description provided for @noHaySolicitudesEnEsteEstado.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes en este estado'**
  String get noHaySolicitudesEnEsteEstado;

  /// No description provided for @solicitudEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar solicitud'**
  String get solicitudEliminarTitulo;

  /// No description provided for @solicitudEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta solicitud? Esta acción no se puede deshacer.'**
  String get solicitudEliminarMensaje;

  /// No description provided for @solicitudNoSePudoEliminar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la solicitud'**
  String get solicitudNoSePudoEliminar;

  /// No description provided for @solicitudAprobarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aprobar solicitud'**
  String get solicitudAprobarTitulo;

  /// No description provided for @solicitudRechazarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Rechazar solicitud'**
  String get solicitudRechazarTitulo;

  /// No description provided for @solicitudConfirmarAprobar.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmas que quieres aprobar esta solicitud de alta?'**
  String get solicitudConfirmarAprobar;

  /// No description provided for @solicitudConfirmarRechazar.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmas que quieres rechazar esta solicitud de alta?'**
  String get solicitudConfirmarRechazar;

  /// No description provided for @aprobar.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get aprobar;

  /// No description provided for @rechazar.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get rechazar;

  /// No description provided for @solicitudNoIdentificado.
  ///
  /// In es, this message translates to:
  /// **'No se pudo identificar al usuario actual'**
  String get solicitudNoIdentificado;

  /// No description provided for @solicitudAprobadaSinCuenta.
  ///
  /// In es, this message translates to:
  /// **'Solicitud aprobada, pero no se pudo crear la cuenta del cliente: {error}'**
  String solicitudAprobadaSinCuenta(String error);

  /// No description provided for @solicitudCuentaCreada.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de cliente creada'**
  String get solicitudCuentaCreada;

  /// No description provided for @solicitudNoSePudoCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la cuenta del cliente: {error}'**
  String solicitudNoSePudoCrearCuenta(String error);

  /// No description provided for @solicitudDetalleTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de cliente'**
  String get solicitudDetalleTitulo;

  /// No description provided for @solicitudAprobarBoton.
  ///
  /// In es, this message translates to:
  /// **'Aprobar solicitud'**
  String get solicitudAprobarBoton;

  /// No description provided for @campoPersonaContacto.
  ///
  /// In es, this message translates to:
  /// **'Persona de contacto'**
  String get campoPersonaContacto;

  /// No description provided for @campoLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get campoLocalidad;

  /// No description provided for @campoObservaciones.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get campoObservaciones;

  /// No description provided for @campoObservacionesResolucion.
  ///
  /// In es, this message translates to:
  /// **'Observaciones de resolución'**
  String get campoObservacionesResolucion;

  /// No description provided for @fieldObservacionesResolucionOpcional.
  ///
  /// In es, this message translates to:
  /// **'Observaciones de resolución (opcional)'**
  String get fieldObservacionesResolucionOpcional;

  /// No description provided for @provincias.
  ///
  /// In es, this message translates to:
  /// **'Provincias'**
  String get provincias;

  /// No description provided for @comunicaciones.
  ///
  /// In es, this message translates to:
  /// **'Comunicaciones'**
  String get comunicaciones;

  /// No description provided for @configuracionProvinciasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Configuración > Provincias'**
  String get configuracionProvinciasTitulo;

  /// No description provided for @noHayProvinciasDadasDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No hay provincias dadas de alta'**
  String get noHayProvinciasDadasDeAlta;

  /// No description provided for @prefijoPostalLabel.
  ///
  /// In es, this message translates to:
  /// **'Prefijo postal: {prefijo}'**
  String prefijoPostalLabel(String prefijo);

  /// No description provided for @provinciaEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar provincia'**
  String get provinciaEliminarTitulo;

  /// No description provided for @provinciaEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"? También se eliminarán sus concellos.'**
  String provinciaEliminarMensaje(String nombre);

  /// No description provided for @provinciaNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva provincia'**
  String get provinciaNueva;

  /// No description provided for @provinciaEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar provincia'**
  String get provinciaEditar;

  /// No description provided for @fieldPrefijoPostal.
  ///
  /// In es, this message translates to:
  /// **'Prefijo postal'**
  String get fieldPrefijoPostal;

  /// No description provided for @errorPrefijoRequerido.
  ///
  /// In es, this message translates to:
  /// **'El prefijo es obligatorio'**
  String get errorPrefijoRequerido;

  /// No description provided for @errorNombreRequerido.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get errorNombreRequerido;

  /// No description provided for @concellosDeProvincia.
  ///
  /// In es, this message translates to:
  /// **'Concellos de {provincia}'**
  String concellosDeProvincia(String provincia);

  /// No description provided for @concellosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Concellos'**
  String get concellosTitulo;

  /// No description provided for @noHayConcellosDadosDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No hay concellos dados de alta'**
  String get noHayConcellosDadosDeAlta;

  /// No description provided for @concelloEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar concello'**
  String get concelloEliminarTitulo;

  /// No description provided for @concelloEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String concelloEliminarMensaje(String nombre);

  /// No description provided for @concelloNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo concello'**
  String get concelloNuevo;

  /// No description provided for @concelloEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar concello'**
  String get concelloEditar;

  /// No description provided for @gestionDeUsuarios.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get gestionDeUsuarios;

  /// No description provided for @solicitudesDeClientes.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes de Clientes'**
  String get solicitudesDeClientes;

  /// No description provided for @holaNombre.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}'**
  String holaNombre(String nombre);

  /// No description provided for @tablon.
  ///
  /// In es, this message translates to:
  /// **'Tablón'**
  String get tablon;

  /// No description provided for @seguidos.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get seguidos;

  /// No description provided for @avisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get avisos;

  /// No description provided for @avisosNuevo.
  ///
  /// In es, this message translates to:
  /// **'Aviso'**
  String get avisosNuevo;

  /// No description provided for @avisosFormTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo aviso'**
  String get avisosFormTitulo;

  /// No description provided for @avisosTituloLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get avisosTituloLabel;

  /// No description provided for @avisosTextoLabel.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get avisosTextoLabel;

  /// No description provided for @avisosEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get avisosEnviar;

  /// No description provided for @avisosEnviadoOk.
  ///
  /// In es, this message translates to:
  /// **'Aviso enviado'**
  String get avisosEnviadoOk;

  /// No description provided for @avisosEnviadoEl.
  ///
  /// In es, this message translates to:
  /// **'Enviado el {fecha} a las {hora}'**
  String avisosEnviadoEl(String fecha, String hora);

  /// No description provided for @avisosVacioEnviados.
  ///
  /// In es, this message translates to:
  /// **'No has enviado ningún aviso todavía.'**
  String get avisosVacioEnviados;

  /// No description provided for @avisosVacioRecibidos.
  ///
  /// In es, this message translates to:
  /// **'No tienes avisos.'**
  String get avisosVacioRecibidos;

  /// No description provided for @avisosCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get avisosCerrar;

  /// No description provided for @avisosEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar aviso'**
  String get avisosEliminarTitulo;

  /// No description provided for @avisosEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el aviso \"{titulo}\"? Esta acción no se puede deshacer.'**
  String avisosEliminarMensaje(String titulo);

  /// No description provided for @avisosEliminarSeleccionadosMensaje.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{¿Eliminar el aviso seleccionado? Esta acción no se puede deshacer.} other{¿Eliminar los {count} avisos seleccionados? Esta acción no se puede deshacer.}}'**
  String avisosEliminarSeleccionadosMensaje(int count);

  /// No description provided for @avisosVaciarTodoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Vaciar avisos'**
  String get avisosVaciarTodoTitulo;

  /// No description provided for @avisosVaciarTodoMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar todos tus avisos? Esta acción no se puede deshacer.'**
  String get avisosVaciarTodoMensaje;

  /// No description provided for @avisosNSeleccionados.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 seleccionado} other{{count} seleccionados}}'**
  String avisosNSeleccionados(int count);

  /// No description provided for @avisosCancelarSeleccion.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get avisosCancelarSeleccion;

  /// No description provided for @avisosEditarProgramado.
  ///
  /// In es, this message translates to:
  /// **'Editar aviso programado'**
  String get avisosEditarProgramado;

  /// No description provided for @avisosProgramadosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Programados'**
  String get avisosProgramadosTitulo;

  /// No description provided for @avisosCancelarProgramadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cancelar aviso programado'**
  String get avisosCancelarProgramadoTitulo;

  /// No description provided for @avisosCancelarProgramadoMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar el aviso programado \"{titulo}\"? No se enviará.'**
  String avisosCancelarProgramadoMensaje(String titulo);

  /// No description provided for @seguidosSeleccionaTipo.
  ///
  /// In es, this message translates to:
  /// **'Elige a quién seguir'**
  String get seguidosSeleccionaTipo;

  /// No description provided for @seguidosSeleccionaProvincia.
  ///
  /// In es, this message translates to:
  /// **'Elige la provincia'**
  String get seguidosSeleccionaProvincia;

  /// No description provided for @seguidosSeleccionaConcello.
  ///
  /// In es, this message translates to:
  /// **'Elige el concello'**
  String get seguidosSeleccionaConcello;

  /// No description provided for @seguidosBuscarConcello.
  ///
  /// In es, this message translates to:
  /// **'Buscar concello'**
  String get seguidosBuscarConcello;

  /// No description provided for @seguidosNoHayActivosNesteConcello.
  ///
  /// In es, this message translates to:
  /// **'{tipoNombre, select, Tanatorio{Todavía no hay ningún tanatorio activo en este concello} Funeraria{Todavía no hay ninguna funeraria activa en este concello} other{Todavía no hay ningún cliente activo en este concello}}'**
  String seguidosNoHayActivosNesteConcello(String tipoNombre);

  /// No description provided for @seguidosSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get seguidosSeguir;

  /// No description provided for @seguidosDejarDeSeguir.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get seguidosDejarDeSeguir;

  /// No description provided for @seguidosSilenciar.
  ///
  /// In es, this message translates to:
  /// **'Desactivar notificaciones'**
  String get seguidosSilenciar;

  /// No description provided for @seguidosActivarAvisos.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get seguidosActivarAvisos;

  /// No description provided for @seguidosSiguiendoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get seguidosSiguiendoEtiqueta;

  /// No description provided for @seguidosNoSiguiendoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'No sigues'**
  String get seguidosNoSiguiendoEtiqueta;

  /// No description provided for @siguiendoTab.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get siguiendoTab;

  /// No description provided for @misSeguidosBuscarNombre.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre'**
  String get misSeguidosBuscarNombre;

  /// No description provided for @misSeguidosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no sigues a ningún cliente. Usa \"Seguir un cliente nuevo\" para buscar funerarias y tanatorios.'**
  String get misSeguidosVacio;

  /// No description provided for @misSeguidosTabClientes.
  ///
  /// In es, this message translates to:
  /// **'Clientes'**
  String get misSeguidosTabClientes;

  /// No description provided for @misSeguidosTabZonas.
  ///
  /// In es, this message translates to:
  /// **'Zonas'**
  String get misSeguidosTabZonas;

  /// No description provided for @misSeguidosSeguirNuevo.
  ///
  /// In es, this message translates to:
  /// **'Seguir un cliente nuevo'**
  String get misSeguidosSeguirNuevo;

  /// No description provided for @zonaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get zonaTitulo;

  /// No description provided for @zonaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Sigue un concello sin tener que buscar y seguir a cada cliente por separado: recibirás los avisos de cualquier cliente con sede ahí.'**
  String get zonaExplicacion;

  /// No description provided for @zonaSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get zonaSeguir;

  /// No description provided for @zonaDejarDeSeguir.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get zonaDejarDeSeguir;

  /// No description provided for @zonaSeguirNueva.
  ///
  /// In es, this message translates to:
  /// **'Seguir una zona nueva'**
  String get zonaSeguirNueva;

  /// No description provided for @misZonasVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no sigues ninguna zona. Usa \"Seguir una zona nueva\" para recibir avisos de todo un concello.'**
  String get misZonasVacio;

  /// No description provided for @drawerMisSedes.
  ///
  /// In es, this message translates to:
  /// **'Mis sedes/tanatorios'**
  String get drawerMisSedes;

  /// No description provided for @drawerContactarSoporte.
  ///
  /// In es, this message translates to:
  /// **'Contactar con soporte'**
  String get drawerContactarSoporte;

  /// No description provided for @soporteAsuntoPorDefecto.
  ///
  /// In es, this message translates to:
  /// **'Soporte TanApp'**
  String get soporteAsuntoPorDefecto;

  /// No description provided for @misSedesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mis sedes/tanatorios'**
  String get misSedesTitulo;

  /// No description provided for @misSedesVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has dado de alta ninguna sede/tanatorio'**
  String get misSedesVacio;

  /// No description provided for @misSedesNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva sede/tanatorio'**
  String get misSedesNueva;

  /// No description provided for @misSedesEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar sede/tanatorio'**
  String get misSedesEditar;

  /// No description provided for @misSedesNombreSede.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la sede/tanatorio'**
  String get misSedesNombreSede;

  /// No description provided for @misSedesNombreAyuda.
  ///
  /// In es, this message translates to:
  /// **'Es el nombre que aparecerá en las notificaciones, avisos y esquelas de esta sede.'**
  String get misSedesNombreAyuda;

  /// No description provided for @misSedesEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar sede/tanatorio'**
  String get misSedesEliminarTitulo;

  /// No description provided for @misSedesEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String misSedesEliminarMensaje(String nombre);

  /// No description provided for @misSedesUltimaSedeAviso.
  ///
  /// In es, this message translates to:
  /// **'Debe quedar al menos una sede/tanatorio. Para eliminar esta, primero da de alta otra.'**
  String get misSedesUltimaSedeAviso;

  /// No description provided for @misSedesCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get misSedesCodigo;

  /// No description provided for @tabPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get tabPublicar;

  /// No description provided for @tabPanelDatos.
  ///
  /// In es, this message translates to:
  /// **'Panel de Datos'**
  String get tabPanelDatos;

  /// No description provided for @publicarEscanear.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get publicarEscanear;

  /// No description provided for @publicarEscanearAyuda.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes la esquela en papel o en una foto? Escanéala y te rellenamos el formulario.'**
  String get publicarEscanearAyuda;

  /// No description provided for @publicarManual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get publicarManual;

  /// No description provided for @publicarDeceso.
  ///
  /// In es, this message translates to:
  /// **'Deceso'**
  String get publicarDeceso;

  /// No description provided for @publicarImportarWeb.
  ///
  /// In es, this message translates to:
  /// **'Importación automática'**
  String get publicarImportarWeb;

  /// No description provided for @publicarPropuestas.
  ///
  /// In es, this message translates to:
  /// **'Propuestas'**
  String get publicarPropuestas;

  /// No description provided for @publicarAvisoImportadoWeb.
  ///
  /// In es, this message translates to:
  /// **'Datos importados automáticamente desde tu web. Revisa todos los campos antes de publicar.'**
  String get publicarAvisoImportadoWeb;

  /// No description provided for @propuestasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Propuestas de publicación'**
  String get propuestasTitulo;

  /// No description provided for @propuestasVacio.
  ///
  /// In es, this message translates to:
  /// **'No hay propuestas pendientes de revisar.'**
  String get propuestasVacio;

  /// No description provided for @propuestasDetectadaEl.
  ///
  /// In es, this message translates to:
  /// **'Detectada el {fecha}'**
  String propuestasDetectadaEl(String fecha);

  /// No description provided for @propuestasRevisar.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get propuestasRevisar;

  /// No description provided for @propuestasDescartar.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get propuestasDescartar;

  /// No description provided for @propuestasConfirmarDescartarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Descartar propuesta'**
  String get propuestasConfirmarDescartarTitulo;

  /// No description provided for @propuestasConfirmarDescartarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar la propuesta de \"{nombre}\"? No se publicará y no se volverá a proponer.'**
  String propuestasConfirmarDescartarMensaje(String nombre);

  /// No description provided for @propuestasImportarAhora.
  ///
  /// In es, this message translates to:
  /// **'Importar ahora'**
  String get propuestasImportarAhora;

  /// No description provided for @propuestasImportando.
  ///
  /// In es, this message translates to:
  /// **'Importando'**
  String get propuestasImportando;

  /// No description provided for @propuestasImportarAhoraResultado.
  ///
  /// In es, this message translates to:
  /// **'{nuevas, plural, =0{No se ha encontrado ninguna esquela nueva.} =1{Se ha encontrado 1 esquela nueva.} other{Se han encontrado {nuevas} esquelas nuevas.}}'**
  String propuestasImportarAhoraResultado(int nuevas);

  /// No description provided for @importacionWebReconfigurar.
  ///
  /// In es, this message translates to:
  /// **'Configurar importación automática'**
  String get importacionWebReconfigurar;

  /// No description provided for @publicarNuevaPublicacion.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get publicarNuevaPublicacion;

  /// No description provided for @publicarMisa.
  ///
  /// In es, this message translates to:
  /// **'Misa/Acto'**
  String get publicarMisa;

  /// No description provided for @publicarNuevoActo.
  ///
  /// In es, this message translates to:
  /// **'Nueva/o Misa/Acto'**
  String get publicarNuevoActo;

  /// No description provided for @publicarEditarActo.
  ///
  /// In es, this message translates to:
  /// **'Editar Misa/Acto'**
  String get publicarEditarActo;

  /// No description provided for @publicarEnMemoriaDe.
  ///
  /// In es, this message translates to:
  /// **'En memoria de'**
  String get publicarEnMemoriaDe;

  /// No description provided for @publicarTipoActo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de acto'**
  String get publicarTipoActo;

  /// No description provided for @publicarTipoActoOtroOpcion.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get publicarTipoActoOtroOpcion;

  /// No description provided for @publicarTipoActoOtro.
  ///
  /// In es, this message translates to:
  /// **'Especifica el tipo de acto'**
  String get publicarTipoActoOtro;

  /// No description provided for @publicarFechaActo.
  ///
  /// In es, this message translates to:
  /// **'Fecha del acto'**
  String get publicarFechaActo;

  /// No description provided for @publicarHoraActo.
  ///
  /// In es, this message translates to:
  /// **'Hora del acto'**
  String get publicarHoraActo;

  /// No description provided for @publicarActoLabel.
  ///
  /// In es, this message translates to:
  /// **'Acto'**
  String get publicarActoLabel;

  /// No description provided for @publicarMisaLabel.
  ///
  /// In es, this message translates to:
  /// **'Misa'**
  String get publicarMisaLabel;

  /// No description provided for @publicarIglesiaLocalizacion.
  ///
  /// In es, this message translates to:
  /// **'Iglesia/Localización'**
  String get publicarIglesiaLocalizacion;

  /// No description provided for @publicarSeleccionaSede.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la sede/tanatorio'**
  String get publicarSeleccionaSede;

  /// No description provided for @publicarSinSedes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes ninguna sede/tanatorio. Da de alta una en \"Miñas sedes\" antes de publicar.'**
  String get publicarSinSedes;

  /// No description provided for @sedeSinRenombrarAviso.
  ///
  /// In es, this message translates to:
  /// **'Antes de publicar esquelas o enviar avisos, revisa (o cambia) el nombre de tu sede desde \"Mis sedes\". Es el nombre que aparecerá en las notificaciones, avisos y esquelas que envíes.'**
  String get sedeSinRenombrarAviso;

  /// No description provided for @sedeSinRenombrarBoton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar el nombre de la sede'**
  String get sedeSinRenombrarBoton;

  /// No description provided for @publicarAvisoDatosPersonales.
  ///
  /// In es, this message translates to:
  /// **'Por protección de datos, no incluyas datos personales de familiares (nombres, teléfonos, direcciones). Solo el nombre del fallecido y la información relevante para el público.'**
  String get publicarAvisoDatosPersonales;

  /// No description provided for @publicarNombreFallecido.
  ///
  /// In es, this message translates to:
  /// **'Nombre del fallecido'**
  String get publicarNombreFallecido;

  /// No description provided for @publicarAvisoRevisar.
  ///
  /// In es, this message translates to:
  /// **'Revisa bien todos los campos antes de publicar: si vienen de un escaneo, corrige o completa lo que haga falta.'**
  String get publicarAvisoRevisar;

  /// No description provided for @publicarFechaFallecimiento.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fallecimiento'**
  String get publicarFechaFallecimiento;

  /// No description provided for @publicarEdad.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get publicarEdad;

  /// No description provided for @publicarFechaFuneral.
  ///
  /// In es, this message translates to:
  /// **'Fecha del funeral'**
  String get publicarFechaFuneral;

  /// No description provided for @publicarHoraFuneral.
  ///
  /// In es, this message translates to:
  /// **'Hora del funeral'**
  String get publicarHoraFuneral;

  /// No description provided for @publicarIglesia.
  ///
  /// In es, this message translates to:
  /// **'Iglesia'**
  String get publicarIglesia;

  /// No description provided for @publicarLugar.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get publicarLugar;

  /// No description provided for @publicarCapillaArdiente.
  ///
  /// In es, this message translates to:
  /// **'Capilla ardiente / velatorio'**
  String get publicarCapillaArdiente;

  /// No description provided for @publicarSala.
  ///
  /// In es, this message translates to:
  /// **'Sala'**
  String get publicarSala;

  /// No description provided for @publicarVelatorioLabel.
  ///
  /// In es, this message translates to:
  /// **'Velatorio'**
  String get publicarVelatorioLabel;

  /// No description provided for @publicarEntierroLabel.
  ///
  /// In es, this message translates to:
  /// **'Entierro'**
  String get publicarEntierroLabel;

  /// No description provided for @publicarObservaciones.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get publicarObservaciones;

  /// No description provided for @publicarEscoitarEsquela.
  ///
  /// In es, this message translates to:
  /// **'Escuchar esquela'**
  String get publicarEscoitarEsquela;

  /// No description provided for @publicarPararEscoita.
  ///
  /// In es, this message translates to:
  /// **'Detener lectura'**
  String get publicarPararEscoita;

  /// No description provided for @publicarCompartirEsquela.
  ///
  /// In es, this message translates to:
  /// **'Compartir por WhatsApp'**
  String get publicarCompartirEsquela;

  /// No description provided for @publicarCompartidoPor.
  ///
  /// In es, this message translates to:
  /// **'Publicado por'**
  String get publicarCompartidoPor;

  /// No description provided for @publicarPublicadoPorSede.
  ///
  /// In es, this message translates to:
  /// **'Publicado por: {nombreCliente} ({nombreSede})'**
  String publicarPublicadoPorSede(String nombreCliente, String nombreSede);

  /// No description provided for @publicarDescargaApp.
  ///
  /// In es, this message translates to:
  /// **'Descarga TanApp:'**
  String get publicarDescargaApp;

  /// No description provided for @publicarCondolencias.
  ///
  /// In es, this message translates to:
  /// **'Enviar condolencias'**
  String get publicarCondolencias;

  /// No description provided for @publicarVerCondolencias.
  ///
  /// In es, this message translates to:
  /// **'Administrar condolencias'**
  String get publicarVerCondolencias;

  /// No description provided for @condolenciasCantidad.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, one{1 condolencia} other{{n} condolencias}}'**
  String condolenciasCantidad(int n);

  /// No description provided for @condolenciasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Condolencias de {nombre}'**
  String condolenciasTitulo(String nombre);

  /// No description provided for @condolenciasTuCondolencia.
  ///
  /// In es, this message translates to:
  /// **'Tu condolencia'**
  String get condolenciasTuCondolencia;

  /// No description provided for @condolenciasEscribeAqui.
  ///
  /// In es, this message translates to:
  /// **'Escribe aquí tu mensaje de pésame...'**
  String get condolenciasEscribeAqui;

  /// No description provided for @condolenciasTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas las condolencias'**
  String get condolenciasTodas;

  /// No description provided for @condolenciasVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ninguna condolencia.'**
  String get condolenciasVacio;

  /// No description provided for @condolenciasEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar condolencia'**
  String get condolenciasEliminarTitulo;

  /// No description provided for @condolenciasEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu condolencia? Esta acción no se puede deshacer.'**
  String get condolenciasEliminarMensaje;

  /// No description provided for @condolenciasDescargarPdf.
  ///
  /// In es, this message translates to:
  /// **'Descargar condolencias en PDF'**
  String get condolenciasDescargarPdf;

  /// No description provided for @condolenciasPdfTitulo.
  ///
  /// In es, this message translates to:
  /// **'Condolencias de {nombre}'**
  String condolenciasPdfTitulo(String nombre);

  /// No description provided for @condolenciasPdfSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Libro de condolencias'**
  String get condolenciasPdfSubtitulo;

  /// No description provided for @condolenciasPdfPie.
  ///
  /// In es, this message translates to:
  /// **'Descarga TanApp'**
  String get condolenciasPdfPie;

  /// No description provided for @condolenciasAnonimo.
  ///
  /// In es, this message translates to:
  /// **'Anónimo'**
  String get condolenciasAnonimo;

  /// No description provided for @condolenciasAnonimaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Publicar como anónima'**
  String get condolenciasAnonimaTitulo;

  /// No description provided for @condolenciasAnonimaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre no se mostrará a nadie, ni siquiera a quien ha publicado la esquela.'**
  String get condolenciasAnonimaAyuda;

  /// No description provided for @condolenciasPrivadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Condolencia privada'**
  String get condolenciasPrivadaTitulo;

  /// No description provided for @condolenciasPrivadaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Solo podrá verla quien ha publicado la esquela.'**
  String get condolenciasPrivadaAyuda;

  /// No description provided for @condolenciasModerarEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar condolencia'**
  String get condolenciasModerarEliminarTitulo;

  /// No description provided for @condolenciasModerarEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Se ocultará esta condolencia y se avisará a quien la escribió de que ha sido retirada por no ajustarse a las normas de uso. ¿Continuar?'**
  String get condolenciasModerarEliminarMensaje;

  /// No description provided for @condolenciasModerarEditarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Editar condolencia'**
  String get condolenciasModerarEditarTitulo;

  /// No description provided for @condolenciasModerarEditarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se avisará a quien la escribió de que has modificado el texto de su condolencia.'**
  String get condolenciasModerarEditarAyuda;

  /// No description provided for @condolenciasAvisoEliminada.
  ///
  /// In es, this message translates to:
  /// **'El cliente que publicó esta esquela ha eliminado tu condolencia por considerar que su contenido no era apropiado.'**
  String get condolenciasAvisoEliminada;

  /// No description provided for @condolenciasAvisoEditada.
  ///
  /// In es, this message translates to:
  /// **'El cliente que publicó esta esquela ha modificado el texto de tu condolencia por considerar que parte de su contenido no era apropiado.'**
  String get condolenciasAvisoEditada;

  /// No description provided for @elegirIdiomaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Elige tu idioma'**
  String get elegirIdiomaTitulo;

  /// No description provided for @elegirIdiomaMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿En qué idioma quieres usar TanApp? Podrás cambiarlo más adelante desde Mi cuenta.'**
  String get elegirIdiomaMensaje;

  /// No description provided for @publicarFuneralVoz.
  ///
  /// In es, this message translates to:
  /// **'El funeral será el {fecha} a las {hora}'**
  String publicarFuneralVoz(String fecha, String hora);

  /// No description provided for @publicarMisaVoz.
  ///
  /// In es, this message translates to:
  /// **'La misa será el {fecha} a las {hora}'**
  String publicarMisaVoz(String fecha, String hora);

  /// No description provided for @publicarActoVoz.
  ///
  /// In es, this message translates to:
  /// **'El acto será el {fecha} a las {hora}'**
  String publicarActoVoz(String fecha, String hora);

  /// No description provided for @tablonAumentarLetra.
  ///
  /// In es, this message translates to:
  /// **'Aumentar tamaño de letra'**
  String get tablonAumentarLetra;

  /// No description provided for @tablonDisminuirLetra.
  ///
  /// In es, this message translates to:
  /// **'Disminuir tamaño de letra'**
  String get tablonDisminuirLetra;

  /// No description provided for @publicarEdadInvalida.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número entero válido'**
  String get publicarEdadInvalida;

  /// No description provided for @publicarVistaPreviaTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Es correcto?'**
  String get publicarVistaPreviaTitulo;

  /// No description provided for @publicarFallecioEl.
  ///
  /// In es, this message translates to:
  /// **'Falleció el {fecha}'**
  String publicarFallecioEl(String fecha);

  /// No description provided for @publicarAnosDeEdad.
  ///
  /// In es, this message translates to:
  /// **'{edad, plural, =1{1 año} other{{edad} años}}'**
  String publicarAnosDeEdad(int edad);

  /// No description provided for @publicarPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicarPublicar;

  /// No description provided for @publicarPublicadoOk.
  ///
  /// In es, this message translates to:
  /// **'Publicación creada'**
  String get publicarPublicadoOk;

  /// No description provided for @publicarLeyendoEsquela.
  ///
  /// In es, this message translates to:
  /// **'Leyendo esquela…'**
  String get publicarLeyendoEsquela;

  /// No description provided for @publicarOcrSinTexto.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido leer texto en la foto. Rellena el formulario a mano.'**
  String get publicarOcrSinTexto;

  /// No description provided for @publicarOcrError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido leer la foto (detalle técnico: {detalle}). Rellena el formulario a mano; si puedes, haz una captura de este mensaje para reportarlo.'**
  String publicarOcrError(String detalle);

  /// No description provided for @publicarSinPublicaciones.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ninguna publicación'**
  String get publicarSinPublicaciones;

  /// No description provided for @publicarCambiosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get publicarCambiosGuardados;

  /// No description provided for @publicarEditarPublicacion.
  ///
  /// In es, this message translates to:
  /// **'Editar publicación'**
  String get publicarEditarPublicacion;

  /// No description provided for @publicarEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar publicación'**
  String get publicarEliminarTitulo;

  /// No description provided for @publicarEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar la publicación de {nombre}?'**
  String publicarEliminarMensaje(String nombre);

  /// No description provided for @publicarProgramarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Programar para más tarde'**
  String get publicarProgramarTitulo;

  /// No description provided for @publicarProgramarAyuda.
  ///
  /// In es, this message translates to:
  /// **'En vez de publicarse ahora, se publicará sola en la fecha y hora que elijas.'**
  String get publicarProgramarAyuda;

  /// No description provided for @publicarProgramarFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha de publicación'**
  String get publicarProgramarFecha;

  /// No description provided for @publicarProgramarHora.
  ///
  /// In es, this message translates to:
  /// **'Hora de publicación'**
  String get publicarProgramarHora;

  /// No description provided for @publicarProgramarEnElPasado.
  ///
  /// In es, this message translates to:
  /// **'La fecha y hora programadas tienen que ser posteriores a ahora.'**
  String get publicarProgramarEnElPasado;

  /// No description provided for @publicarProgramar.
  ///
  /// In es, this message translates to:
  /// **'Programar'**
  String get publicarProgramar;

  /// No description provided for @publicarProgramadaOk.
  ///
  /// In es, this message translates to:
  /// **'Publicación programada'**
  String get publicarProgramadaOk;

  /// No description provided for @publicarProgramacionActualizada.
  ///
  /// In es, this message translates to:
  /// **'Programación actualizada'**
  String get publicarProgramacionActualizada;

  /// No description provided for @publicarEditarProgramada.
  ///
  /// In es, this message translates to:
  /// **'Editar publicación programada'**
  String get publicarEditarProgramada;

  /// No description provided for @publicarProgramadasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Programadas'**
  String get publicarProgramadasTitulo;

  /// No description provided for @publicarPublicadasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Publicadas'**
  String get publicarPublicadasTitulo;

  /// No description provided for @publicarProgramadaPara.
  ///
  /// In es, this message translates to:
  /// **'Programada para el {fecha} a las {hora}'**
  String publicarProgramadaPara(String fecha, String hora);

  /// No description provided for @publicarCancelarProgramadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cancelar publicación programada'**
  String get publicarCancelarProgramadaTitulo;

  /// No description provided for @publicarCancelarProgramadaMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar la publicación programada de {nombre}? No se publicará.'**
  String publicarCancelarProgramadaMensaje(String nombre);

  /// No description provided for @tabPublicaciones.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get tabPublicaciones;

  /// No description provided for @arquivo.
  ///
  /// In es, this message translates to:
  /// **'Archivo'**
  String get arquivo;

  /// No description provided for @arquivoVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has guardado ninguna publicación'**
  String get arquivoVacio;

  /// No description provided for @arquivoGardado.
  ///
  /// In es, this message translates to:
  /// **'Guardado en mi archivo'**
  String get arquivoGardado;

  /// No description provided for @arquivoEliminado.
  ///
  /// In es, this message translates to:
  /// **'Eliminado de mi archivo'**
  String get arquivoEliminado;

  /// No description provided for @arquivoTooltipGardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar en mi archivo'**
  String get arquivoTooltipGardar;

  /// No description provided for @arquivoTooltipQuitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar de mi archivo'**
  String get arquivoTooltipQuitar;

  /// No description provided for @panelDatosPublicaciones.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get panelDatosPublicaciones;

  /// No description provided for @panelDatosCondolenciasPorMes.
  ///
  /// In es, this message translates to:
  /// **'Condolencias por mes'**
  String get panelDatosCondolenciasPorMes;

  /// No description provided for @panelDatosSeguidores.
  ///
  /// In es, this message translates to:
  /// **'Seguidores'**
  String get panelDatosSeguidores;

  /// No description provided for @panelDatosSeguidoresUnicos.
  ///
  /// In es, this message translates to:
  /// **'Seguidores únicos (si sigue varias sedes, cuenta una sola vez)'**
  String get panelDatosSeguidoresUnicos;

  /// No description provided for @panelDatosSinSeguidores.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tiene seguidores'**
  String get panelDatosSinSeguidores;

  /// No description provided for @panelDatosConcelloDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Sin concello indicado'**
  String get panelDatosConcelloDesconocido;

  /// No description provided for @panelDatosZonaSeguidores.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, one{+1 persona más recibe tus avisos por seguir la zona, sin seguirte a ti} other{+{n} personas más reciben tus avisos por seguir la zona, sin seguirte a ti}}'**
  String panelDatosZonaSeguidores(int n);

  /// No description provided for @panelDatosPublicacionesPorMes.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones por mes'**
  String get panelDatosPublicacionesPorMes;

  /// No description provided for @panelDatosAvisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get panelDatosAvisos;

  /// No description provided for @panelDatosAvisosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has enviado ningún aviso'**
  String get panelDatosAvisosVacio;

  /// No description provided for @panelDatosAvisosLeidos.
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get panelDatosAvisosLeidos;

  /// No description provided for @panelDatosAvisosPendientes.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get panelDatosAvisosPendientes;

  /// No description provided for @tablonBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar por texto, cliente o concello'**
  String get tablonBuscar;

  /// No description provided for @tablonSinResultados.
  ///
  /// In es, this message translates to:
  /// **'No se ha encontrado ninguna esquela con ese texto.'**
  String get tablonSinResultados;

  /// No description provided for @tablonVacioSinSeguir.
  ///
  /// In es, this message translates to:
  /// **'Todavía no ves ninguna esquela aquí: sigue a un cliente o a una zona en \"Seguindo\" para que aparezcan sus publicaciones.'**
  String get tablonVacioSinSeguir;

  /// No description provided for @filtrar.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filtrar;

  /// No description provided for @proximamente.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get proximamente;

  /// No description provided for @avisoSolicitudesPendientes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Tienes 1 solicitud de cliente pendiente de aprobar} other{Tienes {count} solicitudes de clientes pendientes de aprobar}}'**
  String avisoSolicitudesPendientes(int count);

  /// No description provided for @estadoAprobadaSingular.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get estadoAprobadaSingular;

  /// No description provided for @estadoRechazadaSingular.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get estadoRechazadaSingular;

  /// No description provided for @solicitudCrearCuentaBoton.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta de cliente'**
  String get solicitudCrearCuentaBoton;

  /// No description provided for @dashboardTitulo.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitulo;

  /// No description provided for @dashboardTabClientes.
  ///
  /// In es, this message translates to:
  /// **'Clientes'**
  String get dashboardTabClientes;

  /// No description provided for @dashboardTabUsuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get dashboardTabUsuarios;

  /// No description provided for @dashboardTabIa.
  ///
  /// In es, this message translates to:
  /// **'IA'**
  String get dashboardTabIa;

  /// No description provided for @dashboardTabEnVivo.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get dashboardTabEnVivo;

  /// No description provided for @enVivoConexionesAbiertas.
  ///
  /// In es, this message translates to:
  /// **'Conexiones abiertas'**
  String get enVivoConexionesAbiertas;

  /// No description provided for @enVivoFiltrarPorCliente.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por cliente'**
  String get enVivoFiltrarPorCliente;

  /// No description provided for @enVivoSinCoincidencias.
  ///
  /// In es, this message translates to:
  /// **'Ningún resultado con ese filtro.'**
  String get enVivoSinCoincidencias;

  /// No description provided for @enVivoVacio.
  ///
  /// In es, this message translates to:
  /// **'No hay ninguna sesión abierta ahora mismo.'**
  String get enVivoVacio;

  /// No description provided for @enVivoSinSede.
  ///
  /// In es, this message translates to:
  /// **'Sin sede asignada'**
  String get enVivoSinSede;

  /// No description provided for @enVivoUltimoAcceso.
  ///
  /// In es, this message translates to:
  /// **'último acceso {fecha}'**
  String enVivoUltimoAcceso(String fecha);

  /// No description provided for @enVivoCerrarSesionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get enVivoCerrarSesionTitulo;

  /// No description provided for @enVivoCerrarSesionMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar la sesión de \"{nombre}\"?'**
  String enVivoCerrarSesionMensaje(String nombre);

  /// No description provided for @dashboardSinDatos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay datos suficientes.'**
  String get dashboardSinDatos;

  /// No description provided for @dashboardClientesActivos.
  ///
  /// In es, this message translates to:
  /// **'Clientes activos'**
  String get dashboardClientesActivos;

  /// No description provided for @dashboardClientesInactivos.
  ///
  /// In es, this message translates to:
  /// **'Clientes inactivos'**
  String get dashboardClientesInactivos;

  /// No description provided for @dashboardSedesTotal.
  ///
  /// In es, this message translates to:
  /// **'Sedes/Tanatorios'**
  String get dashboardSedesTotal;

  /// No description provided for @dashboardPublicacionesTotal.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get dashboardPublicacionesTotal;

  /// No description provided for @dashboardAvisosTotal.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get dashboardAvisosTotal;

  /// No description provided for @dashboardCondolenciasTotal.
  ///
  /// In es, this message translates to:
  /// **'Condolencias'**
  String get dashboardCondolenciasTotal;

  /// No description provided for @dashboardClientesPorTipo.
  ///
  /// In es, this message translates to:
  /// **'Clientes por tipo'**
  String get dashboardClientesPorTipo;

  /// No description provided for @dashboardPublicacionesPorMes.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones por mes'**
  String get dashboardPublicacionesPorMes;

  /// No description provided for @dashboardAvisosPorMes.
  ///
  /// In es, this message translates to:
  /// **'Avisos por mes'**
  String get dashboardAvisosPorMes;

  /// No description provided for @dashboardAltasPorMes.
  ///
  /// In es, this message translates to:
  /// **'Altas por mes'**
  String get dashboardAltasPorMes;

  /// No description provided for @dashboardBajasPorMes.
  ///
  /// In es, this message translates to:
  /// **'Bajas por mes'**
  String get dashboardBajasPorMes;

  /// No description provided for @dashboardTopClientes.
  ///
  /// In es, this message translates to:
  /// **'Clientes con más publicaciones'**
  String get dashboardTopClientes;

  /// No description provided for @dashboardUsuariosActivos.
  ///
  /// In es, this message translates to:
  /// **'Usuarios activos'**
  String get dashboardUsuariosActivos;

  /// No description provided for @dashboardUsuariosInactivos.
  ///
  /// In es, this message translates to:
  /// **'Usuarios inactivos'**
  String get dashboardUsuariosInactivos;

  /// No description provided for @dashboardUsuariosConPush.
  ///
  /// In es, this message translates to:
  /// **'Con notificaciones activas'**
  String get dashboardUsuariosConPush;

  /// No description provided for @dashboardSeguimientosTotal.
  ///
  /// In es, this message translates to:
  /// **'Seguimientos a clientes'**
  String get dashboardSeguimientosTotal;

  /// No description provided for @dashboardZonasSeguidasTotal.
  ///
  /// In es, this message translates to:
  /// **'Zonas seguidas'**
  String get dashboardZonasSeguidasTotal;

  /// No description provided for @dashboardUsuariosPorIdioma.
  ///
  /// In es, this message translates to:
  /// **'Usuarios por idioma'**
  String get dashboardUsuariosPorIdioma;

  /// No description provided for @dashboardTopConcellos.
  ///
  /// In es, this message translates to:
  /// **'Concellos con más usuarios'**
  String get dashboardTopConcellos;

  /// No description provided for @dashboardIaAviso.
  ///
  /// In es, this message translates to:
  /// **'Datos aproximados del escaneo de esquelas con IA (no incluye la importación automática desde web). El coste es una estimación propia a partir de los tokens de cada petición, no el saldo real de la cuenta de Anthropic.'**
  String get dashboardIaAviso;

  /// No description provided for @dashboardIaPeticionesHoy.
  ///
  /// In es, this message translates to:
  /// **'Peticiones hoy'**
  String get dashboardIaPeticionesHoy;

  /// No description provided for @dashboardIaCostoHoy.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado hoy'**
  String get dashboardIaCostoHoy;

  /// No description provided for @dashboardIaPeticionesMes.
  ///
  /// In es, this message translates to:
  /// **'Peticiones este mes'**
  String get dashboardIaPeticionesMes;

  /// No description provided for @dashboardIaCostoMes.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado este mes'**
  String get dashboardIaCostoMes;

  /// No description provided for @dashboardIaPeticionesTotal.
  ///
  /// In es, this message translates to:
  /// **'Peticiones totales'**
  String get dashboardIaPeticionesTotal;

  /// No description provided for @dashboardIaCostoTotal.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado total'**
  String get dashboardIaCostoTotal;

  /// No description provided for @dashboardIaTasaExito.
  ///
  /// In es, this message translates to:
  /// **'Tasa de éxito'**
  String get dashboardIaTasaExito;

  /// No description provided for @dashboardIaPeticionesPorDia.
  ///
  /// In es, this message translates to:
  /// **'Peticiones por día (últimos 30 días)'**
  String get dashboardIaPeticionesPorDia;

  /// No description provided for @dashboardIaUsoPorUsuario.
  ///
  /// In es, this message translates to:
  /// **'Uso por usuario este mes'**
  String get dashboardIaUsoPorUsuario;

  /// No description provided for @dashboardIaColUsuario.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get dashboardIaColUsuario;

  /// No description provided for @dashboardIaColPeticiones.
  ///
  /// In es, this message translates to:
  /// **'Peticiones'**
  String get dashboardIaColPeticiones;

  /// No description provided for @dashboardIaColCosto.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado'**
  String get dashboardIaColCosto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'gl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'gl':
      return AppLocalizationsGl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
