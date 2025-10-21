import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/empleado.dart';


class EmpleadoRepository {
  final String baseUrl;
  final String? token;

  EmpleadoRepository({
    required this.baseUrl,
    this.token,
  });

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==================== CRUD OPERATIONS ====================

  /// Obtener todos los empleados
  Future<List<Empleado>> getEmpleados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/empleados'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Empleado.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        throw Exception('Error al obtener empleados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener un empleado por ID
  Future<Empleado> getEmpleadoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/empleados/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else {
        throw Exception('Error al obtener empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crear empleado
  Future<Empleado> createEmpleado(Empleado empleado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empleados'),
        headers: _getHeaders(),
        body: jsonEncode(empleado.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualizar empleado
  Future<Empleado> updateEmpleado(Empleado empleado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/empleados/${empleado.id}'),
        headers: _getHeaders(),
        body: jsonEncode(empleado.toJson()),
      );

      if (response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Eliminar empleado
  Future<void> deleteEmpleado(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/empleados/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Subir imagen de empleado
  Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );
      
      // Agregar headers de autenticación
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Agregar el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error al subir imagen');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // ==================== CONCURRENCIA (EVALUACIÓN) ====================

  Future<ConcurrencyResult> cargarEmpleadosSecuencial(List<int> ids) async {
    final stopwatch = Stopwatch()..start();
    final empleados = <Empleado>[];

    for (final id in ids) {
      try {
        final empleado = await getEmpleadoById(id);
        empleados.add(empleado);
      } catch (e) {
        print('Error cargando empleado $id: $e');
      }
    }

    stopwatch.stop();
    return ConcurrencyResult(
      empleados: empleados,
      tiempoMs: stopwatch.elapsedMilliseconds,
      metodo: 'Secuencial',
    );
  }

  /// Cargar múltiples empleados de forma PARALELA con Future.wait
  Future<ConcurrencyResult> cargarEmpleadosParalelo(List<int> ids) async {
    final stopwatch = Stopwatch()..start();

    final futures = ids.map((id) async {
      try {
        return await getEmpleadoById(id);
      } catch (e) {
        print('Error cargando empleado $id en paralelo: $e');
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);

    final empleados = results.whereType<Empleado>().toList();

    stopwatch.stop();
    return ConcurrencyResult(
      empleados: empleados,
      tiempoMs: stopwatch.elapsedMilliseconds,
      metodo: 'Paralelo (Future.wait)',
    );
  }

  /// Comparar ambos métodos y retornar estadísticas
  Future<ComparisonResult> compararMetodos(List<int> ids) async {
    print('🔄 Iniciando comparación de concurrencia...');
    print('   IDs a cargar: $ids');

    if (ids.isEmpty) {
      throw Exception('Se necesita al menos un ID para la comparación');
    }

    // Método 1: Secuencial
    final resultadoSecuencial = await cargarEmpleadosSecuencial(ids);
    print('✅ Secuencial completado: ${resultadoSecuencial.tiempoMs} ms (${resultadoSecuencial.empleados.length} empleados)');

    if (resultadoSecuencial.empleados.isEmpty) {
      throw Exception('No se pudieron cargar empleados. Verifica que existan en la base de datos.');
    }

    // Pequeña pausa para no saturar el servidor
    await Future.delayed(Duration(milliseconds: 500));

    // Método 2: Paralelo
    final resultadoParalelo = await cargarEmpleadosParalelo(ids);
    print('✅ Paralelo completado: ${resultadoParalelo.tiempoMs} ms (${resultadoParalelo.empleados.length} empleados)');

    // Calcular mejora (evitar división por cero)
    final mejora = resultadoSecuencial.tiempoMs > 0
        ? ((resultadoSecuencial.tiempoMs - resultadoParalelo.tiempoMs) /
                resultadoSecuencial.tiempoMs *
                100)
            .toStringAsFixed(1)
        : '0.0';

    print('📊 Mejora: $mejora%');

    return ComparisonResult(
      secuencial: resultadoSecuencial,
      paralelo: resultadoParalelo,
      mejoraPorcentaje: double.parse(mejora),
    );
  }
}

// ==================== CLASES DE RESULTADOS ====================

/// Resultado de una operación de carga con medición de tiempo
class ConcurrencyResult {
  final List<Empleado> empleados;
  final int tiempoMs;
  final String metodo;

  ConcurrencyResult({
    required this.empleados,
    required this.tiempoMs,
    required this.metodo,
  });

  double get tiempoSegundos => tiempoMs / 1000;
}

/// Resultado de comparación entre métodos secuencial y paralelo
class ComparisonResult {
  final ConcurrencyResult secuencial;
  final ConcurrencyResult paralelo;
  final double mejoraPorcentaje;

  ComparisonResult({
    required this.secuencial,
    required this.paralelo,
    required this.mejoraPorcentaje,
  });

  @override
  String toString() {
    return '''
📊 Comparación de Concurrencia:
   Secuencial: ${secuencial.tiempoMs} ms (${secuencial.empleados.length} empleados)
   Paralelo:   ${paralelo.tiempoMs} ms (${paralelo.empleados.length} empleados)
   Mejora:     $mejoraPorcentaje%
''';
  }
}
