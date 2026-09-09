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
  String validatorPasswordTooShortEstricta(int minimo) {
    return 'Debe tener al menos $minimo caracteres';
  }

  @override
  String get validatorPasswordSinLetraYNumero =>
      'Debe combinar letras y números';

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
  String passwordRequisitoLongitud(int minimo) {
    return 'Mínimo $minimo caracteres';
  }

  @override
  String get passwordRequisitoLetraNumero => 'Combina letras y números';

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
  String get fieldDireccion => 'Dirección completa';

  @override
  String get fieldNombreEmpresa => 'Nombre de la empresa';

  @override
  String get comoLlegar => 'Cómo llegar';

  @override
  String get mapa => 'Mapa';

  @override
  String get llamar => 'Llamar';

  @override
  String get filtroTodasProvincias => 'Todas';

  @override
  String get filtroTodosConcellos => 'Todos';

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
  String get facebookContinuar => 'Continuar con Facebook';

  @override
  String get facebookRegistrarse => 'Regístrate con Facebook';

  @override
  String get o => 'o';

  @override
  String get drawerMiCuenta => 'Mi cuenta';

  @override
  String get drawerDashboard => 'Dashboard';

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
  String get loginTaglineCliente => 'Acceso para funerarias y tanatorios';

  @override
  String get bienvenidaOpcionParticularTitulo => 'Quiero estar informado';

  @override
  String get bienvenidaOpcionParticularSubtitulo =>
      'Sigue esquelas, avisos y funerales de tu zona';

  @override
  String get bienvenidaOpcionClienteTitulo => 'Soy una funeraria o tanatorio';

  @override
  String get bienvenidaOpcionClienteSubtitulo =>
      'Accede o da de alta tu negocio en TanApp';

  @override
  String get bienvenidaEntrando => 'Iniciando sesión…';

  @override
  String get loginRecordarme => 'Recordarme';

  @override
  String get loginOlvidasteContrasena => '¿Olvidaste tu contraseña?';

  @override
  String get loginYaTengoCodigo => '¿Ya tienes un código?';

  @override
  String get loginIniciarSesion => 'Iniciar sesión';

  @override
  String get loginNoTienesCuenta => '¿No tienes cuenta?';

  @override
  String get loginRegistrate => 'Regístrate';

  @override
  String get loginEresFunerariaPregunta =>
      '¿Eres una funeraria o tanatorio y todavía no tienes cuenta?';

  @override
  String get loginSolicitarAlta => 'Solicitar alta';

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
  String get tengoCodigoTitulo => 'Introducir código';

  @override
  String get tengoCodigoIntro =>
      'Si ya has recibido un código de acceso por correo, escribe tu email para continuar.';

  @override
  String get tengoCodigoContinuar => 'Continuar';

  @override
  String get resetPasswordTitle => 'Nueva contraseña';

  @override
  String get resetPasswordInfo =>
      'Elige la contraseña con la que vas a acceder a TanApp a partir de ahora. Debe tener al menos 8 caracteres.';

  @override
  String get resetPasswordNuevaContrasena => 'Nueva contraseña';

  @override
  String get resetPasswordGuardar => 'Guardar contraseña';

  @override
  String get resetPasswordActualizada => 'Contraseña actualizada';

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
  String get accountNotificacionesPush =>
      'Deseo recibir notificaciones de las publicaciones en mi móvil.';

  @override
  String get accountDarseDeBajaTitulo => 'Darse de baja';

  @override
  String get accountDarseDeBajaAyuda =>
      'Al darte de baja tu cuenta se desactiva y se cierra tu sesión. Solo un administrador puede reactivarla.';

  @override
  String get accountDarseDeBajaMensaje =>
      '¿Seguro que quieres darte de baja? Tu cuenta se desactivará y se cerrará tu sesión.';

  @override
  String get accountCuentaPersonalTitulo => 'Tu cuenta personal';

  @override
  String get accountCuentaPersonalAyuda =>
      'Como cliente también puedes tener tu propia cuenta personal, separada de la de tu negocio, para seguir clientes y zonas y dejar condolencias como cualquier otro usuario.';

  @override
  String get accountCuentaPersonalEntrar => 'Entrar en tu cuenta personal';

  @override
  String get terminosTitulo => 'Antes de continuar';

  @override
  String terminosHeAceptado(String titulo) {
    return 'He leído y acepto: $titulo';
  }

  @override
  String get terminosContinuar => 'Continuar';

  @override
  String get terminosVerEnCuenta => 'Términos y privacidad';

  @override
  String get importacionWebTitulo => 'Importar datos automáticamente';

  @override
  String get importacionWebConsentimiento =>
      'Autorizo a TanApp a rastrear la web indicada más abajo para proponer esquelas automáticamente a partir de su contenido público. Cada propuesta la seguiré revisando y publicando yo mismo/a antes de que sea visible para el público; TanApp no publica nada sin mi revisión.';

  @override
  String get importacionWebAceptoCheckbox =>
      'Acepto y autorizo el rastreo de mi web';

  @override
  String get importacionWebUrlLabel => 'URL de mi web';

  @override
  String get importacionWebUrlInvalida =>
      'Introduce una URL válida (debe empezar por http:// o https://)';

  @override
  String get importacionWebGuardar => 'Guardar y autorizar';

  @override
  String get importacionWebActualizar => 'Actualizar URL';

  @override
  String get importacionWebDesactivar => 'Desactivar';

  @override
  String importacionWebActiva(String fecha) {
    return 'Activa desde $fecha';
  }

  @override
  String get importacionWebDesactivada => 'Desactivada';

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
  String get suplantarUsuario => 'Suplantar usuario';

  @override
  String suplantarMensaje(String nombre) {
    return 'Vas a iniciar sesión como \"$nombre\" para ver la app tal cual la ve. Podrás volver a tu cuenta de administrador en cualquier momento. ¿Continuar?';
  }

  @override
  String get suplantarConfirmar => 'Suplantar';

  @override
  String get suplantarCuentaPersonal => 'Suplantar cuenta personal';

  @override
  String usuarioEsCuentaPersonalDe(String nombre) {
    return 'Esta es la cuenta personal de $nombre (cliente)';
  }

  @override
  String get usuarioVerFichaCliente => 'Ver ficha del cliente';

  @override
  String get usuarioForzarCambioContrasenaTitulo =>
      'Obligar a cambiar contraseña';

  @override
  String usuarioForzarCambioContrasenaMensaje(String nombre) {
    return '\"$nombre\" tendrá que fijar una contraseña nueva la próxima vez que entre, antes de poder usar el resto de la app. ¿Continuar?';
  }

  @override
  String get usuarioForzarCambioContrasenaConfirmar => 'Obligar';

  @override
  String get usuarioForzarCambioContrasenaHecho =>
      'Se le pedirá una contraseña nueva en su próximo acceso';

  @override
  String get usuarioForzarCambioContrasenaPendiente => 'Pendiente';

  @override
  String get usuarioForzarCambioContrasenaAccion =>
      'Obligar a cambiar contraseña';

  @override
  String suplantacionBannerTexto(String nombre) {
    return 'Estás viendo la app como $nombre';
  }

  @override
  String get suplantacionVolver => 'Volver a mi cuenta';

  @override
  String get cuentaPropiaBannerTexto =>
      'Estás en tu cuenta personal de seguidor';

  @override
  String get cuentaPropiaVolver => 'Volver a mi cuenta de cliente';

  @override
  String get usuarioIdiomaPreferido => 'Idioma preferido';

  @override
  String errorCargarIdiomas(String error) {
    return 'No se pudieron cargar los idiomas: $error';
  }

  @override
  String get usuarioTipoCliente => 'Tipo de cliente';

  @override
  String errorCargarTiposCliente(String error) {
    return 'No se pudieron cargar los tipos de cliente: $error';
  }

  @override
  String get usuarioActivo => 'Usuario activo';

  @override
  String get usuarioImportacionWebSinConfigurar =>
      'Este cliente no ha configurado ninguna URL de importación automática.';

  @override
  String get usuarioImportacionWebActiva => 'Importación automática activa';

  @override
  String get usuarioEscaneoEsquelaIaTitulo => 'Escaneo de esquelas con IA';

  @override
  String get usuarioEscaneoEsquelaIaActiva =>
      'Escaneo con IA activo para este usuario';

  @override
  String get validacionEmail => 'Validación de email';

  @override
  String get usuarioTerminosTitulo => 'Términos y condiciones';

  @override
  String get usuarioTerminosAceptados => 'Aceptados';

  @override
  String get usuarioTerminosPendientes => 'Pendientes';

  @override
  String get terminosTipoUso => 'Términos de uso';

  @override
  String get terminosTipoPrivacidad => 'Política de privacidad';

  @override
  String get terminosCampoTitulo => 'Título';

  @override
  String get terminosCampoCuerpo => 'Contenido';

  @override
  String terminosContenidoGuardadoEnIdioma(String idioma) {
    return 'Contenido en $idioma guardado';
  }

  @override
  String get terminosColDocumento => 'Documento';

  @override
  String get terminosColFecha => 'Fecha';

  @override
  String get terminosVerTexto => 'Ver texto';

  @override
  String get terminosRolCliente => 'Cliente';

  @override
  String get terminosRolUsuarioOrdinario => 'Usuario ordinario';

  @override
  String get verDetalle => 'Ver detalle';

  @override
  String get ocultarDetalle => 'Ocultar detalle';

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
  String get sesionColDispositivo => 'Dispositivo';

  @override
  String get deslizaParaVerMas => 'Desliza para ver más';

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
  String get elegirSedeTitulo => '¿Con qué sede vas a trabajar?';

  @override
  String get elegirSedeMensaje =>
      'Elige la sede con la que vas a trabajar en esta sesión. Podrás cambiarla más adelante cuando quieras.';

  @override
  String get sedeLimiteTitulo => 'Límite de sesiones alcanzado';

  @override
  String sedeLimiteMensaje(String sede) {
    return 'Ya hay 2 sesiones abiertas trabajando como \"$sede\". Si continúas, se cerrará la más antigua.';
  }

  @override
  String get sedeLimiteConfirmar => 'Cerrar la más antigua y continuar';

  @override
  String sedeActualTexto(String sede) {
    return 'Sede: $sede';
  }

  @override
  String get sedeActualCambiar => 'Cambiar sede';

  @override
  String get solicitudTitulo => 'Solicitud de alta de cliente';

  @override
  String get solicitudEnviadaTitulo => 'Solicitud enviada';

  @override
  String get solicitudEnviadaMensaje =>
      'Hemos recibido tu solicitud. Un administrador la revisará y te contactaremos en breve.';

  @override
  String get solicitudEnviadaProcesoTitulo => '¿Qué pasa ahora?';

  @override
  String get solicitudEnviadaPaso1 =>
      'Revisamos tu solicitud (normalmente en 1-2 días laborables).';

  @override
  String get solicitudEnviadaPaso2 =>
      'Cuando se apruebe, te llegará un correo con tu código de acceso.';

  @override
  String get solicitudEnviadaPaso3 =>
      'Abre la app, en la pantalla de inicio de sesión pulsa \"¿Ya tienes un código?\", introduce tu email y el código para fijar tu contraseña y entrar.';

  @override
  String get volverAlInicio => 'Volver al inicio';

  @override
  String get solicitudIntro =>
      'Solicita el alta de tu funeraria o tanatorio en TanApp. Un administrador revisará tu solicitud antes de darte acceso.';

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
  String get tiposCliente => 'Tipos de Clientes';

  @override
  String get configuracionTiposClienteTitulo =>
      'Configuración > Tipos de Clientes';

  @override
  String get tiposActo => 'Tipos de acto';

  @override
  String get configuracionTiposActoTitulo => 'Configuración > Tipos de acto';

  @override
  String get noHayTiposActoDadosDeAlta => 'No hay tipos de acto dados de alta';

  @override
  String get actoTipoNuevo => 'Nuevo tipo de acto';

  @override
  String get actoTipoEditar => 'Editar tipo de acto';

  @override
  String get actoTipoActivo => 'Activo';

  @override
  String get actoTipoEliminarTitulo => 'Eliminar tipo de acto';

  @override
  String actoTipoEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"?';
  }

  @override
  String get configuracionIa => 'Configuración IA';

  @override
  String get configuracionIaTitulo => 'Configuración > IA';

  @override
  String get configuracionIaImportacionWebLabel =>
      'Importación de esquelas con IA';

  @override
  String get configuracionIaImportacionWebDescripcion =>
      'Si la desactivas, ningún cliente podrá activar la importación automática de su web ni ver propuestas, aunque ya la tuviera configurada.';

  @override
  String get configuracionIaEscaneoEsquelaLabel => 'Escaneo de esquelas con IA';

  @override
  String get configuracionIaEscaneoEsquelaDescripcion =>
      'Si está activado, al escanear una esquela la foto se analiza con IA en vez del reconocimiento de texto local. Si la desactivas (o falla), se sigue usando el escaneo local de siempre.';

  @override
  String get configuracionLoginTitulo => 'Login';

  @override
  String get configuracionLoginGoogleLabel => 'Iniciar sesión con Google';

  @override
  String get configuracionLoginGoogleDescripcion =>
      'Si lo desactivas, el botón \"Continuar con Google\" desaparece de las pantallas de acceso y registro de usuario ordinario.';

  @override
  String get configuracionLoginFacebookLabel => 'Iniciar sesión con Facebook';

  @override
  String get configuracionLoginFacebookDescripcion =>
      'Si lo desactivas, el botón \"Continuar con Facebook\" desaparece de las pantallas de acceso y registro de usuario ordinario.';

  @override
  String get noHayTiposClienteDadosDeAlta =>
      'No hay tipos de cliente dados de alta';

  @override
  String get clienteTipoNuevo => 'Nuevo tipo de cliente';

  @override
  String get clienteTipoEditar => 'Editar tipo de cliente';

  @override
  String get clienteTipoActivo => 'Activo';

  @override
  String get clienteTipoEliminarTitulo => 'Eliminar tipo de cliente';

  @override
  String clienteTipoEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"?';
  }

  @override
  String get clienteTipoTraduccionesPorIdioma => 'Traducciones por idioma';

  @override
  String get clienteTipoGuardarTraduccion => 'Guardar traducción';

  @override
  String clienteTipoTraduccionGuardadaEnIdioma(String idioma) {
    return 'Traducción en $idioma guardada';
  }

  @override
  String get clienteTipoNoSePudoGuardar => 'No se pudo guardar';

  @override
  String get solicitudSeleccionarTipoCliente => 'Selecciona el tipo de cliente';

  @override
  String get solicitudTipoClienteObligatorio =>
      'El tipo de cliente es obligatorio para aprobar la solicitud';

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
  String get seguidos => 'Buscar';

  @override
  String get avisos => 'Avisos';

  @override
  String get avisosNuevo => 'Aviso';

  @override
  String get avisosFormTitulo => 'Nuevo aviso';

  @override
  String get avisosTituloLabel => 'Título';

  @override
  String get avisosTextoLabel => 'Texto';

  @override
  String get avisosEnviar => 'Enviar';

  @override
  String get avisosEnviadoOk => 'Aviso enviado';

  @override
  String avisosEnviadoEl(String fecha, String hora) {
    return 'Enviado el $fecha a las $hora';
  }

  @override
  String get avisosVacioEnviados => 'No has enviado ningún aviso todavía.';

  @override
  String get avisosVacioRecibidos => 'No tienes avisos.';

  @override
  String get avisosCerrar => 'Cerrar';

  @override
  String get avisosEliminarTitulo => 'Eliminar aviso';

  @override
  String avisosEliminarMensaje(String titulo) {
    return '¿Eliminar el aviso \"$titulo\"? Esta acción no se puede deshacer.';
  }

  @override
  String avisosEliminarSeleccionadosMensaje(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Eliminar los $count avisos seleccionados? Esta acción no se puede deshacer.',
      one: '¿Eliminar el aviso seleccionado? Esta acción no se puede deshacer.',
    );
    return '$_temp0';
  }

  @override
  String get avisosVaciarTodoTitulo => 'Vaciar avisos';

  @override
  String get avisosVaciarTodoMensaje =>
      '¿Eliminar todos tus avisos? Esta acción no se puede deshacer.';

  @override
  String avisosNSeleccionados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get avisosCancelarSeleccion => 'Cancelar';

  @override
  String get avisosSeleccionar => 'Seleccionar';

  @override
  String get avisosEditarProgramado => 'Editar aviso programado';

  @override
  String get avisosProgramadosTitulo => 'Programados';

  @override
  String get avisosCancelarProgramadoTitulo => 'Cancelar aviso programado';

  @override
  String avisosCancelarProgramadoMensaje(String titulo) {
    return '¿Seguro que quieres cancelar el aviso programado \"$titulo\"? No se enviará.';
  }

  @override
  String get avisosTabRecibidos => 'Recibidos';

  @override
  String get avisosTabRecordatorios => 'Recordatorios';

  @override
  String get recordatorioBoton => 'Recordatorio';

  @override
  String get recordatorioModalTitulo => 'Recordatorios';

  @override
  String get recordatorioVacio =>
      'No tienes ningún recordatorio para esta publicación.';

  @override
  String get recordatorioMaximoAlcanzado =>
      'Ya tienes el máximo de 2 recordatorios para esta publicación.';

  @override
  String get recordatorioAnadir => 'Añadir recordatorio';

  @override
  String get recordatorioFechaInvalida =>
      'Elige una fecha y hora posteriores a ahora y anteriores al evento.';

  @override
  String get recordatorioEliminarTitulo => 'Eliminar recordatorio';

  @override
  String get recordatorioEliminarMensaje =>
      '¿Eliminar este recordatorio? Esta acción no se puede deshacer.';

  @override
  String recordatorioProgramadoPara(String fecha) {
    return 'Te avisaremos el $fecha';
  }

  @override
  String get recordatorioListaVacia => 'No tienes recordatorios configurados.';

  @override
  String get recordatorioRecibidoTitulo => 'Recordatorio';

  @override
  String get recordatorioRecibidoTexto =>
      'Tenías un recordatorio pendiente de esta publicación.';

  @override
  String get recordatorioRecibidoSeccion => 'Recordatorios';

  @override
  String get recordatorioTipoEsquela => 'Esquela';

  @override
  String get seguidosSeleccionaTipo => 'Elige a quién seguir';

  @override
  String get seguidosSeleccionaProvincia => 'Elige la provincia';

  @override
  String get seguidosSeleccionaConcello => 'Elige el concello';

  @override
  String get seguidosBuscarConcello => 'Buscar concello';

  @override
  String seguidosNoHayActivosNesteConcello(String tipoNombre) {
    String _temp0 = intl.Intl.selectLogic(tipoNombre, {
      'Tanatorio': 'Todavía no hay ningún tanatorio activo en este concello',
      'Funeraria': 'Todavía no hay ninguna funeraria activa en este concello',
      'other': 'Todavía no hay ningún cliente activo en este concello',
    });
    return '$_temp0';
  }

  @override
  String get seguidosSeguir => 'Seguir';

  @override
  String get seguidosDejarDeSeguir => 'Dejar de seguir';

  @override
  String get seguidosSilenciar => 'Desactivar notificaciones';

  @override
  String get seguidosActivarAvisos => 'Activar notificaciones';

  @override
  String get seguidosSiguiendoEtiqueta => 'Siguiendo';

  @override
  String get seguidosNoSiguiendoEtiqueta => 'No sigues';

  @override
  String get siguiendoTab => 'Siguiendo';

  @override
  String get misSeguidosBuscarNombre => 'Buscar por nombre';

  @override
  String get misSeguidosVacio =>
      'Todavía no sigues a ningún cliente. Usa \"Seguir un cliente nuevo\" para buscar funerarias y tanatorios.';

  @override
  String get misSeguidosTabClientes => 'Clientes';

  @override
  String get misSeguidosTabZonas => 'Zonas';

  @override
  String get misSeguidosSeguirNuevo => 'Seguir un cliente nuevo';

  @override
  String get zonaTitulo => 'Zona';

  @override
  String get zonaExplicacion =>
      'Sigue un concello sin tener que buscar y seguir a cada cliente por separado: recibirás los avisos de cualquier cliente con sede ahí.';

  @override
  String get zonaSeguir => 'Seguir';

  @override
  String get zonaDejarDeSeguir => 'Dejar de seguir';

  @override
  String get zonaSeguirNueva => 'Seguir una zona nueva';

  @override
  String get misZonasVacio =>
      'Todavía no sigues ninguna zona. Usa \"Seguir una zona nueva\" para recibir avisos de todo un concello.';

  @override
  String get drawerMisSedes => 'Mis sedes/tanatorios';

  @override
  String get drawerContactarSoporte => 'Contactar con soporte';

  @override
  String get soporteAsuntoPorDefecto => 'Soporte TanApp';

  @override
  String get misSedesTitulo => 'Mis sedes/tanatorios';

  @override
  String get misSedesVacio =>
      'Todavía no has dado de alta ninguna sede/tanatorio';

  @override
  String get misSedesNueva => 'Nueva sede/tanatorio';

  @override
  String get misSedesEditar => 'Editar sede/tanatorio';

  @override
  String get misSedesNombreSede => 'Nombre de la sede/tanatorio';

  @override
  String get misSedesNombreAyuda =>
      'Es el nombre que aparecerá en las notificaciones, avisos y esquelas de esta sede.';

  @override
  String get misSedesEliminarTitulo => 'Eliminar sede/tanatorio';

  @override
  String misSedesEliminarMensaje(String nombre) {
    return '¿Eliminar \"$nombre\"?';
  }

  @override
  String get misSedesUltimaSedeAviso =>
      'Debe quedar al menos una sede/tanatorio. Para eliminar esta, primero da de alta otra.';

  @override
  String get misSedesCodigo => 'Código';

  @override
  String get tabPublicar => 'Publicar';

  @override
  String get tabPanelDatos => 'Panel de Datos';

  @override
  String get publicarEscanear => 'Escanear';

  @override
  String get publicarEscanearAyuda =>
      '¿Tienes la esquela en papel o en una foto? Escanéala y te rellenamos el formulario.';

  @override
  String get publicarManual => 'Manual';

  @override
  String get publicarDeceso => 'Deceso';

  @override
  String get publicarImportarWeb => 'Importación automática';

  @override
  String get publicarPropuestas => 'Propuestas';

  @override
  String get publicarAvisoImportadoWeb =>
      'Datos importados automáticamente desde tu web. Revisa todos los campos antes de publicar.';

  @override
  String get propuestasTitulo => 'Propuestas de publicación';

  @override
  String get propuestasVacio => 'No hay propuestas pendientes de revisar.';

  @override
  String propuestasDetectadaEl(String fecha) {
    return 'Detectada el $fecha';
  }

  @override
  String get propuestasRevisar => 'Revisar';

  @override
  String get propuestasDescartar => 'Descartar';

  @override
  String get propuestasConfirmarDescartarTitulo => 'Descartar propuesta';

  @override
  String propuestasConfirmarDescartarMensaje(String nombre) {
    return '¿Descartar la propuesta de \"$nombre\"? No se publicará y no se volverá a proponer.';
  }

  @override
  String get propuestasImportarAhora => 'Importar ahora';

  @override
  String get propuestasImportando => 'Importando';

  @override
  String propuestasImportarAhoraResultado(int nuevas) {
    String _temp0 = intl.Intl.pluralLogic(
      nuevas,
      locale: localeName,
      other: 'Se han encontrado $nuevas esquelas nuevas.',
      one: 'Se ha encontrado 1 esquela nueva.',
      zero: 'No se ha encontrado ninguna esquela nueva.',
    );
    return '$_temp0';
  }

  @override
  String get importacionWebReconfigurar => 'Configurar importación automática';

  @override
  String get publicarNuevaPublicacion => 'Nueva publicación';

  @override
  String get publicarMisa => 'Misa/Acto';

  @override
  String get publicarNuevoActo => 'Nueva/o Misa/Acto';

  @override
  String get publicarEditarActo => 'Editar Misa/Acto';

  @override
  String get publicarEnMemoriaDe => 'En memoria de';

  @override
  String get publicarTipoActo => 'Tipo de acto';

  @override
  String get publicarTipoActoOtroOpcion => 'Otro';

  @override
  String get publicarTipoActoOtro => 'Especifica el tipo de acto';

  @override
  String get publicarFechaActo => 'Fecha del acto';

  @override
  String get publicarHoraActo => 'Hora del acto';

  @override
  String get publicarActoLabel => 'Acto';

  @override
  String get publicarIglesiaLocalizacion => 'Iglesia/Localización';

  @override
  String get publicarSeleccionaSede => 'Selecciona la sede/tanatorio';

  @override
  String get publicarSinSedes =>
      'Todavía no tienes ninguna sede/tanatorio. Da de alta una en \"Miñas sedes\" antes de publicar.';

  @override
  String get sedeSinRenombrarAviso =>
      'Antes de publicar esquelas o enviar avisos, revisa (o cambia) el nombre de tu sede desde \"Mis sedes\". Es el nombre que aparecerá en las notificaciones, avisos y esquelas que envíes.';

  @override
  String get sedeSinRenombrarBoton => 'Cambiar el nombre de la sede';

  @override
  String get publicarAvisoDatosPersonales =>
      'Por protección de datos, no incluyas datos personales de familiares (nombres, teléfonos, direcciones). Solo el nombre del fallecido y la información relevante para el público.';

  @override
  String get publicarNombreFallecido => 'Nombre del fallecido';

  @override
  String get publicarAvisoRevisar =>
      'Revisa bien todos los campos antes de publicar: si vienen de un escaneo, corrige o completa lo que haga falta.';

  @override
  String get publicarFechaFallecimiento => 'Fecha de fallecimiento';

  @override
  String get publicarEdad => 'Edad';

  @override
  String get publicarFechaFuneral => 'Fecha del funeral';

  @override
  String get publicarHoraFuneral => 'Hora del funeral';

  @override
  String get publicarIglesia => 'Iglesia';

  @override
  String get publicarLugar => 'Lugar';

  @override
  String get publicarCapillaArdiente => 'Capilla ardiente / velatorio';

  @override
  String get publicarSala => 'Sala';

  @override
  String get publicarVelatorioLabel => 'Velatorio';

  @override
  String get publicarEntierroLabel => 'Entierro';

  @override
  String get publicarObservaciones => 'Observaciones';

  @override
  String get publicarEscoitarEsquela => 'Escuchar esquela';

  @override
  String get publicarPararEscoita => 'Detener lectura';

  @override
  String get publicarCompartirEsquela => 'Compartir por WhatsApp';

  @override
  String get publicarCompartidoPor => 'Publicado por';

  @override
  String publicarPublicadoPorSede(String nombreCliente, String nombreSede) {
    return 'Publicado por: $nombreCliente ($nombreSede)';
  }

  @override
  String get publicarDescargaApp => 'Descarga TanApp:';

  @override
  String get publicarCondolencias => 'Enviar condolencias';

  @override
  String get publicarVerCondolencias => 'Administrar condolencias';

  @override
  String condolenciasCantidad(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n condolencias',
      one: '1 condolencia',
    );
    return '$_temp0';
  }

  @override
  String condolenciasTitulo(String nombre) {
    return 'Condolencias de $nombre';
  }

  @override
  String get condolenciasTuCondolencia => 'Tu condolencia';

  @override
  String get condolenciasEscribeAqui => 'Escribe aquí tu mensaje de pésame...';

  @override
  String get condolenciasTodas => 'Todas las condolencias';

  @override
  String get condolenciasVacio => 'Todavía no hay ninguna condolencia.';

  @override
  String get condolenciasEliminarTitulo => 'Eliminar condolencia';

  @override
  String get condolenciasEliminarMensaje =>
      '¿Eliminar tu condolencia? Esta acción no se puede deshacer.';

  @override
  String get condolenciasDescargarPdf => 'Descargar condolencias en PDF';

  @override
  String condolenciasPdfTitulo(String nombre) {
    return 'Condolencias de $nombre';
  }

  @override
  String get condolenciasPdfSubtitulo => 'Libro de condolencias';

  @override
  String get condolenciasPdfPie => 'Descarga TanApp';

  @override
  String get condolenciasAnonimo => 'Anónimo';

  @override
  String get condolenciasAnonimaTitulo => 'Publicar como anónima';

  @override
  String get condolenciasAnonimaAyuda =>
      'Tu nombre no se mostrará a nadie, ni siquiera a quien ha publicado la esquela.';

  @override
  String get condolenciasPrivadaTitulo => 'Condolencia privada';

  @override
  String get condolenciasPrivadaAyuda =>
      'Solo podrá verla quien ha publicado la esquela.';

  @override
  String get condolenciasNoAdmite => 'Esta publicación no admite condolencias.';

  @override
  String get condolenciasSoloPrivadasAviso =>
      'Quien ha publicado esta esquela ha decidido que todas las condolencias sean privadas: solo esa persona podrá verla.';

  @override
  String get condolenciasModerarEliminarTitulo => 'Eliminar condolencia';

  @override
  String get condolenciasModerarEliminarMensaje =>
      'Se ocultará esta condolencia y se avisará a quien la escribió de que ha sido retirada por no ajustarse a las normas de uso. ¿Continuar?';

  @override
  String get condolenciasModerarEditarTitulo => 'Editar condolencia';

  @override
  String get condolenciasModerarEditarAyuda =>
      'Se avisará a quien la escribió de que has modificado el texto de su condolencia.';

  @override
  String get condolenciasAvisoEliminada =>
      'El cliente que publicó esta esquela ha eliminado tu condolencia por considerar que su contenido no era apropiado.';

  @override
  String get condolenciasAvisoEditada =>
      'El cliente que publicó esta esquela ha modificado el texto de tu condolencia por considerar que parte de su contenido no era apropiado.';

  @override
  String get elegirIdiomaTitulo => 'Elige tu idioma';

  @override
  String get elegirIdiomaMensaje =>
      '¿En qué idioma quieres usar TanApp? Podrás cambiarlo más adelante desde Mi cuenta.';

  @override
  String publicarFuneralVoz(String fecha, String hora) {
    return 'El funeral será el $fecha a las $hora';
  }

  @override
  String publicarMisaVoz(String fecha, String hora) {
    return 'La misa será el $fecha a las $hora';
  }

  @override
  String publicarActoVoz(String fecha, String hora) {
    return 'El acto será el $fecha a las $hora';
  }

  @override
  String get tablonAumentarLetra => 'Aumentar tamaño de letra';

  @override
  String get tablonDisminuirLetra => 'Disminuir tamaño de letra';

  @override
  String get publicarEdadInvalida => 'Introduce un número entero válido';

  @override
  String get publicarVistaPreviaTitulo => '¿Es correcto?';

  @override
  String get publicarCondolenciasPreguntaTitulo => 'Condolencias';

  @override
  String get publicarAdmiteCondolencias => 'Admitir condolencias';

  @override
  String get publicarAdmiteCondolenciasAyuda =>
      'Los seguidores podrán dejar mensajes de pésame en esta esquela.';

  @override
  String get publicarCondolenciasPrivadas => 'Solo condolencias privadas';

  @override
  String get publicarCondolenciasPrivadasAyuda =>
      'Todas las condolencias que se dejen aquí serán privadas: solo tú podrás verlas.';

  @override
  String get publicarCondolenciasContinuar => 'Continuar';

  @override
  String publicarFallecioEl(String fecha) {
    return 'Falleció el $fecha';
  }

  @override
  String publicarAnosDeEdad(int edad) {
    String _temp0 = intl.Intl.pluralLogic(
      edad,
      locale: localeName,
      other: '$edad años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get publicarPublicar => 'Publicar';

  @override
  String get publicarPublicadoOk => 'Publicación creada';

  @override
  String get publicarLeyendoEsquela => 'Leyendo esquela…';

  @override
  String get publicarOcrSinTexto =>
      'No se ha podido leer texto en la foto. Rellena el formulario a mano.';

  @override
  String publicarOcrError(String detalle) {
    return 'No se ha podido leer la foto (detalle técnico: $detalle). Rellena el formulario a mano; si puedes, haz una captura de este mensaje para reportarlo.';
  }

  @override
  String get publicarSinPublicaciones => 'Todavía no hay ninguna publicación';

  @override
  String get publicarCambiosGuardados => 'Cambios guardados';

  @override
  String get publicarEditarPublicacion => 'Editar publicación';

  @override
  String get publicarEliminarTitulo => 'Eliminar publicación';

  @override
  String publicarEliminarMensaje(String nombre) {
    return '¿Seguro que quieres eliminar la publicación de $nombre?';
  }

  @override
  String get publicarProgramarTitulo => 'Programar para más tarde';

  @override
  String get publicarProgramarAyuda =>
      'En vez de publicarse ahora, se publicará sola en la fecha y hora que elijas.';

  @override
  String get publicarProgramarFecha => 'Fecha de publicación';

  @override
  String get publicarProgramarHora => 'Hora de publicación';

  @override
  String get publicarProgramarEnElPasado =>
      'La fecha y hora programadas tienen que ser posteriores a ahora.';

  @override
  String get publicarProgramar => 'Programar';

  @override
  String get publicarProgramadaOk => 'Publicación programada';

  @override
  String get publicarProgramacionActualizada => 'Programación actualizada';

  @override
  String get publicarEditarProgramada => 'Editar publicación programada';

  @override
  String get publicarProgramadasTitulo => 'Programadas';

  @override
  String get publicarPublicadasTitulo => 'Publicadas';

  @override
  String publicarProgramadaPara(String fecha, String hora) {
    return 'Programada para el $fecha a las $hora';
  }

  @override
  String get publicarCancelarProgramadaTitulo =>
      'Cancelar publicación programada';

  @override
  String publicarCancelarProgramadaMensaje(String nombre) {
    return '¿Seguro que quieres cancelar la publicación programada de $nombre? No se publicará.';
  }

  @override
  String get tabPublicaciones => 'Publicaciones';

  @override
  String get arquivo => 'Archivo';

  @override
  String get arquivoVacio => 'Todavía no has guardado ninguna publicación';

  @override
  String get arquivoGardado => 'Guardado en mi archivo';

  @override
  String get arquivoEliminado => 'Eliminado de mi archivo';

  @override
  String get arquivoTooltipGardar => 'Guardar en mi archivo';

  @override
  String get arquivoTooltipQuitar => 'Quitar de mi archivo';

  @override
  String get panelDatosPublicaciones => 'Publicaciones';

  @override
  String get panelDatosCondolenciasPorMes => 'Condolencias por mes';

  @override
  String get panelDatosSeguidores => 'Seguidores';

  @override
  String get panelDatosSeguidoresUnicos =>
      'Seguidores únicos (si sigue varias sedes, cuenta una sola vez)';

  @override
  String get panelDatosSinSeguidores => 'Todavía no tiene seguidores';

  @override
  String get panelDatosConcelloDesconocido => 'Sin concello indicado';

  @override
  String panelDatosZonaSeguidores(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '+$n personas más reciben tus avisos por seguir la zona, sin seguirte a ti',
      one:
          '+1 persona más recibe tus avisos por seguir la zona, sin seguirte a ti',
    );
    return '$_temp0';
  }

  @override
  String get panelDatosPublicacionesPorMes => 'Publicaciones por mes';

  @override
  String get panelDatosAvisos => 'Avisos';

  @override
  String get panelDatosAvisosVacio => 'Todavía no has enviado ningún aviso';

  @override
  String get panelDatosAvisosLeidos => 'Leídos';

  @override
  String get panelDatosAvisosPendientes => 'Sin leer';

  @override
  String get tablonBuscar => 'Buscar por texto, cliente o concello';

  @override
  String get tablonSinResultados =>
      'No se ha encontrado ninguna esquela con ese texto.';

  @override
  String get tablonVacioSinSeguir =>
      'Todavía no ves ninguna esquela aquí: sigue a un cliente o a una zona en \"Seguindo\" para que aparezcan sus publicaciones.';

  @override
  String get tablonHayNuevas => 'Hay nuevas publicaciones';

  @override
  String get filtrar => 'Filtrar';

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

  @override
  String get dashboardTitulo => 'Dashboard';

  @override
  String get dashboardTabClientes => 'Clientes';

  @override
  String get dashboardTabUsuarios => 'Usuarios';

  @override
  String get dashboardTabIa => 'IA';

  @override
  String get dashboardTabEnVivo => 'En vivo';

  @override
  String get enVivoConexionesAbiertas => 'Conexiones abiertas';

  @override
  String get enVivoFiltrarPorCliente => 'Filtrar por cliente';

  @override
  String get enVivoSinCoincidencias => 'Ningún resultado con ese filtro.';

  @override
  String get enVivoVacio => 'No hay ninguna sesión abierta ahora mismo.';

  @override
  String get enVivoSinSede => 'Sin sede asignada';

  @override
  String enVivoUltimoAcceso(String fecha) {
    return 'último acceso $fecha';
  }

  @override
  String get enVivoCerrarSesionTitulo => 'Cerrar sesión';

  @override
  String enVivoCerrarSesionMensaje(String nombre) {
    return '¿Cerrar la sesión de \"$nombre\"?';
  }

  @override
  String get dashboardSinDatos => 'Todavía no hay datos suficientes.';

  @override
  String get dashboardClientesActivos => 'Clientes activos';

  @override
  String get dashboardClientesInactivos => 'Clientes inactivos';

  @override
  String get dashboardSedesTotal => 'Sedes/Tanatorios';

  @override
  String get dashboardPublicacionesTotal => 'Publicaciones';

  @override
  String get dashboardAvisosTotal => 'Avisos';

  @override
  String get dashboardCondolenciasTotal => 'Condolencias';

  @override
  String get dashboardClientesPorTipo => 'Clientes por tipo';

  @override
  String get dashboardPublicacionesPorMes => 'Publicaciones por mes';

  @override
  String get dashboardAvisosPorMes => 'Avisos por mes';

  @override
  String get dashboardAltasPorMes => 'Altas por mes';

  @override
  String get dashboardBajasPorMes => 'Bajas por mes';

  @override
  String get dashboardTopClientes => 'Clientes con más publicaciones';

  @override
  String get dashboardUsuariosActivos => 'Usuarios activos';

  @override
  String get dashboardUsuariosInactivos => 'Usuarios inactivos';

  @override
  String get dashboardUsuariosConPush => 'Con notificaciones activas';

  @override
  String get dashboardSeguimientosTotal => 'Seguimientos a clientes';

  @override
  String get dashboardZonasSeguidasTotal => 'Zonas seguidas';

  @override
  String get dashboardUsuariosPorIdioma => 'Usuarios por idioma';

  @override
  String get dashboardTopConcellos => 'Concellos con más usuarios';

  @override
  String get dashboardIaAviso =>
      'Datos aproximados del escaneo de esquelas con IA (no incluye la importación automática desde web). El coste es una estimación propia a partir de los tokens de cada petición, no el saldo real de la cuenta de Anthropic.';

  @override
  String get dashboardIaPeticionesHoy => 'Peticiones hoy';

  @override
  String get dashboardIaCostoHoy => 'Coste estimado hoy';

  @override
  String get dashboardIaPeticionesMes => 'Peticiones este mes';

  @override
  String get dashboardIaCostoMes => 'Coste estimado este mes';

  @override
  String get dashboardIaPeticionesTotal => 'Peticiones totales';

  @override
  String get dashboardIaCostoTotal => 'Coste estimado total';

  @override
  String get dashboardIaTasaExito => 'Tasa de éxito';

  @override
  String get dashboardIaPeticionesPorDia =>
      'Peticiones por día (últimos 30 días)';

  @override
  String get dashboardIaUsoPorUsuario => 'Uso por usuario este mes';

  @override
  String get dashboardIaColUsuario => 'Usuario';

  @override
  String get dashboardIaColPeticiones => 'Peticiones';

  @override
  String get dashboardIaColCosto => 'Coste estimado';
}
