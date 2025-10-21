class Empleado {
  final int? id;
  final String nombre;
  final String apellido;
  final String puesto;
  final double salario;
  final String email;
  final String telefono;
  final String? fotoUrl;
  final DateTime? fechaIngreso;

  Empleado({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.puesto,
    required this.salario,
    required this.email,
    required this.telefono,
    this.fotoUrl,
    this.fechaIngreso,
  });

  // Convertir JSON a objeto Empleado
  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      puesto: json['puesto'],
      salario: (json['salario'] as num).toDouble(),
      email: json['email'],
      telefono: json['telefono'],
      fotoUrl: json['foto_url'],
      fechaIngreso: json['fecha_ingreso'] != null 
          ? DateTime.parse(json['fecha_ingreso'])
          : null,
    );
  }

  // Convertir objeto Empleado a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'puesto': puesto,
      'salario': salario,
      'email': email,
      'telefono': telefono,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }

  // Método auxiliar para obtener el nombre completo
  String get nombreCompleto => '$nombre $apellido';
}
