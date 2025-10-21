import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/empleado_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/empleado_viewmodel.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Configuración de la URL del backend
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
  // Para Android Emulator: 'http://10.0.2.2:8000'
  // Para dispositivo físico: 'http://TU_IP_LOCAL:8000'

  @override
  Widget build(BuildContext context) {
    // Configurar MultiProvider para MVVM
    // Proporciona los ViewModels a toda la aplicación
    return MultiProvider(
      providers: [
        // Provider para AuthViewModel
        ChangeNotifierProvider(
          create: (context) {
            final authRepo = AuthRepository(baseUrl: apiBaseUrl);
            final authViewModel = AuthViewModel(authRepo);
            // Verificar sesión al iniciar
            authViewModel.checkAuthStatus();
            return authViewModel;
          },
        ),
        
        // Provider para EmpleadoViewModel (depende de AuthViewModel para el token)
        ChangeNotifierProxyProvider<AuthViewModel, EmpleadoViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();
            final empleadoRepo = EmpleadoRepository(
              baseUrl: apiBaseUrl,
              token: authViewModel.currentToken,
            );
            return EmpleadoViewModel(empleadoRepo);
          },
          update: (context, authViewModel, previousEmpleadoViewModel) {
            // Actualizar repository con nuevo token cuando cambie la autenticación
            final empleadoRepo = EmpleadoRepository(
              baseUrl: apiBaseUrl,
              token: authViewModel.currentToken,
            );
            return EmpleadoViewModel(empleadoRepo);
          },
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return MaterialApp(
            title: 'CRUD Empleados - MVVM',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            // Navegación basada en estado de autenticación
            home: authViewModel.isLoading
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : authViewModel.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}

