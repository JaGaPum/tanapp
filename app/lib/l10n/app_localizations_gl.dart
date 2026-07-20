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
  String get fieldDireccion => 'Enderezo completo';

  @override
  String get fieldNombreEmpresa => 'Nome da empresa';

  @override
  String get comoLlegar => 'Como chegar';

  @override
  String get mapa => 'Mapa';

  @override
  String get filtroTodasProvincias => 'Todas';

  @override
  String get filtroTodosConcellos => 'Todos';

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
  String get accountNotificacionesPush =>
      'Desexo recibir notificacións das publicacións no meu móbil.';

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
  String get usuarioTipoCliente => 'Tipo de cliente';

  @override
  String errorCargarTiposCliente(String error) {
    return 'Non se puideron cargar os tipos de cliente: $error';
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
  String get tiposCliente => 'Tipos de Clientes';

  @override
  String get configuracionTiposClienteTitulo =>
      'Configuración > Tipos de Clientes';

  @override
  String get noHayTiposClienteDadosDeAlta =>
      'Non hai tipos de cliente dados de alta';

  @override
  String get clienteTipoNuevo => 'Novo tipo de cliente';

  @override
  String get clienteTipoEditar => 'Editar tipo de cliente';

  @override
  String get clienteTipoActivo => 'Activo';

  @override
  String get clienteTipoEliminarTitulo => 'Eliminar tipo de cliente';

  @override
  String clienteTipoEliminarMensaje(String nombre) {
    return 'Eliminar \"$nombre\"?';
  }

  @override
  String get clienteTipoTraduccionesPorIdioma => 'Traducións por idioma';

  @override
  String get clienteTipoGuardarTraduccion => 'Gardar tradución';

  @override
  String clienteTipoTraduccionGuardadaEnIdioma(String idioma) {
    return 'Tradución en $idioma gardada';
  }

  @override
  String get clienteTipoNoSePudoGuardar => 'Non se puido gardar';

  @override
  String get solicitudSeleccionarTipoCliente => 'Selecciona o tipo de cliente';

  @override
  String get solicitudTipoClienteObligatorio =>
      'O tipo de cliente é obrigatorio para aprobar a solicitude';

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
  String get seguidos => 'Buscar';

  @override
  String get avisos => 'Avisos';

  @override
  String get seguidosSeleccionaTipo => '¿A quen quero seguir?';

  @override
  String get seguidosSeleccionaProvincia => 'Escolle a provincia';

  @override
  String get seguidosSeleccionaConcello => 'Escolle o concello';

  @override
  String get seguidosBuscarConcello => 'Buscar concello';

  @override
  String seguidosNoHayActivosNesteConcello(String tipoNombre) {
    String _temp0 = intl.Intl.selectLogic(tipoNombre, {
      'Tanatorio': 'Aínda non hai ningún tanatorio activo neste concello',
      'Funeraria': 'Aínda non hai ningunha funeraria activa neste concello',
      'Parroquia': 'Aínda non hai ningunha parroquia activa neste concello',
      'other': 'Aínda non hai ningún cliente activo neste concello',
    });
    return '$_temp0';
  }

  @override
  String get seguidosSeguir => 'Seguir';

  @override
  String get seguidosDejarDeSeguir => 'Deixar de seguir';

  @override
  String get siguiendoTab => 'Seguindo';

  @override
  String get misSeguidosBuscarNombre => 'Buscar por nome';

  @override
  String get misSeguidosVacio => 'Aínda non segues a ningún cliente';

  @override
  String get drawerMisSedes => 'As miñas sedes';

  @override
  String get misSedesTitulo => 'As miñas sedes';

  @override
  String get misSedesVacio => 'Aínda non deches de alta ningunha sede';

  @override
  String get misSedesNueva => 'Nova sede';

  @override
  String get misSedesEditar => 'Editar sede';

  @override
  String get misSedesNombreSede => 'Nome da sede';

  @override
  String get misSedesEliminarTitulo => 'Eliminar sede';

  @override
  String misSedesEliminarMensaje(String nombre) {
    return 'Eliminar \"$nombre\"?';
  }

  @override
  String get misSedesUltimaSedeAviso =>
      'Debe quedar polo menos unha sede. Para eliminar esta, primeiro dá de alta outra.';

  @override
  String get misSedesCodigo => 'Código';

  @override
  String get tabPublicar => 'Publicar';

  @override
  String get tabPanelDatos => 'Panel de Datos';

  @override
  String get publicarEscanear => 'Escanear';

  @override
  String get publicarManual => 'Manual';

  @override
  String get publicarNuevaPublicacion => 'Nova publicación';

  @override
  String get publicarSeleccionaSede => 'Escolle a sede';

  @override
  String get publicarSinSedes =>
      'Aínda non tes ningunha sede. Dá de alta unha sede en \"Miñas sedes\" antes de publicar.';

  @override
  String get publicarAvisoDatosPersonales =>
      'Por protección de datos, non inclúas datos persoais de familiares (nomes, teléfonos, enderezos). Só o nome do falecido e a información relevante para o público.';

  @override
  String get publicarNombreFallecido => 'Nome do falecido';

  @override
  String get publicarAvisoRevisar =>
      'Revisa ben todos os campos antes de publicar: se veñen dun escaneo, corrixe ou completa o que faga falta.';

  @override
  String get publicarFechaFallecimiento => 'Data de falecemento';

  @override
  String get publicarEdad => 'Idade';

  @override
  String get publicarFechaFuneral => 'Data do funeral';

  @override
  String get publicarHoraFuneral => 'Hora do funeral';

  @override
  String get publicarIglesia => 'Igrexa';

  @override
  String get publicarLugar => 'Lugar';

  @override
  String get publicarCapillaArdiente => 'Capela ardente / velorio';

  @override
  String get publicarSala => 'Sala';

  @override
  String get publicarObservaciones => 'Observacións';

  @override
  String get publicarEscoitarEsquela => 'Escoitar esquela';

  @override
  String get publicarPararEscoita => 'Deter a lectura';

  @override
  String publicarFuneralVoz(String fecha, String hora) {
    return 'O funeral será o $fecha ás $hora';
  }

  @override
  String get tablonAumentarLetra => 'Aumentar tamaño de letra';

  @override
  String get tablonDisminuirLetra => 'Diminuír tamaño de letra';

  @override
  String get publicarEdadInvalida => 'Introduce un número enteiro válido';

  @override
  String get publicarVistaPreviaTitulo => 'É correcto?';

  @override
  String publicarFallecioEl(String fecha) {
    return 'Faleceu o $fecha';
  }

  @override
  String publicarAnosDeEdad(int edad) {
    String _temp0 = intl.Intl.pluralLogic(
      edad,
      locale: localeName,
      other: '$edad anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String get publicarPublicar => 'Publicar';

  @override
  String get publicarPublicadoOk => 'Publicación creada';

  @override
  String get publicarLeyendoEsquela => 'Lendo esquela…';

  @override
  String get publicarOcrSinTexto =>
      'Non se puido ler texto na foto. Cobre o formulario a man.';

  @override
  String publicarOcrError(String detalle) {
    return 'Non se puido ler a foto (detalle técnico: $detalle). Cobre o formulario a man; se podes, fai unha captura desta mensaxe para reportalo.';
  }

  @override
  String get publicarSinPublicaciones => 'Aínda non hai ningunha publicación';

  @override
  String get publicarCambiosGuardados => 'Cambios gardados';

  @override
  String get publicarEditarPublicacion => 'Editar publicación';

  @override
  String get publicarEliminarTitulo => 'Eliminar publicación';

  @override
  String publicarEliminarMensaje(String nombre) {
    return 'Seguro que queres eliminar a publicación de $nombre?';
  }

  @override
  String get tabPublicaciones => 'Publicacións';

  @override
  String get arquivo => 'Arquivo';

  @override
  String get arquivoVacio => 'Aínda non gardaches ningunha publicación';

  @override
  String get arquivoGardado => 'Gardado no meu arquivo';

  @override
  String get arquivoEliminado => 'Eliminado do meu arquivo';

  @override
  String get arquivoTooltipGardar => 'Gardar no meu arquivo';

  @override
  String get arquivoTooltipQuitar => 'Quitar do meu arquivo';

  @override
  String get panelDatosPublicaciones => 'Publicacións';

  @override
  String get panelDatosSeguidores => 'Seguidores';

  @override
  String get panelDatosSinSeguidores => 'Aínda non ten seguidores';

  @override
  String get panelDatosConcelloDesconocido => 'Sen concello indicado';

  @override
  String get tablonBuscar => 'Buscar por texto, cliente ou concello';

  @override
  String get misSeguidosBuscarYFiltrar => 'Buscar e filtrar';

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
