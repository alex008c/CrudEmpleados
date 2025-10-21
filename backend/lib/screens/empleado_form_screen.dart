import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/empleado.dart';
import '../viewmodels/empleado_viewmodel.dart';

class EmpleadoFormScreen extends StatefulWidget {
  final Empleado? empleado;

  const EmpleadoFormScreen({super.key, this.empleado});

  @override
  State<EmpleadoFormScreen> createState() => _EmpleadoFormScreenState();
}

class _EmpleadoFormScreenState extends State<EmpleadoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _puestoController;
  late TextEditingController _salarioController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _fotoUrlController;

  bool _isEditMode = false;
  File? _imageFile;
  bool _uploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.empleado != null;

    // Inicializar controladores con datos existentes o vacíos
    _nombreController = TextEditingController(text: widget.empleado?.nombre ?? '');
    _apellidoController = TextEditingController(text: widget.empleado?.apellido ?? '');
    _puestoController = TextEditingController(text: widget.empleado?.puesto ?? '');
    _salarioController = TextEditingController(
      text: widget.empleado?.salario.toString() ?? '',
    );
    _emailController = TextEditingController(text: widget.empleado?.email ?? '');
    _telefonoController = TextEditingController(text: widget.empleado?.telefono ?? '');
    _fotoUrlController = TextEditingController(text: widget.empleado?.fotoUrl ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _puestoController.dispose();
    _salarioController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<EmpleadoViewModel>();

    final empleado = Empleado(
      id: widget.empleado?.id,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      puesto: _puestoController.text.trim(),
      salario: double.parse(_salarioController.text.trim()),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      fotoUrl: _fotoUrlController.text.trim().isEmpty 
          ? null 
          : _fotoUrlController.text.trim(),
    );

    bool success;
    if (_isEditMode) {
      success = await viewModel.actualizarEmpleado(empleado);
    } else {
      success = await viewModel.crearEmpleado(empleado);
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true); // Retornar true para indicar éxito
    } else {
      _showErrorDialog(viewModel.errorMessage ?? 'Error al guardar');
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      // Mostrar opciones de fuente de imagen
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Seleccionar imagen
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _imageFile = File(image.path);
        _uploadingImage = true;
      });

      // Subir imagen al servidor
      final viewModel = context.read<EmpleadoViewModel>();
      final imageUrl = await viewModel.uploadImage(_imageFile!);

      if (!mounted) return;

      setState(() {
        _fotoUrlController.text = imageUrl;
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _uploadingImage = false;
      });

      _showErrorDialog('Error al subir imagen: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpleadoViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Editar Empleado' : 'Nuevo Empleado'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el apellido';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _puestoController,
                    decoration: const InputDecoration(
                      labelText: 'Puesto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el puesto';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _salarioController,
                    decoration: const InputDecoration(
                      labelText: 'Salario',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el salario';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingresa un número válido';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingresa un email válido';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el teléfono';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Sección de foto
                  const Text(
                    'Foto del Empleado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Botón para seleccionar imagen
                  OutlinedButton.icon(
                    onPressed: _uploadingImage || isLoading ? null : _seleccionarImagen,
                    icon: _uploadingImage 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate),
                    label: Text(_uploadingImage 
                        ? 'Subiendo imagen...' 
                        : 'Seleccionar Foto'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Campo de URL manual (opcional)
                  ExpansionTile(
                    title: const Text('O ingresar URL manualmente'),
                    children: [
                      TextFormField(
                        controller: _fotoUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Foto (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          helperText: 'Ingresa la URL de una imagen (ej: https://...)',
                        ),
                        keyboardType: TextInputType.url,
                        enabled: !isLoading && !_uploadingImage,
                        onChanged: (value) {
                          // Actualizar vista previa cuando cambia el texto
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  
                  // Vista previa de la imagen
                  if (_fotoUrlController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _fotoUrlController.text.trim(),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, 
                                    size: 48, 
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'URL de imagen inválida',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _guardarEmpleado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditMode ? 'ACTUALIZAR' : 'CREAR',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
