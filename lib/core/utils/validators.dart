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
    // Expresión regular más robusta para validación de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&' '*' r"'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Formato de correo electrónico no válido';
    }
    if (value.length > 50) {
      return 'El correo es demasiado largo';
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

  /// Lista de palabras ofensivas prohibidas
  static const List<String> _palabrasProhibidas = [
    'ofensiva1', 'ofensiva2', 'groseria', 'insulto', // Ejemplos
    'malpalabra', 'idiota', 'estupido'
  ];

  /// Valida nombre de usuario (mínimo 3 caracteres, alfanumérico y sin groserías)
  static String? nombreUsuario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre de usuario';
    }
    final cleanValue = value.trim().toLowerCase();
    
    if (cleanValue.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (cleanValue.length > 20) {
      return 'El nombre no puede exceder los 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9áéíóúñÁÉÍÓÚÑ_ ]+$').hasMatch(value.trim())) {
      return 'Solo se permiten letras, números, espacios y guión bajo';
    }
    
    // Filtro de groserías
    for (final palabra in _palabrasProhibidas) {
      if (cleanValue.contains(palabra)) {
        return 'El nombre contiene lenguaje no permitido';
      }
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
