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

  /// No description provided for @loginEresFuneraria.
  ///
  /// In es, this message translates to:
  /// **'¿Eres una funeraria o tanatorio? Solicita el alta'**
  String get loginEresFuneraria;

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

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get resetPasswordTitle;

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
  /// **'Contraseña actualizada, inicia sesión de nuevo'**
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

  /// No description provided for @validacionEmail.
  ///
  /// In es, this message translates to:
  /// **'Validación de email'**
  String get validacionEmail;

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

  /// No description provided for @volverAlInicio.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get volverAlInicio;

  /// No description provided for @solicitudIntro.
  ///
  /// In es, this message translates to:
  /// **'Solicita el alta de tu funeraria, tanatorio o parroquia en TanApp. Un administrador revisará tu solicitud antes de darte acceso.'**
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

  /// No description provided for @seguidosSeleccionaTipo.
  ///
  /// In es, this message translates to:
  /// **'¿A quién quiero seguir?'**
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
  /// **'{tipoNombre, select, Tanatorio{Todavía no hay ningún tanatorio activo en este concello} Funeraria{Todavía no hay ninguna funeraria activa en este concello} Parroquia{Todavía no hay ninguna parroquia activa en este concello} other{Todavía no hay ningún cliente activo en este concello}}'**
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
  /// **'Todavía no sigues a ningún cliente'**
  String get misSeguidosVacio;

  /// No description provided for @drawerMisSedes.
  ///
  /// In es, this message translates to:
  /// **'Mis sedes'**
  String get drawerMisSedes;

  /// No description provided for @misSedesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mis sedes'**
  String get misSedesTitulo;

  /// No description provided for @misSedesVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has dado de alta ninguna sede'**
  String get misSedesVacio;

  /// No description provided for @misSedesNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva sede'**
  String get misSedesNueva;

  /// No description provided for @misSedesEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar sede'**
  String get misSedesEditar;

  /// No description provided for @misSedesNombreSede.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la sede'**
  String get misSedesNombreSede;

  /// No description provided for @misSedesEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar sede'**
  String get misSedesEliminarTitulo;

  /// No description provided for @misSedesEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\"?'**
  String misSedesEliminarMensaje(String nombre);

  /// No description provided for @misSedesUltimaSedeAviso.
  ///
  /// In es, this message translates to:
  /// **'Debe quedar al menos una sede. Para eliminar esta, primero da de alta otra.'**
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

  /// No description provided for @publicarManual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get publicarManual;

  /// No description provided for @publicarNuevaPublicacion.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get publicarNuevaPublicacion;

  /// No description provided for @publicarSeleccionaSede.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la sede'**
  String get publicarSeleccionaSede;

  /// No description provided for @publicarSinSedes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes ninguna sede. Da de alta una sede en \"Miñas sedes\" antes de publicar.'**
  String get publicarSinSedes;

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

  /// No description provided for @publicarFuneralVoz.
  ///
  /// In es, this message translates to:
  /// **'El funeral será el {fecha} a las {hora}'**
  String publicarFuneralVoz(String fecha, String hora);

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

  /// No description provided for @panelDatosSeguidores.
  ///
  /// In es, this message translates to:
  /// **'Seguidores'**
  String get panelDatosSeguidores;

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

  /// No description provided for @tablonBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar por texto, cliente o concello'**
  String get tablonBuscar;

  /// No description provided for @misSeguidosBuscarYFiltrar.
  ///
  /// In es, this message translates to:
  /// **'Buscar y filtrar'**
  String get misSeguidosBuscarYFiltrar;

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
