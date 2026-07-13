// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TanApp';

  @override
  String get errorInesperado => 'Ha ocurrido un error inesperado';

  @override
  String get cuentaDesactivada =>
      'Tu cuenta está desactivada. Contacta con el administrador.';

  @override
  String validatorRequiredField(String field) {
    return '$field es obligatorio';
  }

  @override
  String get validatorEmailRequired => 'El email es obligatorio';

  @override
  String get validatorEmailInvalid => 'Introduce un email válido';

  @override
  String get validatorPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get validatorPasswordTooShort => 'Debe tener al menos 8 caracteres';

  @override
  String get validatorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get validatorOtpLength => 'Introduce el código de 6 dígitos';

  @override
  String get validatorOtpDigitsOnly => 'El código solo contiene números';

  @override
  String get validatorProvinciaRequired => 'La provincia es obligatoria';

  @override
  String get validatorConcelloRequired => 'El concello es obligatorio';

  @override
  String get confirmDialogConfirm => 'Confirmar';

  @override
  String get confirmDialogCancel => 'Cancelar';

  @override
  String get passwordFieldLabel => 'Contraseña';

  @override
  String get fieldNombre => 'Nombre';

  @override
  String get fieldPrimerApellido => 'Primer apellido';

  @override
  String get fieldSegundoApellidoOpcional => 'Segundo apellido (opcional)';

  @override
  String get fieldSegundoApellido => 'Segundo apellido';

  @override
  String get fieldTelefonoOpcional => 'Teléfono (opcional)';

  @override
  String get fieldTelefono => 'Teléfono';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldContrasena => 'La contraseña';

  @override
  String get fieldProvincia => 'Provincia';

  @override
  String get fieldConcello => 'Concello';

  @override
  String get fieldConfirmarContrasena => 'Confirmar contraseña';

  @override
  String errorCargarProvincias(String error) {
    return 'No se pudieron cargar las provincias: $error';
  }

  @override
  String errorCargarConcellos(String error) {
    return 'No se pudieron cargar los concellos: $error';
  }

  @override
  String get googleContinuar => 'Continuar con Google';

  @override
  String get googleConectando => 'Conectando…';

  @override
  String get googleRegistrarse => 'Regístrate con Google';

  @override
  String get o => 'o';

  @override
  String get drawerMiCuenta => 'Mi cuenta';

  @override
  String get drawerSistema => 'Sistema';

  @override
  String get drawerConfiguracion => 'Configuración';

  @override
  String get drawerCerrarSesion => 'Cerrar sesión';

  @override
  String get drawerCerrarSesionMensaje => '¿Seguro que quieres cerrar sesión?';

  @override
  String get loginTagline => 'Información funeraria';

  @override
  String get loginRecordarme => 'Recordarme';

  @override
  String get loginOlvidasteContrasena => '¿Olvidaste tu contraseña?';

  @override
  String get loginIniciarSesion => 'Iniciar sesión';

  @override
  String get loginNoTienesCuenta => '¿No tienes cuenta?';

  @override
  String get loginRegistrate => 'Regístrate';

  @override
  String get loginEresFuneraria =>
      '¿Eres una funeraria o tanatorio? Solicita el alta';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerYaTengoCuenta => 'Ya tengo cuenta, iniciar sesión';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordIntro =>
      'Introduce tu email y te enviaremos un código para restablecer tu contraseña.';

  @override
  String get forgotPasswordEnviarCodigo => 'Enviar código';

  @override
  String get resetPasswordTitle => 'Nueva contraseña';

  @override
  String get resetPasswordNuevaContrasena => 'Nueva contraseña';

  @override
  String get resetPasswordGuardar => 'Guardar contraseña';

  @override
  String get resetPasswordActualizada =>
      'Contraseña actualizada, inicia sesión de nuevo';

  @override
  String get verifyOtpTitle => 'Verificar código';

  @override
  String verifyOtpSentTo(String email) {
    return 'Hemos enviado un código de 6 dígitos a $email';
  }

  @override
  String get verifyOtpVerificar => 'Verificar';

  @override
  String get verifyOtpReenviar => 'Reenviar código';

  @override
  String verifyOtpReenviarCooldown(int segundos) {
    return 'Reenviar código (${segundos}s)';
  }

  @override
  String get verifyOtpCodigoReenviado => 'Código reenviado';

  @override
  String get verifyOtpNoSePudoReenviar => 'No se pudo reenviar el código';

  @override
  String get verifyOtpCodigoIncorrecto => 'Código incorrecto';

  @override
  String errorGenerico(String error) {
    return 'Error: $error';
  }

  @override
  String get accountTitle => 'Mi cuenta';

  @override
  String get accountNoSePudoCargarPerfil => 'No se pudo cargar tu perfil';

  @override
  String get accountFotoPerfil => 'Foto de perfil';

  @override
  String get accountDatosPersonales => 'Datos personales';

  @override
  String get accountFotoActualizada => 'Foto actualizada';

  @override
  String get accountNoSePudoSubirFoto => 'No se pudo subir la foto';

  @override
  String get accountDatosActualizados => 'Datos actualizados';

  @override
  String get accountCambiarContrasena => 'Cambiar contraseña';

  @override
  String get accountContrasenaActual => 'Contraseña actual';

  @override
  String get accountContrasenaActualIncorrecta =>
      'La contraseña actual no es correcta';

  @override
  String get accountNoSePudoVerificarIdentidad =>
      'No se pudo verificar tu identidad';

  @override
  String get accountContrasenaActualizada => 'Contraseña actualizada';

  @override
  String get accountActualizarContrasena => 'Actualizar contraseña';

  @override
  String get accountGuardarCambios => 'Guardar cambios';

  @override
  String get usuarioFichaTitulo => 'Ficha de usuario';

  @override
  String get usuarioCambiosGuardados => 'Cambios guardados';

  @override
  String get usuarioNoSePudoAsignarRol => 'No se pudo asignar el rol';

  @override
  String get usuarioQuitarRolTitulo => 'Quitar rol';

  @override
  String usuarioQuitarRolMensaje(String rol) {
    return '¿Quitar el rol \"$rol\" a este usuario?';
  }

  @override
  String get usuarioQuitar => 'Quitar';

  @override
  String get usuarioNoSePudoQuitarRol => 'No se pudo quitar el rol';

  @override
  String get usuarioYaTieneTodosLosRoles =>
      'Ya tiene todos los roles asignados';

  @override
  String get usuarioEmailValidado => 'Email validado';

  @override
  String get usuarioNoSePudoValidarEmail => 'No se pudo validar el email';

  @override
  String get usuarioEliminarTitulo => 'Eliminar usuario';

  @override
  String usuarioEliminarMensaje(String nombre) {
    return '¿Seguro que quieres eliminar a \"$nombre\"? Esta acción no se puede deshacer.';
  }

  @override
  String get usuarioEliminar => 'Eliminar';

  @override
  String get usuarioNoSePudoEliminar => 'No se pudo eliminar el usuario';

  @override
  String get usuarioIdiomaPreferido => 'Idioma preferido';

  @override
  String errorCargarIdiomas(String error) {
    return 'No se pudieron cargar los idiomas: $error';
  }

  @override
  String get usuarioActivo => 'Usuario activo';

  @override
  String get validacionEmail => 'Validación de email';

  @override
  String get marcarComoValidado => 'Marcar como validado';

  @override
  String get validado => 'Validado';

  @override
  String get roles => 'Roles';

  @override
  String get anadirRol => 'Añadir rol';

  @override
  String get sesiones => 'Sesiones';

  @override
  String get ocultarSesiones => 'Ocultar sesiones';

  @override
  String get verSesiones => 'Ver sesiones';

  @override
  String get sinSesionesRegistradas => 'Sin sesiones registradas';

  @override
  String get sesionColInicio => 'Inicio';

  @override
  String get sesionColFin => 'Fin';

  @override
  String get sesionColEstado => 'Estado';

  @override
  String get sesionColRecordar => 'Recordar';

  @override
  String get sesionEnCurso => 'En curso';

  @override
  String get sesionAbierta => 'Abierta';

  @override
  String get sesionCerrada => 'Cerrada';

  @override
  String get si => 'Sí';

  @override
  String get no => 'No';

  @override
  String errorCargarSesiones(String error) {
    return 'No se pudieron cargar las sesiones: $error';
  }

  @override
  String get solicitudTitulo => 'Solicitud de alta de cliente';

  @override
  String get solicitudEnviadaTitulo => 'Solicitud enviada';

  @override
  String get solicitudEnviadaMensaje =>
      'Hemos recibido tu solicitud. Un administrador la revisará y te contactaremos en breve.';

  @override
  String get volverAlInicio => 'Volver al inicio';

  @override
  String get solicitudIntro =>
      'Solicita el alta de tu funeraria, tanatorio o parroquia en TanApp. Un administrador revisará tu solicitud antes de darte acceso.';

  @override
  String get fieldRazonSocial => 'Razón social';

  @override
  String get fieldNifCif => 'NIF / CIF';

  @override
  String get fieldNombreContacto => 'Nombre de la persona de contacto';

  @override
  String get fieldEmailContacto => 'Email de contacto';

  @override
  String get fieldTelefonoContacto => 'Teléfono de contacto';

  @override
  String get fieldObservacionesOpcional => 'Observaciones (opcional)';

  @override
  String get enviarSolicitud => 'Enviar solicitud';

  @override
  String get volver => 'Volver';

  @override
  String get guardar => 'Guardar';

  @override
  String get editar => 'Editar';

  @override
  String get eliminar => 'Eliminar';

  @override
  String get cambiosGuardados => 'Cambios guardados';

  @override
  String get comunicacionNueva => 'Nueva comunicación';

  @override
  String get comunicacionEditar => 'Editar comunicación';

  @override
  String get comunicacionTipo => 'Tipo de comunicación';

  @override
  String get comunicacionCodigo => 'Código';

  @override
  String get comunicacionRemitente => 'Remitente';

  @override
  String get comunicacionActiva => 'Activa';

  @override
  String get comunicacionTextosPorIdioma => 'Textos por idioma';

  @override
  String comunicacionTextoGuardadoEnIdioma(String idioma) {
    return 'Texto en $idioma guardado';
  }

  @override
  String get comunicacionNoSePudoGuardar => 'No se pudo guardar';

  @override
  String get comunicacionAsunto => 'Asunto';

  @override
  String get comunicacionCuerpo => 'Cuerpo';

  @override
  String get comunicacionGuardarTexto => 'Guardar texto';

  @override
  String get comunicacionEliminarTitulo => 'Eliminar comunicación';

  @override
  String comunicacionEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"?';
  }

  @override
  String get configuracionComunicacionesTitulo =>
      'Configuración > Comunicaciones';

  @override
  String get noHayComunicacionesDadasDeAlta =>
      'No hay comunicaciones dadas de alta';

  @override
  String get inactiva => 'Inactiva';

  @override
  String get gestionUsuariosTitulo => 'Gestión de usuarios';

  @override
  String get buscarPorNombreEmail => 'Buscar por nombre o email';

  @override
  String get soloActivos => 'Solo activos';

  @override
  String get todosLosRoles => 'Todos los roles';

  @override
  String get noSeHanEncontradoUsuarios => 'No se han encontrado usuarios';

  @override
  String get pendiente => 'Pendiente';

  @override
  String get solicitudesClientesTitulo => 'Solicitudes de clientes';

  @override
  String get estadoTodas => 'Todas';

  @override
  String get estadoPendientes => 'Pendientes';

  @override
  String get estadoAprobadas => 'Aprobadas';

  @override
  String get estadoRechazadas => 'Rechazadas';

  @override
  String get noHaySolicitudesEnEsteEstado =>
      'No hay solicitudes en este estado';

  @override
  String get solicitudEliminarTitulo => 'Eliminar solicitud';

  @override
  String get solicitudEliminarMensaje =>
      '¿Seguro que quieres eliminar esta solicitud? Esta acción no se puede deshacer.';

  @override
  String get solicitudNoSePudoEliminar => 'No se pudo eliminar la solicitud';

  @override
  String get solicitudAprobarTitulo => 'Aprobar solicitud';

  @override
  String get solicitudRechazarTitulo => 'Rechazar solicitud';

  @override
  String get solicitudConfirmarAprobar =>
      '¿Confirmas que quieres aprobar esta solicitud de alta?';

  @override
  String get solicitudConfirmarRechazar =>
      '¿Confirmas que quieres rechazar esta solicitud de alta?';

  @override
  String get aprobar => 'Aprobar';

  @override
  String get rechazar => 'Rechazar';

  @override
  String get solicitudNoIdentificado =>
      'No se pudo identificar al usuario actual';

  @override
  String solicitudAprobadaSinCuenta(String error) {
    return 'Solicitud aprobada, pero no se pudo crear la cuenta del cliente: $error';
  }

  @override
  String get solicitudCuentaCreada => 'Cuenta de cliente creada';

  @override
  String solicitudNoSePudoCrearCuenta(String error) {
    return 'No se pudo crear la cuenta del cliente: $error';
  }

  @override
  String get solicitudDetalleTitulo => 'Solicitud de cliente';

  @override
  String get solicitudAprobarBoton => 'Aprobar solicitud';

  @override
  String get campoPersonaContacto => 'Persona de contacto';

  @override
  String get campoLocalidad => 'Localidad';

  @override
  String get campoObservaciones => 'Observaciones';

  @override
  String get campoObservacionesResolucion => 'Observaciones de resolución';

  @override
  String get fieldObservacionesResolucionOpcional =>
      'Observaciones de resolución (opcional)';

  @override
  String get provincias => 'Provincias';

  @override
  String get comunicaciones => 'Comunicaciones';

  @override
  String get configuracionProvinciasTitulo => 'Configuración > Provincias';

  @override
  String get noHayProvinciasDadasDeAlta => 'No hay provincias dadas de alta';

  @override
  String prefijoPostalLabel(String prefijo) {
    return 'Prefijo postal: $prefijo';
  }

  @override
  String get provinciaEliminarTitulo => 'Eliminar provincia';

  @override
  String provinciaEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"? También se eliminarán sus concellos.';
  }

  @override
  String get provinciaNueva => 'Nueva provincia';

  @override
  String get provinciaEditar => 'Editar provincia';

  @override
  String get fieldPrefijoPostal => 'Prefijo postal';

  @override
  String get errorPrefijoRequerido => 'El prefijo es obligatorio';

  @override
  String get errorNombreRequerido => 'El nombre es obligatorio';

  @override
  String concellosDeProvincia(String provincia) {
    return 'Concellos de $provincia';
  }

  @override
  String get concellosTitulo => 'Concellos';

  @override
  String get noHayConcellosDadosDeAlta => 'No hay concellos dados de alta';

  @override
  String get concelloEliminarTitulo => 'Eliminar concello';

  @override
  String concelloEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"?';
  }

  @override
  String get concelloNuevo => 'Nuevo concello';

  @override
  String get concelloEditar => 'Editar concello';

  @override
  String get gestionDeUsuarios => 'Gestión de Usuarios';

  @override
  String get solicitudesDeClientes => 'Solicitudes de Clientes';

  @override
  String holaNombre(String nombre) {
    return 'Hola, $nombre';
  }

  @override
  String get tablon => 'Tablón';

  @override
  String get seguidos => 'Seguidos';

  @override
  String get avisos => 'Avisos';

  @override
  String get proximamente => 'Próximamente';

  @override
  String avisoSolicitudesPendientes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count solicitudes de clientes pendientes de aprobar',
      one: 'Tienes 1 solicitud de cliente pendiente de aprobar',
    );
    return '$_temp0';
  }

  @override
  String get estadoAprobadaSingular => 'Aprobada';

  @override
  String get estadoRechazadaSingular => 'Rechazada';

  @override
  String get solicitudCrearCuentaBoton => 'Crear cuenta de cliente';
}
