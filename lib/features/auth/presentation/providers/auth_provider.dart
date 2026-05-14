import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Estado de la autenticación en la aplicación.
/// Maneja los distintos estados posibles: cargando, autenticado, no autenticado, error.
class AuthState {
  final bool estaCargando;
  final UserModel? usuario;
  final String? error;
  final bool estaAutenticado;

  const AuthState({
    this.estaCargando = false,
    this.usuario,
    this.error,
    this.estaAutenticado = false,
  });

  /// Estado inicial: verificando sesión
  factory AuthState.inicial() => const AuthState(estaCargando: true);

  /// Estado cuando se está procesando una acción
  factory AuthState.cargando() => const AuthState(estaCargando: true);

  /// Estado autenticado con datos del usuario
  factory AuthState.autenticado(UserModel usuario) => AuthState(
    usuario: usuario,
    estaAutenticado: true,
  );

  /// Estado no autenticado (sin sesión activa)
  factory AuthState.noAutenticado() => const AuthState();

  /// Estado de error con mensaje descriptivo
  factory AuthState.error(String mensaje) => AuthState(error: mensaje);

  /// Crea una copia limpiando el error (útil para reintentos)
  AuthState limpiarError() => AuthState(
    estaCargando: estaCargando,
    usuario: usuario,
    estaAutenticado: estaAutenticado,
  );
}

/// Provider del repositorio de autenticación (singleton)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider del estado de autenticación.
/// Controla el flujo completo: verificar sesión, login, registro, logout.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

/// Notifier que gestiona las acciones de autenticación.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.inicial()) {
    // Al crear el notifier, verificamos si hay una sesión activa
    verificarSesion();
  }

  /// Verifica si existe una sesión válida al iniciar la app
  Future<void> verificarSesion() async {
    try {
      state = AuthState.cargando();
      final usuario = await _repository.verificarSesion();

      if (usuario != null) {
        state = AuthState.autenticado(usuario);
      } else {
        state = AuthState.noAutenticado();
      }
    } catch (e) {
      state = AuthState.noAutenticado();
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    try {
      state = AuthState.cargando();

      final usuario = await _repository.iniciarSesion(
        email: email,
        contrasena: contrasena,
      );

      state = AuthState.autenticado(usuario);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> registrar({
    required String nombre,
    required String email,
    required String contrasena,
  }) async {
    try {
      state = AuthState.cargando();

      final usuario = await _repository.registrar(
        nombre: nombre,
        email: email,
        contrasena: contrasena,
      );

      state = AuthState.autenticado(usuario);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Cierra la sesión actual
  Future<void> cerrarSesion() async {
    await _repository.cerrarSesion();
    state = AuthState.noAutenticado();
  }

  /// Limpia el mensaje de error actual
  void limpiarError() {
    state = state.limpiarError();
  }
}
