import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/empleado.dart';
import '../viewmodels/empleado_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'empleado_form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpleadoViewModel>().cargarEmpleados();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.logout();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EmpleadoFormScreen(),
      ),
    );

    if (result == true && mounted) {
      context.read<EmpleadoViewModel>().cargarEmpleados();
    }
  }

  Future<void> _handleEdit(Empleado empleado) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EmpleadoFormScreen(empleado: empleado),
      ),
    );

    if (result == true && mounted) {
      context.read<EmpleadoViewModel>().cargarEmpleados();
    }
  }

  Future<void> _handleDelete(Empleado empleado) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar a ${empleado.nombre} ${empleado.apellido}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final viewModel = context.read<EmpleadoViewModel>();
      final success = await viewModel.eliminarEmpleado(empleado.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Empleado eliminado'
                : viewModel.errorMessage ?? 'Error al eliminar',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _demostrarConcurrencia() async {
    final viewModel = context.read<EmpleadoViewModel>();

    // Verificar que hay al menos 2 empleados
    if (viewModel.empleados.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesitan al menos 2 empleados para la demo'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Ejecutando comparación...'),
          ],
        ),
      ),
    );

    try {
      final resultado = await viewModel.ejecutarDemoConcurrencia();

      if (!mounted) return;

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Comparación de Velocidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Secuencial: ${resultado.secuencial.tiempoMs} ms'),
              Text('Paralelo: ${resultado.paralelo.tiempoMs} ms'),
              const SizedBox(height: 8),
              Text(
                '${resultado.mejoraPorcentaje.toStringAsFixed(1)}% más rápido',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Empleados - MVVM'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer<EmpleadoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.empleados.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando empleados...'),
                ],
              ),
            );
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.cargarEmpleados(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay empleados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega el primer empleado',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar empleado'),
                  ),
                ],
              ),
            );
          }

          // Filtrar empleados según búsqueda
          final empleadosFiltrados = _searchQuery.isEmpty
              ? viewModel.empleados
              : viewModel.buscarEmpleados(_searchQuery);

          return Column(
            children: [
              // Campo de búsqueda
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar empleado por nombre o apellido...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Resultados de búsqueda
              if (empleadosFiltrados.isEmpty && _searchQuery.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otro término de búsqueda',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Lista de empleados
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => viewModel.cargarEmpleados(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: empleadosFiltrados.length,
                      itemBuilder: (context, index) {
                        final empleado = empleadosFiltrados[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: empleado.fotoUrl != null && empleado.fotoUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(empleado.fotoUrl!),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      // Si falla la carga, no hacer nada (mostrará el placeholder)
                                    },
                                    child: null, // La imagen se muestra como fondo
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.blue.shade700,
                                    radius: 25,
                                    child: Text(
                                      empleado.nombre[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                            title: Text(
                              '${empleado.nombre} ${empleado.apellido}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(empleado.puesto),
                                Text(
                                  '\$${empleado.salario.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _handleEdit(empleado),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _handleDelete(empleado),
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _demostrarConcurrencia,
            backgroundColor: Colors.orange,
            heroTag: 'concurrency',
            tooltip: 'Comparar velocidad',
            child: const Icon(Icons.speed),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _handleCreate,
            backgroundColor: Colors.blue.shade700,
            heroTag: 'add',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}