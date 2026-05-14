import 'dart:convert';

/// Modelo de usuario para autenticación local.
/// Almacena los datos del usuario registrado en la aplicación.
class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String contrasenaHash; // Hash simple para simulación
  final DateTime creadoEn;

  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.contrasenaHash,
    required this.creadoEn,
  });

  /// Crea una instancia desde un mapa JSON (deserialización)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      contrasenaHash: json['contrasenaHash'] as String,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }

  /// Convierte la instancia a un mapa JSON (serialización)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'contrasenaHash': contrasenaHash,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  /// Serializa a String JSON para almacenamiento local
  String toJsonString() => jsonEncode(toJson());

  /// Deserializa desde String JSON del almacenamiento local
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Crea una copia con campos modificados
  UserModel copyWith({
    String? id,
    String? nombre,
    String? email,
    String? contrasenaHash,
    DateTime? creadoEn,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      contrasenaHash: contrasenaHash ?? this.contrasenaHash,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
