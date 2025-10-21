import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// VIEWMODEL - Capa de lógica de autenticación
/// Responsabilidad: Manejar estado de sesión, login/logout, verificación de token
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  // ==================== ESTADO ====================

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;
  String? _username;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;
  String? get username => _username;
  bool get hasError => _errorMessage != null;

  // ==================== INICIALIZACIÓN ====================

  /// Verificar si hay una sesión guardada al iniciar la app
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final token = await _repository.loadToken();
      
      if (token != null) {
        // Verificar si el token sigue siendo válido
        final isValid = await _repository.verifyToken(token);
        
        if (isValid) {
          _currentToken = token;
          _isAuthenticated = true;
        } else {
          // Token expirado, limpiar
          await _repository.clearToken();
        }
      }
    } catch (e) {
      _setError('Error al verificar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== AUTENTICACIÓN ====================

  /// Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Validaciones básicas
      if (username.isEmpty || password.isEmpty) {
        _setError('Usuario y contraseña son requeridos');
        return false;
      }

      // Realizar login
      final token = await _repository.login(username, password);
      
      // Actualizar estado
      _currentToken = token;
      _username = username;
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registro
  Future<bool> register(String username, String password, String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Validaciones básicas
      if (username.isEmpty || password.isEmpty || email.isEmpty) {
        _setError('Todos los campos son requeridos');
        return false;
      }

      if (password.length < 6) {
        _setError('La contraseña debe tener al menos 6 caracteres');
        return false;
      }

      // Validación básica de email
      if (!email.contains('@')) {
        _setError('Email inválido');
        return false;
      }

      // Realizar registro
      final token = await _repository.register(username, password, email);
      
      // Actualizar estado
      _currentToken = token;
      _username = username;
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _repository.logout();
      
      // Limpiar estado
      _currentToken = null;
      _username = null;
      _isAuthenticated = false;
      
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
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

  /// Obtener token actualizado (útil para los repositories)
  Future<String?> getToken() async {
    if (_currentToken != null) {
      return _currentToken;
    }
    return await _repository.loadToken();
  }
}
