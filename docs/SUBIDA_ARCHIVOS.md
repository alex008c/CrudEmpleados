# Subida de Archivos - Imágenes de Empleados

## Descripción General

El sistema permite subir imágenes reales de empleados desde el dispositivo (galería o cámara) en lugar de solo URLs. Las imágenes se almacenan en el servidor y se sirven como archivos estáticos.

## Arquitectura de Subida de Archivos

### Backend (FastAPI)

**1. Endpoint de Subida (`POST /upload-image`)**

```python
@app.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: str = Depends(auth.verify_token)
):
    """
    Sube una imagen de empleado y devuelve la URL.
    - Acepta: jpg, jpeg, png, gif
    - Tamaño máximo: 5MB
    - Requiere autenticación JWT
    """
```

**Validaciones implementadas:**
- ✅ Tipo de archivo (solo imágenes: jpg, jpeg, png, gif)
- ✅ Tamaño máximo (5MB)
- ✅ Autenticación requerida
- ✅ Nombres únicos (timestamp + UUID)

**Proceso:**
1. Recibe archivo vía `multipart/form-data`
2. Valida tipo MIME (`image/jpeg`, `image/png`, etc.)
3. Lee contenido completo y valida tamaño
4. Genera nombre único: `YYYYMMDD_HHMMSS_uuid.extension`
5. Guarda en directorio `uploads/`
6. Retorna URL completa: `http://127.0.0.1:8000/uploads/nombre_archivo.jpg`

**2. Servicio de Archivos Estáticos**

```python
# Crear directorio para archivos subidos
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

# Montar directorio estático
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
```

**Características:**
- Directorio `uploads/` creado automáticamente
- Archivos accesibles vía HTTP GET
- Sin autenticación para servir imágenes (públicas)

### Frontend (Flutter)

**1. Repositorio - Método `uploadImage()`**

```dart
Future<String> uploadImage(File imageFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/upload-image'),
  );
  
  // Agregar autenticación
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  
  // Agregar archivo
  request.files.add(
    await http.MultipartFile.fromPath('file', imageFile.path),
  );
  
  // Enviar y obtener respuesta
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['url'] as String; // Retorna URL del archivo
  } else {
    throw Exception('Error al subir imagen');
  }
}
```

**2. ViewModel - Coordinación**

```dart
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
```

**3. Vista - Interfaz de Usuario**

**Método de selección:**
```dart
Future<void> _seleccionarImagen() async {
  // 1. Mostrar diálogo: Galería o Cámara
  final source = await showDialog<ImageSource>(...);
  
  // 2. Seleccionar imagen con image_picker
  final XFile? image = await _picker.pickImage(
    source: source,
    maxWidth: 800,      // Redimensiona automáticamente
    maxHeight: 800,
    imageQuality: 85,   // Compresión JPEG
  );
  
  // 3. Subir al servidor
  setState(() {
    _imageFile = File(image.path);
    _uploadingImage = true;
  });
  
  final viewModel = context.read<EmpleadoViewModel>();
  final imageUrl = await viewModel.uploadImage(_imageFile!);
  
  // 4. Actualizar campo de URL
  setState(() {
    _fotoUrlController.text = imageUrl;
    _uploadingImage = false;
  });
}
```

**Componentes de UI:**

```dart
// Botón principal de selección
OutlinedButton.icon(
  onPressed: _uploadingImage || isLoading ? null : _seleccionarImagen,
  icon: _uploadingImage 
      ? CircularProgressIndicator(strokeWidth: 2)
      : Icon(Icons.add_photo_alternate),
  label: Text(_uploadingImage 
      ? 'Subiendo imagen...' 
      : 'Seleccionar Foto'),
)

// Opción de URL manual (colapsable)
ExpansionTile(
  title: Text('O ingresar URL manualmente'),
  children: [
    TextFormField(
      controller: _fotoUrlController,
      enabled: !isLoading && !_uploadingImage,
      // ...
    ),
  ],
)

// Vista previa con error handling
if (_fotoUrlController.text.trim().isNotEmpty)
  Image.network(
    _fotoUrlController.text.trim(),
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return CircularProgressIndicator(...);
    },
    errorBuilder: (context, error, stackTrace) {
      return Text('Error al cargar imagen');
    },
  )
```

## Flujo Completo

### Crear Empleado con Foto Subida

```
Usuario                    Vista                    ViewModel           Repository           Backend
  |                         |                          |                    |                   |
  |--Click "Seleccionar"--->|                          |                    |                   |
  |                         |--Muestra diálogo-------->|                    |                   |
  |                         |  (Galería/Cámara)        |                    |                   |
  |<-Selecciona fuente------|                          |                    |                   |
  |                         |--image_picker.pickImage->|                    |                   |
  |<-Selecciona imagen------|                          |                    |                   |
  |                         |--uploadImage(File)------>|                    |                   |
  |                         |                          |--uploadImage()---->|                   |
  |                         |                          |                    |--POST /upload---->|
  |                         |                          |                    |                   |--Valida tipo
  |                         |                          |                    |                   |--Valida tamaño
  |                         |                          |                    |                   |--Genera nombre único
  |                         |                          |                    |                   |--Guarda en uploads/
  |                         |                          |                    |<--{url, size}-----|
  |                         |                          |<---imageUrl--------|                   |
  |                         |<-URL de imagen-----------|                    |                   |
  |<-Actualiza campo URL----|                          |                    |                   |
  |                         |                          |                    |                   |
  |--Click "Guardar"------->|                          |                    |                   |
  |                         |--crearEmpleado()-------->|                    |                   |
  |                         |  (con fotoUrl)           |--createEmpleado()->|                   |
  |                         |                          |                    |--POST /empleados->|
  |                         |                          |                    |                   |--Guarda en DB
  |                         |                          |                    |<--{empleado}------|
  |                         |<-Success-----------------|                    |                   |
  |<-Navigate back----------|                          |                    |                   |
```

### Mostrar Imagen en Lista

```
Usuario                    Vista                    Backend
  |                         |                          |
  |--Ver lista empleados--->|                          |
  |                         |--CircleAvatar----------->|
  |                         |  backgroundImage:        |
  |                         |  NetworkImage(url)       |--GET /uploads/archivo.jpg
  |<-Muestra foto-----------|<-Archivo binario---------|
```

## Dependencias Agregadas

### Backend (Python)

```python
from fastapi import File, UploadFile
from fastapi.staticfiles import StaticFiles
import os
import shutil
from pathlib import Path
```

**Instaladas por defecto con FastAPI**, no requiere instalación adicional.

### Frontend (Flutter)

```yaml
dependencies:
  image_picker: ^1.2.0  # Selector de imágenes (galería/cámara)
```

**Instalado con:**
```bash
flutter pub add image_picker
```

## Ventajas vs URLs Manuales

| Aspecto | URLs Manuales | Subida de Archivos |
|---------|---------------|-------------------|
| **Facilidad de uso** | ❌ Debe buscar URL externa | ✅ Selecciona de galería/cámara |
| **Control de archivos** | ❌ Depende de servidores externos | ✅ Archivos almacenados localmente |
| **Disponibilidad** | ❌ URLs pueden morir | ✅ Siempre disponible |
| **Privacidad** | ❌ Imágenes en servidores de terceros | ✅ Datos en tu servidor |
| **Validación** | ❌ Difícil validar contenido | ✅ Valida tipo y tamaño |
| **Profesionalismo** | ⚠️ Válido para desarrollo | ✅ Producción-ready |

## Configuración de Producción

### 1. Limitar Tamaño de Request (nginx)

```nginx
client_max_body_size 5M;
```

### 2. Cambiar URL Base en Frontend

```dart
// Desarrollo
final baseUrl = 'http://127.0.0.1:8000';

// Producción
final baseUrl = 'https://api.tudominio.com';
```

### 3. Configurar CORS para Uploads

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://tudominio.com"],  # Específico en producción
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 4. Almacenamiento en la Nube (Opcional)

Para producción a gran escala, considerar:
- **AWS S3**: Almacenamiento escalable
- **Cloudinary**: Optimización automática de imágenes
- **Google Cloud Storage**: Integración con GCP

**Ejemplo con AWS S3:**
```python
import boto3

s3_client = boto3.client('s3')

@app.post("/upload-image")
async def upload_image_s3(file: UploadFile = File(...)):
    # Subir a S3 en lugar de filesystem local
    s3_client.upload_fileobj(
        file.file,
        'mi-bucket',
        unique_filename
    )
    return {"url": f"https://mi-bucket.s3.amazonaws.com/{unique_filename}"}
```

## Seguridad

### Medidas Implementadas

1. **Autenticación**: Solo usuarios autenticados pueden subir
2. **Validación de tipo**: Solo acepta formatos de imagen
3. **Límite de tamaño**: Máximo 5MB por archivo
4. **Nombres únicos**: Previene sobrescritura de archivos
5. **Servicio público**: Imágenes accesibles sin autenticación (para mostrar en UI)

### Mejoras Adicionales (Producción)

```python
# Validación de contenido real (no solo extensión)
from PIL import Image

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    # Validar que sea imagen real
    try:
        image = Image.open(file.file)
        image.verify()  # Verifica que sea imagen válida
    except Exception:
        raise HTTPException(400, "Archivo no es una imagen válida")
    
    # Sanitizar nombre de archivo
    import re
    safe_filename = re.sub(r'[^a-zA-Z0-9._-]', '', file.filename)
```

## Troubleshooting

### Error: "Cannot find 'image_picker'"

**Solución:**
```bash
cd frontend
flutter pub get
flutter clean
flutter pub get
```

### Error: "Failed to upload image"

**Backend no recibe archivo:**
- Verificar que el servidor esté corriendo
- Comprobar token de autenticación
- Revisar logs del backend

**Frontend no envía correctamente:**
- Verificar que `http` usa `MultipartRequest`
- Confirmar que el campo se llama `'file'` en ambos lados

### Imágenes muy grandes (>5MB)

**Reducir tamaño en frontend:**
```dart
final XFile? image = await _picker.pickImage(
  source: source,
  maxWidth: 800,     // Ajustar según necesidad
  maxHeight: 800,
  imageQuality: 70,  // Reducir calidad (1-100)
);
```

### Permisos de cámara/galería

**Android** - `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** - `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para seleccionar imagen de empleado</string>
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar foto de empleado</string>
```

## Pruebas

### Caso 1: Subir desde Galería
1. Abrir formulario de empleado
2. Click en "Seleccionar Foto"
3. Elegir "Galería"
4. Seleccionar imagen
5. Verificar que se muestre "Subiendo imagen..."
6. Confirmar que aparece vista previa
7. Guardar empleado
8. Verificar que la imagen se muestre en la lista

### Caso 2: Subir desde Cámara
1. Abrir formulario
2. Click "Seleccionar Foto" → "Cámara"
3. Tomar foto
4. Verificar subida exitosa

### Caso 3: Validación de Tamaño
1. Intentar subir imagen >5MB
2. Verificar mensaje de error: "El archivo es muy grande"

### Caso 4: Validación de Tipo
1. Intentar subir archivo `.txt` o `.pdf`
2. Verificar mensaje: "Tipo de archivo no permitido"

## Archivos Modificados

### Backend
- ✅ `backend/main.py` - Endpoint `/upload-image`, configuración de StaticFiles
- ✅ Directorio `backend/uploads/` - Creado automáticamente

### Frontend
- ✅ `frontend/lib/repositories/empleado_repository.dart` - Método `uploadImage()`
- ✅ `frontend/lib/viewmodels/empleado_viewmodel.dart` - Coordinación de subida
- ✅ `frontend/lib/screens/empleado_form_screen.dart` - UI de selección e indicador de progreso
- ✅ `frontend/pubspec.yaml` - Dependencia `image_picker`

## Referencias

- [FastAPI File Uploads](https://fastapi.tiangolo.com/tutorial/request-files/)
- [FastAPI Static Files](https://fastapi.tiangolo.com/tutorial/static-files/)
- [Flutter image_picker](https://pub.dev/packages/image_picker)
- [HTTP Multipart Requests in Dart](https://pub.dev/documentation/http/latest/http/MultipartRequest-class.html)

---

**Autor:** Sistema CRUD Empleados  
**Versión:** 1.1.0  
**Última actualización:** 2024
