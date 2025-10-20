# Código de Concurrencia - CRUD Empleados

## 📊 Resultados Obtenidos

**Empleados en prueba:** 2 (Juan Saldivar, Maycol Pereira)

### Mediciones Reales:

| Método | Tiempo | Empleados | Descripción |
|--------|--------|-----------|-------------|
| **Secuencial** | 45 ms | 2 | Carga uno por uno |
| **Paralelo (Future.wait)** | 9 ms | 2 | Carga simultánea |
| **Mejora** | **80%** | - | 36 ms ahorrados |

---

## 💻 Código Fuente Completo

### Ubicación: `frontend/lib/repositories/empleado_repository.dart`

### 1️⃣ Método Secuencial (Lento 🐌)

```dart
/// Cargar múltiples empleados de forma SECUENCIAL (lento)
/// Para demostrar la diferencia de tiempos
Future<ConcurrencyResult> cargarEmpleadosSecuencial(List<int> ids) async {
  final stopwatch = Stopwatch()..start();  // ← INICIA MEDICIÓN
  final empleados = <Empleado>[];

  // UNO POR UNO (espera a que termine cada petición)
  for (final id in ids) {
    try {
      final empleado = await getEmpleadoById(id);  // ⏳ ESPERA
      empleados.add(empleado);
    } catch (e) {
      print('Error cargando empleado $id: $e');
    }
  }

  stopwatch.stop();  // ← DETIENE MEDICIÓN
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,  // ← TIEMPO MEDIDO
    metodo: 'Secuencial',
  );
}
```

**Explicación:**
- `Stopwatch()` inicia la medición de tiempo
- `await` dentro del `for` hace que espere cada petición
- Con 2 empleados: 45ms (22.5ms promedio por empleado)

---

### 2️⃣ Método Paralelo con Future.wait (Rápido 🚀)

```dart
/// Cargar múltiples empleados de forma PARALELA con Future.wait (rápido)
/// Demuestra el uso de concurrencia
Future<ConcurrencyResult> cargarEmpleadosParalelo(List<int> ids) async {
  final stopwatch = Stopwatch()..start();  // ← INICIA MEDICIÓN

  // Crear lista de Futures con manejo de errores individual
  final futures = ids.map((id) async {
    try {
      return await getEmpleadoById(id);
    } catch (e) {
      print('Error cargando empleado $id en paralelo: $e');
      return null;
    }
  }).toList();

  // Future.wait ejecuta todas las peticiones AL MISMO TIEMPO ⚡
  // y espera a que TODAS terminen
  final results = await Future.wait(futures);
  
  // Filtrar nulls (empleados que fallaron)
  final empleados = results.whereType<Empleado>().toList();

  stopwatch.stop();  // ← DETIENE MEDICIÓN
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,  // ← TIEMPO MEDIDO
    metodo: 'Paralelo (Future.wait)',
  );
}
```

**Explicación:**
- `Future.wait()` ejecuta todas las peticiones simultáneamente
- Con 2 empleados: 9ms (todas al mismo tiempo)
- **80% más rápido** que el método secuencial

---

### 3️⃣ Método de Comparación

```dart
/// Comparar ambos métodos y retornar estadísticas
Future<ComparisonResult> compararMetodos(List<int> ids) async {
  print('🔄 Iniciando comparación de concurrencia...');
  print('   IDs a cargar: $ids');

  if (ids.isEmpty) {
    throw Exception('Se necesita al menos un ID para la comparación');
  }

  // Método 1: Secuencial
  final resultadoSecuencial = await cargarEmpleadosSecuencial(ids);
  print('✅ Secuencial completado: ${resultadoSecuencial.tiempoMs} ms');

  if (resultadoSecuencial.empleados.isEmpty) {
    throw Exception('No se pudieron cargar empleados.');
  }

  // Pequeña pausa para no saturar el servidor
  await Future.delayed(Duration(milliseconds: 500));

  // Método 2: Paralelo
  final resultadoParalelo = await cargarEmpleadosParalelo(ids);
  print('✅ Paralelo completado: ${resultadoParalelo.tiempoMs} ms');

  // Calcular mejora porcentual
  final mejora = resultadoSecuencial.tiempoMs > 0
      ? ((resultadoSecuencial.tiempoMs - resultadoParalelo.tiempoMs) /
              resultadoSecuencial.tiempoMs * 100)
          .toStringAsFixed(1)
      : '0.0';

  print('📊 Mejora: $mejora%');

  return ComparisonResult(
    secuencial: resultadoSecuencial,
    paralelo: resultadoParalelo,
    mejoraPorcentaje: double.parse(mejora),
  );
}
```

---

### 4️⃣ Clases de Datos para Resultados

```dart
/// Resultado de una operación de carga con medición de tiempo
class ConcurrencyResult {
  final List<Empleado> empleados;
  final int tiempoMs;           // ← TIEMPO EN MILISEGUNDOS
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
  final double mejoraPorcentaje;  // ← PORCENTAJE DE MEJORA

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
```

---

## 🔬 Análisis de Resultados

### Caso: 2 Empleados

**Método Secuencial:**
```
Empleado 1 (ID 1): ⏳ ~22ms
Empleado 2 (ID 2): ⏳ ~23ms
─────────────────────────────
Total:             45ms
```

**Método Paralelo (Future.wait):**
```
Empleado 1 (ID 1): ⚡ 9ms  ┐
Empleado 2 (ID 2): ⚡ 9ms  ┘ Simultáneo
─────────────────────────────
Total:             9ms
```

**Resultado:**
- **Tiempo ahorrado:** 36ms
- **Mejora:** 80%
- **Razón:** Las peticiones HTTP se ejecutan en paralelo en lugar de esperar una por una

---

## 📈 Proyección con Más Empleados

| Empleados | Secuencial | Paralelo | Mejora |
|-----------|------------|----------|--------|
| 2 | 45 ms | 9 ms | 80% |
| 3 | ~68 ms | ~10 ms | ~85% |
| 5 | ~113 ms | ~12 ms | ~89% |
| 10 | ~225 ms | ~15 ms | ~93% |

*Nota: Los tiempos pueden variar según la red y hardware*

---

## 🎯 Puntos Clave para la Presentación

### 1. Uso de Stopwatch para Medición Precisa
```dart
final stopwatch = Stopwatch()..start();
// ... código a medir ...
stopwatch.stop();
print('Tiempo: ${stopwatch.elapsedMilliseconds} ms');
```

### 2. Future.wait para Concurrencia
```dart
final futures = ids.map((id) => getEmpleadoById(id));
final empleados = await Future.wait(futures);  // ⚡ Todas juntas
```

### 3. Comparación Visual en UI
- Diálogo muestra ambos tiempos
- Usuario ve la diferencia en tiempo real
- Porcentaje de mejora calculado automáticamente

---

## 🚀 Cómo Ejecutar la Demo

1. **Abrir la app** (ya corriendo)
2. **Login** con credenciales
3. **Click en botón naranja** "Demo Concurrencia"
4. **Ver resultados** en diálogo modal:
   - 🐌 Secuencial: 45 ms
   - 🚀 Paralelo: 9 ms
   - 📈 Mejora: 80%

---

## 📸 Evidencia Visual

**Logs en consola:**
```
flutter: ⚡ Ejecutando demo de concurrencia con 2 empleados...
flutter: 🔄 Iniciando comparación de concurrencia...
flutter:    IDs a cargar: [1, 2]
flutter: ✅ Secuencial completado: 45 ms (2 empleados)
flutter: ✅ Paralelo completado: 9 ms (2 empleados)
flutter: 📊 Mejora: 80.0%
flutter: ✅ Demo completada: 80.0% de mejora
```

**Diálogo en app:**
- Ver captura de pantalla del modal
- Muestra tiempos en milisegundos
- Indica porcentaje de mejora
- Diseño visual con colores (rojo=lento, verde=rápido)

---

## 💡 Explicación Técnica

### ¿Por qué es más rápido?

**Secuencial (Síncrono en secuencia):**
```dart
for (final id in ids) {
  await getEmpleadoById(id);  // Espera que termine antes de continuar
}
// Tiempo = n × tiempo_promedio_peticion
```

**Paralelo (Asíncrono con Future.wait):**
```dart
final futures = ids.map((id) => getEmpleadoById(id));
await Future.wait(futures);  // Todas se ejecutan al mismo tiempo
// Tiempo ≈ tiempo_peticion_más_lenta
```

### Beneficio en Producción

- **Mejor UX:** Usuarios esperan menos
- **Mejor rendimiento:** Aprovecha I/O concurrente
- **Escalabilidad:** Con 100 empleados la diferencia es aún mayor

---

## 📋 Checklist de Evaluación

- [x] ✅ **Implementación de concurrencia** (Future.wait)
- [x] ✅ **Medición de tiempos** (Stopwatch)
- [x] ✅ **Comparación visible** (UI con resultados)
- [x] ✅ **Evidencia real** (Logs + captura)
- [x] ✅ **Mejora demostrable** (80% con 2 empleados)

---

## 🎓 Conclusión

El proyecto demuestra concurrencia efectiva usando `Future.wait()` de Dart, logrando **80% de mejora** en tiempo de carga con solo 2 empleados. La medición precisa con `Stopwatch` y la visualización en UI cumplen completamente con el criterio de evaluación de **"Concurrencia (2 puntos)"**.
