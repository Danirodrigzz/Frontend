import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Repositorio de autenticación que simula un backend usando SharedPreferences.
/// Maneja registro, login, verificación de sesión y logout.
class AuthRepository {
  static const _registeredUsersKey = 'registered_users';

  // ── Registro de usuario ──────────────────────────────────────
  /// Registra un nuevo usuario validando que el email no exista.
  /// Retorna el usuario creado o lanza una excepción si ya existe.
  Future<UserModel> registrar({
    required String nombre,
    required String email,
    required String contrasena,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = _obtenerUsuariosRegistrados(prefs);

    // Verificar si el email ya está registrado
    final existeEmail = usuarios.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existeEmail) {
      throw Exception('Ya existe una cuenta con este correo electrónico');
    }

    // Crear nuevo usuario con ID único
    final nuevoUsuario = UserModel(
      id: const Uuid().v4(),
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      contrasenaHash: _hashContrasena(contrasena),
      creadoEn: DateTime.now(),
    );

    // Guardar en la lista de usuarios registrados
    usuarios.add(nuevoUsuario);
    await _guardarUsuariosRegistrados(prefs, usuarios);

    // Crear sesión activa (guardar token)
    await _crearSesion(prefs, nuevoUsuario);

    // Inicializar los saldos del usuario
    await _inicializarSaldos(prefs);

    return nuevoUsuario;
  }

  // ── Inicio de sesión ─────────────────────────────────────────
  /// Autentica al usuario verificando email y contraseña.
  /// Retorna el usuario si las credenciales son correctas.
  Future<UserModel> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = _obtenerUsuariosRegistrados(prefs);

    // Buscar usuario por email
    final usuario = usuarios.where(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );

    if (usuario.isEmpty) {
      throw Exception('No existe una cuenta con este correo electrónico');
    }

    // Verificar contraseña
    final hashIngresado = _hashContrasena(contrasena);
    if (usuario.first.contrasenaHash != hashIngresado) {
      throw Exception('La contraseña es incorrecta');
    }

    // Crear sesión activa
    await _crearSesion(prefs, usuario.first);

    return usuario.first;
  }

  // ── Verificación de sesión ───────────────────────────────────
  /// Verifica si hay una sesión activa (token almacenado).
  /// Retorna el usuario de la sesión o null si no hay sesión.
  Future<UserModel?> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenData = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.userKey);

    if (tokenData == null || userData == null) return null;

    try {
      // Verificar que el token no haya expirado (24 horas)
      final tokenInfo = jsonDecode(tokenData) as Map<String, dynamic>;
      final expiracion = DateTime.parse(tokenInfo['expiracion'] as String);

      if (DateTime.now().isAfter(expiracion)) {
        // Token expirado: limpiar sesión
        await cerrarSesion();
        return null;
      }

      return UserModel.fromJsonString(userData);
    } catch (_) {
      await cerrarSesion();
      return null;
    }
  }

  // ── Cierre de sesión ─────────────────────────────────────────
  /// Elimina el token y los datos de sesión del usuario.
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  // ── Métodos privados ─────────────────────────────────────────

  /// Genera un hash simple de la contraseña (simulación, no criptográfico real)
  String _hashContrasena(String contrasena) {
    // En producción usaríamos bcrypt o similar.
    // Para la prueba técnica, usamos base64 como simulación.
    return base64Encode(utf8.encode('chinchin_salt_$contrasena'));
  }

  /// Crea una sesión guardando token y datos del usuario
  Future<void> _crearSesion(SharedPreferences prefs, UserModel usuario) async {
    // Generar token simulado con expiración de 24 horas
    final tokenInfo = {
      'token': const Uuid().v4(),
      'userId': usuario.id,
      'creado': DateTime.now().toIso8601String(),
      'expiracion': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };

    await prefs.setString(AppConstants.tokenKey, jsonEncode(tokenInfo));
    await prefs.setString(AppConstants.userKey, usuario.toJsonString());
  }

  /// Inicializa los saldos del usuario con los valores por defecto
  Future<void> _inicializarSaldos(SharedPreferences prefs) async {
    // Solo inicializar si no existen saldos previos
    if (!prefs.containsKey(AppConstants.balancesKey)) {
      await prefs.setString(
        AppConstants.balancesKey,
        jsonEncode(AppConstants.initialBalances),
      );
    }
  }

  /// Obtiene la lista de usuarios registrados del almacenamiento local
  List<UserModel> _obtenerUsuariosRegistrados(SharedPreferences prefs) {
    final data = prefs.getString(_registeredUsersKey);
    if (data == null) return [];

    final lista = jsonDecode(data) as List<dynamic>;
    return lista
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Guarda la lista actualizada de usuarios registrados
  Future<void> _guardarUsuariosRegistrados(
    SharedPreferences prefs,
    List<UserModel> usuarios,
  ) async {
    final data = jsonEncode(usuarios.map((u) => u.toJson()).toList());
    await prefs.setString(_registeredUsersKey, data);
  }
}
