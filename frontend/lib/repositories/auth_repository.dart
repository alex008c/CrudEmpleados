import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// REPOSITORY - Capa de acceso a datos de autenticación
/// Responsabilidad: Manejar login, registro, tokens, persistencia de sesión
class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  // ==================== GESTIÓN DE TOKENS ====================

  /// Guardar token en almacenamiento local
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Cargar token desde almacenamiento local
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Eliminar token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Verificar si hay un token guardado
  Future<bool> hasToken() async {
    final token = await loadToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== AUTENTICACIÓN ====================

  /// Login - Retorna el token JWT si es exitoso
  Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String;
        
        // Guardar token automáticamente
        await saveToken(token);
        
        return token;
      } else if (response.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  /// Registro de nuevo usuario
  Future<String> register(String username, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registro exitoso - ahora hacer login automático
        return await login(username, password);
      } else if (response.statusCode == 400) {
        throw Exception('El usuario ya existe');
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  /// Logout - Elimina el token
  Future<void> logout() async {
    await clearToken();
  }

  /// Verificar si el token es válido haciendo una petición de prueba
  Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/empleados'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
