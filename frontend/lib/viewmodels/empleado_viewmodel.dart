import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/empleado.dart';
import '../repositories/empleado_repository.dart';

/// VIEWMODEL - Capa de lógica de negocio
/// Responsabilidad: Manejar estado de la UI, coordinar operaciones, notificar cambios
/// Usa ChangeNotifier para el patrón Observer (notifica a la UI cuando cambia el estado)
class EmpleadoViewModel extends ChangeNotifier {
  final EmpleadoRepository _repository;

  EmpleadoViewModel(this._repository);

  // ==================== ESTADO ====================

  List<Empleado> _empleados = [];
  bool _isLoading = false;
  String? _errorMessage;
  Empleado? _selectedEmpleado;

  // Getters (exponen el estado de forma inmutable)
  List<Empleado> get empleados => List.unmodifiable(_empleados);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Empleado? get selectedEmpleado => _selectedEmpleado;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _empleados.isEmpty && !_isLoading;

  // ==================== OPERACIONES CRUD ====================

  /// Cargar todos los empleados
  Future<void> cargarEmpleados() async {
    _setLoading(true);
    _clearError();

    try {
      _empleados = await _repository.getEmpleados();
      notifyListeners(); // Notifica a la UI que hay cambios
    } catch (e) {
      _setError('Error al cargar empleados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar un empleado específico por ID
  Future<void> cargarEmpleadoById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedEmpleado = await _repository.getEmpleadoById(id);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar empleado: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear nuevo empleado
  Future<bool> crearEmpleado(Empleado empleado) async {
    _setLoading(true);
    _clearError();

    try {
      final nuevoEmpleado = await _repository.createEmpleado(empleado);
      _empleados.add(nuevoEmpleado);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al crear empleado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar empleado existente
  Future<bool> actualizarEmpleado(Empleado empleado) async {
    _setLoading(true);
    _clearError();

    try {
      final empleadoActualizado = await _repository.updateEmpleado(empleado);
      
      // Actualizar en la lista local
      final index = _empleados.indexWhere((e) => e.id == empleadoActualizado.id);
      if (index != -1) {
        _empleados[index] = empleadoActualizado;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar empleado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar empleado
  Future<bool> eliminarEmpleado(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteEmpleado(id);
      
      // Eliminar de la lista local
      _empleados.removeWhere((e) => e.id == id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar empleado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Subir imagen de empleado
  Future<String> uploadImage(File imageFile) async {
    _clearError();

    try {
      final imageUrl = await _repository.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      _setError('Error al subir imagen: $e');
      rethrow;
    }
  }

  // ==================== GESTIÓN DE ESTADO ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void selectEmpleado(Empleado? empleado) {
    _selectedEmpleado = empleado;
    notifyListeners();
  }

  // ==================== UTILIDADES ====================

  /// Buscar empleados por nombre
  List<Empleado> buscarEmpleados(String query) {
    if (query.isEmpty) return empleados;
    
    final queryLower = query.toLowerCase();
    return _empleados.where((e) {
      return e.nombre.toLowerCase().contains(queryLower) ||
          e.apellido.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Obtener estadísticas
  Map<String, dynamic> obtenerEstadisticas() {
    if (_empleados.isEmpty) {
      return {
        'total': 0,
        'promedioSalario': 0.0,
      };
    }

    final totalSalarios = _empleados.fold<double>(
      0,
      (sum, empleado) => sum + empleado.salario,
    );

    return {
      'total': _empleados.length,
      'promedioSalario': totalSalarios / _empleados.length,
      'salarioMasAlto': _empleados
          .map((e) => e.salario)
          .reduce((a, b) => a > b ? a : b),
      'salarioMasBajo': _empleados
          .map((e) => e.salario)
          .reduce((a, b) => a < b ? a : b),
    };
  }

  // ==================== DEMOSTRACIÓN DE CONCURRENCIA ====================

  /// Ejecutar demo de concurrencia comparando carga secuencial vs paralela
  /// Funciona con mínimo 2 empleados (recomendado 3-5 para mejores resultados)
  Future<ComparisonResult> ejecutarDemoConcurrencia() async {
    if (_empleados.length < 2) {
      throw Exception('Se necesitan al menos 2 empleados para la demo');
    }

    // Obtener IDs de los empleados actuales (filtrar nulls)
    final ids = _empleados.map((e) => e.id).whereType<int>().toList();
    
    // Tomar máximo 10 empleados para no hacer la demo muy larga
    final idsDemo = ids.take(10).toList();

    print('⚡ Ejecutando demo de concurrencia con ${idsDemo.length} empleados...');
    
    // Ejecutar comparación
    final resultado = await _repository.compararMetodos(idsDemo);
    
    print('✅ Demo completada: ${resultado.mejoraPorcentaje}% de mejora');
    
    return resultado;
  }
}
