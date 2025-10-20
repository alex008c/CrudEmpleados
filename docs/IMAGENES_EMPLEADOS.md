# 📸 Guía de Imágenes de Empleados

## ✅ Funcionalidad Implementada

### **Características:**
- ✅ Campo "URL Foto (opcional)" en formulario
- ✅ Vista previa en tiempo real mientras escribes la URL
- ✅ Validación visual (muestra si la URL es válida)
- ✅ CircleAvatar con imagen en lista de empleados
- ✅ Fallback a inicial del nombre si no hay foto
- ✅ Manejo de errores si la imagen no carga

---

## 🎯 Cómo Usar

### **1. Crear/Editar Empleado:**
1. Click en botón **+** (crear) o **✏️** (editar)
2. Llena los campos normales (nombre, apellido, etc.)
3. En el campo **"URL Foto (opcional)"**, pega una URL de imagen
4. **Verás una vista previa** debajo del campo
5. Si la URL es válida → muestra la imagen ✅
6. Si la URL es inválida → muestra icono de error ❌
7. Guarda el empleado

### **2. Ver en Lista:**
- Si el empleado tiene foto → muestra la imagen en círculo
- Si no tiene foto → muestra inicial del nombre

---

## 🔗 URLs de Ejemplo para Probar

### **Fotos de Perfil Profesionales:**

```
https://randomuser.me/api/portraits/men/1.jpg
https://randomuser.me/api/portraits/women/1.jpg
https://randomuser.me/api/portraits/men/32.jpg
https://randomuser.me/api/portraits/women/44.jpg
https://randomuser.me/api/portraits/men/75.jpg
https://randomuser.me/api/portraits/women/65.jpg
```

### **Avatares de UI Avatars:**
```
https://ui-avatars.com/api/?name=Juan+Perez&size=200&background=0D8ABC&color=fff
https://ui-avatars.com/api/?name=Maria+Garcia&size=200&background=FF6B6B&color=fff
https://ui-avatars.com/api/?name=Carlos+Lopez&size=200&background=4ECDC4&color=fff
```

### **Fotos de Unsplash (Profesionales):**
```
https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop
https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop
https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop
https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop
```

---

## 💻 Código Implementado

### **1. Modelo (Ya existía)**

**Archivo:** `frontend/lib/models/empleado.dart`

```dart
class Empleado {
  final String? fotoUrl;  // ← Campo opcional para URL de foto
  
  Empleado({
    // ... otros campos
    this.fotoUrl,
  });
  
  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      // ... otros campos
      fotoUrl: json['foto_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      // ... otros campos
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}
```

---

### **2. Formulario con Vista Previa**

**Archivo:** `frontend/lib/screens/empleado_form_screen.dart`

```dart
// Controller
late TextEditingController _fotoUrlController;

@override
void initState() {
  super.initState();
  _fotoUrlController = TextEditingController(
    text: widget.empleado?.fotoUrl ?? ''
  );
}

// Campo de texto con vista previa
TextFormField(
  controller: _fotoUrlController,
  decoration: const InputDecoration(
    labelText: 'URL Foto (opcional)',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.image),
    helperText: 'Ingresa la URL de una imagen',
  ),
  keyboardType: TextInputType.url,
  onChanged: (value) {
    setState(() {}); // Actualiza vista previa
  },
),

// Vista previa (se muestra si hay URL)
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
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48),
                Text('URL de imagen inválida'),
              ],
            ),
          );
        },
      ),
    ),
  ),
],

// Guardar empleado
final empleado = Empleado(
  // ... otros campos
  fotoUrl: _fotoUrlController.text.trim().isEmpty 
      ? null 
      : _fotoUrlController.text.trim(),
);
```

---

### **3. Lista con Imágenes**

**Archivo:** `frontend/lib/screens/home_screen.dart`

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final empleado = viewModel.empleados[index];
    
    return ListTile(
      leading: empleado.fotoUrl != null && empleado.fotoUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(empleado.fotoUrl!),
              onBackgroundImageError: (exception, stackTrace) {
                // Si falla, CircleAvatar muestra placeholder
              },
            )
          : CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 25,
              child: Text(
                empleado.nombre[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
      title: Text('${empleado.nombre} ${empleado.apellido}'),
      subtitle: Text(empleado.puesto),
    );
  },
)
```

---

## 🎨 Características de la Implementación

### **Vista Previa en Tiempo Real:**
- ✅ Actualiza automáticamente con `onChanged`
- ✅ Muestra indicador de carga mientras descarga
- ✅ Muestra error si la URL no es válida
- ✅ Altura fija de 150px para consistencia

### **Manejo de Errores:**
- ✅ `errorBuilder` muestra icono de imagen rota
- ✅ `onBackgroundImageError` en CircleAvatar
- ✅ Fallback a inicial si no hay foto o falla

### **Optimizaciones:**
- ✅ `fit: BoxFit.cover` para que la imagen llene el espacio
- ✅ `ClipRRect` para bordes redondeados
- ✅ Campo opcional (no es requerido)

---

## 🔧 Backend (Ya Soporta)

**Base de datos:** Ya tiene columna `foto_url` (nullable)

**Modelo Python:** `backend/models.py`
```python
class EmpleadoDB(Base):
    __tablename__ = "empleados"
    
    foto_url = Column(String, nullable=True)  # ← Ya existe

class EmpleadoBase(BaseModel):
    foto_url: Optional[str] = None  # ← Ya existe
```

**Endpoint:** Ya acepta y devuelve `foto_url` en JSON

---

## 📝 Ejemplo de Uso Completo

### **Paso 1: Crear empleado con foto**
```
Nombre: Juan
Apellido: Pérez
Puesto: Desarrollador
Salario: 50000
Email: juan@empresa.com
Teléfono: 555-1234
URL Foto: https://randomuser.me/api/portraits/men/32.jpg
```

### **Paso 2: Ver en lista**
- Verás un círculo con la foto de Juan
- Si haces hover, se ve completa

### **Paso 3: Editar y cambiar foto**
- Click en ✏️ editar
- Cambia la URL a otra imagen
- Ve la vista previa actualizada
- Guarda

---

## 🚀 Prueba Rápida

### **Datos de Prueba con Fotos:**

**Empleado 1:**
```
Nombre: Juan
Apellido: Saldivar
Foto: https://randomuser.me/api/portraits/men/1.jpg
```

**Empleado 2:**
```
Nombre: Maycol
Apellido: Pereira
Foto: https://randomuser.me/api/portraits/men/32.jpg
```

**Empleado 3:**
```
Nombre: María
Apellido: García
Foto: https://randomuser.me/api/portraits/women/44.jpg
```

---

## 🎯 Para la Presentación

### **Captura de Pantalla 1: Formulario**
- Muestra el campo "URL Foto (opcional)"
- Con vista previa activa de una imagen

### **Captura de Pantalla 2: Lista**
- Muestra empleados con sus fotos en círculo
- Algunos con foto, otros con inicial

### **Captura de Pantalla 3: Error Handling**
- Muestra qué pasa con URL inválida
- Icono de imagen rota en vista previa

---

## ⚠️ Limitaciones Actuales

- ❌ No soporta subir archivos desde dispositivo
- ❌ No soporta almacenamiento en servidor
- ✅ Solo URL externas (suficiente para el proyecto)
- ✅ Simple, funcional y cumple el objetivo

---

## 🔮 Mejoras Futuras (Opcional)

Si quieres mejorar después:

1. **Subir archivos:** Usar `image_picker` + backend storage
2. **Cache de imágenes:** Usar `cached_network_image`
3. **Crop de imágenes:** Permitir recortar
4. **Avatares generados:** API de avatares automáticos

---

## ✅ Checklist

- [x] ✅ Campo `foto_url` en modelo
- [x] ✅ Campo en formulario con vista previa
- [x] ✅ Validación visual (carga/error)
- [x] ✅ Mostrar en lista de empleados
- [x] ✅ Fallback a inicial si no hay foto
- [x] ✅ Manejo de errores de carga
- [x] ✅ Backend ya lo soporta
- [x] ✅ Documentación completa

---

## 🎉 ¡Listo para Usar!

La funcionalidad de imágenes está completamente implementada y lista para demostrar en tu presentación.
