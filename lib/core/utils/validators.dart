/// Validadores de formularios para la autenticación y entradas numéricas.
/// Cada método retorna null si es válido, o un mensaje de error en español.
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío
  static String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  /// Valida formato de correo electrónico
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    // Expresión regular estándar para validación de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Valida contraseña con requisitos de seguridad
  static String? contrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra mayúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  /// Valida que la confirmación de contraseña coincida
  static String? confirmarContrasena(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida nombre de usuario (mínimo 3 caracteres, alfanumérico)
  static String? nombreUsuario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre de usuario';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Solo se permiten letras, números y guión bajo';
    }
    return null;
  }

  /// Valida una cantidad numérica positiva para intercambio
  static String? cantidad(String? value, {double? maximo}) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa una cantidad';
    }
    final numero = double.tryParse(value.replaceAll(',', '.'));
    if (numero == null) {
      return 'Ingresa un número válido';
    }
    if (numero <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    if (maximo != null && numero > maximo) {
      return 'Saldo insuficiente (máx: ${maximo.toStringAsFixed(4)})';
    }
    return null;
  }
}
