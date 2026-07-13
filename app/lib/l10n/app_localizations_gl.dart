// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appTitle => 'TanApp';

  @override
  String get errorInesperado => 'Ocorreu un erro inesperado';

  @override
  String get cuentaDesactivada =>
      'A túa conta está desactivada. Contacta co administrador.';

  @override
  String validatorRequiredField(String field) {
    return '$field é obrigatorio';
  }

  @override
  String get validatorEmailRequired => 'O email é obrigatorio';

  @override
  String get validatorEmailInvalid => 'Introduce un email válido';

  @override
  String get validatorPasswordRequired => 'O contrasinal é obrigatorio';

  @override
  String get validatorPasswordTooShort => 'Debe ter polo menos 8 caracteres';

  @override
  String get validatorPasswordMismatch => 'Os contrasinais non coinciden';

  @override
  String get validatorOtpLength => 'Introduce o código de 6 díxitos';

  @override
  String get validatorOtpDigitsOnly => 'O código só contén números';

  @override
  String get validatorProvinciaRequired => 'A provincia é obrigatoria';

  @override
  String get validatorConcelloRequired => 'O concello é obrigatorio';

  @override
  String get confirmDialogConfirm => 'Confirmar';

  @override
  String get confirmDialogCancel => 'Cancelar';

  @override
  String get passwordFieldLabel => 'Contrasinal';

  @override
  String get fieldNombre => 'Nome';

  @override
  String get fieldPrimerApellido => 'Primeiro apelido';

  @override
  String get fieldSegundoApellidoOpcional => 'Segundo apelido (opcional)';

  @override
  String get fieldSegundoApellido => 'Segundo apelido';

  @override
  String get fieldTelefonoOpcional => 'Teléfono (opcional)';

  @override
  String get fieldTelefono => 'Teléfono';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldContrasena => 'O contrasinal';

  @override
  String get fieldProvincia => 'Provincia';

  @override
  String get fieldConcello => 'Concello';

  @override
  String get fieldConfirmarContrasena => 'Confirmar contrasinal';

  @override
  String errorCargarProvincias(String error) {
    return 'Non se puideron cargar as provincias: $error';
  }

  @override
  String errorCargarConcellos(String error) {
    return 'Non se puideron cargar os concellos: $error';
  }

  @override
  String get googleContinuar => 'Continuar con Google';

  @override
  String get googleConectando => 'Conectando…';

  @override
  String get googleRegistrarse => 'Rexístrate con Google';

  @override
  String get o => 'ou';

  @override
  String get drawerMiCuenta => 'A miña conta';

  @override
  String get drawerSistema => 'Sistema';

  @override
  String get drawerConfiguracion => 'Configuración';

  @override
  String get drawerCerrarSesion => 'Pechar sesión';

  @override
  String get drawerCerrarSesionMensaje => 'Seguro que queres pechar a sesión?';

  @override
  String get loginTagline => 'Información funeraria';

  @override
  String get loginRecordarme => 'Lembrarme';

  @override
  String get loginOlvidasteContrasena => 'Esqueciches o contrasinal?';

  @override
  String get loginIniciarSesion => 'Iniciar sesión';

  @override
  String get loginNoTienesCuenta => 'Non tes conta?';

  @override
  String get loginRegistrate => 'Rexístrate';

  @override
  String get loginEresFuneraria =>
      'És unha funeraria ou tanatorio? Solicita a alta';

  @override
  String get registerTitle => 'Crear conta';

  @override
  String get registerYaTengoCuenta => 'Xa teño conta, iniciar sesión';

  @override
  String get forgotPasswordTitle => 'Recuperar contrasinal';

  @override
  String get forgotPasswordIntro =>
      'Introduce o teu email e enviarémosche un código para restablecer o contrasinal.';

  @override
  String get forgotPasswordEnviarCodigo => 'Enviar código';

  @override
  String get resetPasswordTitle => 'Novo contrasinal';

  @override
  String get resetPasswordNuevaContrasena => 'Novo contrasinal';

  @override
  String get resetPasswordGuardar => 'Gardar contrasinal';

  @override
  String get resetPasswordActualizada =>
      'Contrasinal actualizado, inicia sesión de novo';

  @override
  String get verifyOtpTitle => 'Verificar código';

  @override
  String verifyOtpSentTo(String email) {
    return 'Enviámosche un código de 6 díxitos a $email';
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
  String get verifyOtpNoSePudoReenviar => 'Non se puido reenviar o código';

  @override
  String get verifyOtpCodigoIncorrecto => 'Código incorrecto';

  @override
  String errorGenerico(String error) {
    return 'Erro: $error';
  }

  @override
  String get accountTitle => 'A miña conta';

  @override
  String get accountNoSePudoCargarPerfil => 'Non se puido cargar o teu perfil';

  @override
  String get accountFotoPerfil => 'Foto de perfil';

  @override
  String get accountDatosPersonales => 'Datos persoais';

  @override
  String get accountFotoActualizada => 'Foto actualizada';

  @override
  String get accountNoSePudoSubirFoto => 'Non se puido subir a foto';

  @override
  String get accountDatosActualizados => 'Datos actualizados';

  @override
  String get accountCambiarContrasena => 'Cambiar contrasinal';

  @override
  String get accountContrasenaActual => 'Contrasinal actual';

  @override
  String get accountContrasenaActualIncorrecta =>
      'O contrasinal actual non é correcto';

  @override
  String get accountNoSePudoVerificarIdentidad =>
      'Non se puido verificar a túa identidade';

  @override
  String get accountContrasenaActualizada => 'Contrasinal actualizado';

  @override
  String get accountActualizarContrasena => 'Actualizar contrasinal';

  @override
  String get accountGuardarCambios => 'Gardar cambios';

  @override
  String get usuarioFichaTitulo => 'Ficha de usuario';

  @override
  String get usuarioCambiosGuardados => 'Cambios gardados';

  @override
  String get usuarioNoSePudoAsignarRol => 'Non se puido asignar o rol';

  @override
  String get usuarioQuitarRolTitulo => 'Quitar rol';

  @override
  String usuarioQuitarRolMensaje(String rol) {
    return 'Quitar o rol \"$rol\" a este usuario?';
  }

  @override
  String get usuarioQuitar => 'Quitar';

  @override
  String get usuarioNoSePudoQuitarRol => 'Non se puido quitar o rol';

  @override
  String get usuarioYaTieneTodosLosRoles => 'Xa ten todos os roles asignados';

  @override
  String get usuarioEmailValidado => 'Email validado';

  @override
  String get usuarioNoSePudoValidarEmail => 'Non se puido validar o email';

  @override
  String get usuarioEliminarTitulo => 'Eliminar usuario';

  @override
  String usuarioEliminarMensaje(String nombre) {
    return 'Seguro que queres eliminar a \"$nombre\"? Esta acción non se pode desfacer.';
  }

  @override
  String get usuarioEliminar => 'Eliminar';

  @override
  String get usuarioNoSePudoEliminar => 'Non se puido eliminar o usuario';

  @override
  String get usuarioIdiomaPreferido => 'Idioma preferido';

  @override
  String errorCargarIdiomas(String error) {
    return 'Non se puideron cargar os idiomas: $error';
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
  String get anadirRol => 'Engadir rol';

  @override
  String get sesiones => 'Sesións';

  @override
  String get ocultarSesiones => 'Ocultar sesións';

  @override
  String get verSesiones => 'Ver sesións';

  @override
  String get sinSesionesRegistradas => 'Sen sesións rexistradas';

  @override
  String get sesionColInicio => 'Inicio';

  @override
  String get sesionColFin => 'Fin';

  @override
  String get sesionColEstado => 'Estado';

  @override
  String get sesionColRecordar => 'Lembrar';

  @override
  String get sesionEnCurso => 'En curso';

  @override
  String get sesionAbierta => 'Aberta';

  @override
  String get sesionCerrada => 'Pechada';

  @override
  String get si => 'Si';

  @override
  String get no => 'Non';

  @override
  String errorCargarSesiones(String error) {
    return 'Non se puideron cargar as sesións: $error';
  }

  @override
  String get solicitudTitulo => 'Solicitude de alta de cliente';

  @override
  String get solicitudEnviadaTitulo => 'Solicitude enviada';

  @override
  String get solicitudEnviadaMensaje =>
      'Recibimos a túa solicitude. Un administrador revisaraa e contactaremos contigo en breve.';

  @override
  String get volverAlInicio => 'Volver ao inicio';

  @override
  String get solicitudIntro =>
      'Solicita a alta da túa funeraria, tanatorio ou parroquia en TanApp. Un administrador revisará a túa solicitude antes de darche acceso.';

  @override
  String get fieldRazonSocial => 'Razón social';

  @override
  String get fieldNifCif => 'NIF / CIF';

  @override
  String get fieldNombreContacto => 'Nome da persoa de contacto';

  @override
  String get fieldEmailContacto => 'Email de contacto';

  @override
  String get fieldTelefonoContacto => 'Teléfono de contacto';

  @override
  String get fieldObservacionesOpcional => 'Observacións (opcional)';

  @override
  String get enviarSolicitud => 'Enviar solicitude';

  @override
  String get volver => 'Volver';

  @override
  String get guardar => 'Gardar';

  @override
  String get editar => 'Editar';

  @override
  String get eliminar => 'Eliminar';

  @override
  String get cambiosGuardados => 'Cambios gardados';

  @override
  String get comunicacionNueva => 'Nova comunicación';

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
    return 'Texto en $idioma gardado';
  }

  @override
  String get comunicacionNoSePudoGuardar => 'Non se puido gardar';

  @override
  String get comunicacionAsunto => 'Asunto';

  @override
  String get comunicacionCuerpo => 'Corpo';

  @override
  String get comunicacionGuardarTexto => 'Gardar texto';

  @override
  String get comunicacionEliminarTitulo => 'Eliminar comunicación';

  @override
  String comunicacionEliminarMensaje(String nombre) {
    return 'Eliminar \"$nombre\"?';
  }

  @override
  String get configuracionComunicacionesTitulo =>
      'Configuración > Comunicacións';

  @override
  String get noHayComunicacionesDadasDeAlta =>
      'Non hai comunicacións dadas de alta';

  @override
  String get inactiva => 'Inactiva';

  @override
  String get gestionUsuariosTitulo => 'Xestión de usuarios';

  @override
  String get buscarPorNombreEmail => 'Buscar por nome ou email';

  @override
  String get soloActivos => 'Só activos';

  @override
  String get todosLosRoles => 'Todos os roles';

  @override
  String get noSeHanEncontradoUsuarios => 'Non se atoparon usuarios';

  @override
  String get pendiente => 'Pendente';

  @override
  String get solicitudesClientesTitulo => 'Solicitudes de clientes';

  @override
  String get estadoTodas => 'Todas';

  @override
  String get estadoPendientes => 'Pendentes';

  @override
  String get estadoAprobadas => 'Aprobadas';

  @override
  String get estadoRechazadas => 'Rexeitadas';

  @override
  String get noHaySolicitudesEnEsteEstado => 'Non hai solicitudes neste estado';

  @override
  String get solicitudEliminarTitulo => 'Eliminar solicitude';

  @override
  String get solicitudEliminarMensaje =>
      'Seguro que queres eliminar esta solicitude? Esta acción non se pode desfacer.';

  @override
  String get solicitudNoSePudoEliminar => 'Non se puido eliminar a solicitude';

  @override
  String get solicitudAprobarTitulo => 'Aprobar solicitude';

  @override
  String get solicitudRechazarTitulo => 'Rexeitar solicitude';

  @override
  String get solicitudConfirmarAprobar =>
      'Confirmas que queres aprobar esta solicitude de alta?';

  @override
  String get solicitudConfirmarRechazar =>
      'Confirmas que queres rexeitar esta solicitude de alta?';

  @override
  String get aprobar => 'Aprobar';

  @override
  String get rechazar => 'Rexeitar';

  @override
  String get solicitudNoIdentificado =>
      'Non se puido identificar o usuario actual';

  @override
  String solicitudAprobadaSinCuenta(String error) {
    return 'Solicitude aprobada, pero non se puido crear a conta do cliente: $error';
  }

  @override
  String get solicitudCuentaCreada => 'Conta de cliente creada';

  @override
  String solicitudNoSePudoCrearCuenta(String error) {
    return 'Non se puido crear a conta do cliente: $error';
  }

  @override
  String get solicitudDetalleTitulo => 'Solicitude de cliente';

  @override
  String get solicitudAprobarBoton => 'Aprobar solicitude';

  @override
  String get campoPersonaContacto => 'Persoa de contacto';

  @override
  String get campoLocalidad => 'Localidade';

  @override
  String get campoObservaciones => 'Observacións';

  @override
  String get campoObservacionesResolucion => 'Observacións de resolución';

  @override
  String get fieldObservacionesResolucionOpcional =>
      'Observacións de resolución (opcional)';

  @override
  String get provincias => 'Provincias';

  @override
  String get comunicaciones => 'Comunicacións';

  @override
  String get configuracionProvinciasTitulo => 'Configuración > Provincias';

  @override
  String get noHayProvinciasDadasDeAlta => 'Non hai provincias dadas de alta';

  @override
  String prefijoPostalLabel(String prefijo) {
    return 'Prefixo postal: $prefijo';
  }

  @override
  String get provinciaEliminarTitulo => 'Eliminar provincia';

  @override
  String provinciaEliminarMensaje(String nombre) {
    return 'Eliminar \"$nombre\"? Tamén se eliminarán os seus concellos.';
  }

  @override
  String get provinciaNueva => 'Nova provincia';

  @override
  String get provinciaEditar => 'Editar provincia';

  @override
  String get fieldPrefijoPostal => 'Prefixo postal';

  @override
  String get errorPrefijoRequerido => 'O prefixo é obrigatorio';

  @override
  String get errorNombreRequerido => 'O nome é obrigatorio';

  @override
  String concellosDeProvincia(String provincia) {
    return 'Concellos de $provincia';
  }

  @override
  String get concellosTitulo => 'Concellos';

  @override
  String get noHayConcellosDadosDeAlta => 'Non hai concellos dados de alta';

  @override
  String get concelloEliminarTitulo => 'Eliminar concello';

  @override
  String concelloEliminarMensaje(String nombre) {
    return 'Eliminar \"$nombre\"?';
  }

  @override
  String get concelloNuevo => 'Novo concello';

  @override
  String get concelloEditar => 'Editar concello';

  @override
  String get gestionDeUsuarios => 'Xestión de Usuarios';

  @override
  String get solicitudesDeClientes => 'Solicitudes de Clientes';

  @override
  String holaNombre(String nombre) {
    return 'Ola, $nombre';
  }

  @override
  String get tablon => 'Taboleiro';

  @override
  String get seguidos => 'Seguidos';

  @override
  String get avisos => 'Avisos';

  @override
  String get proximamente => 'Proximamente';

  @override
  String avisoSolicitudesPendientes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tes $count solicitudes de clientes pendentes de aprobar',
      one: 'Tes 1 solicitude de cliente pendente de aprobar',
    );
    return '$_temp0';
  }

  @override
  String get estadoAprobadaSingular => 'Aprobada';

  @override
  String get estadoRechazadaSingular => 'Rexeitada';

  @override
  String get solicitudCrearCuentaBoton => 'Crear conta de cliente';
}
