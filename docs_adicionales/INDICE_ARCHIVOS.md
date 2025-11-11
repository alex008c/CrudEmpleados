# 📁 Índice de Archivos del Proyecto

## 📋 Documentación Principal

### Para la Tarea 3 (EventBridge)
- **EVIDENCIA_TAREA3_EVENTBRIDGE.md** ⭐ - Documento completo para entregar
- **RESUMEN_TAREA3_COMPLETADA.md** - Resumen ejecutivo rápido
- **QUE_AUTOMATIZAMOS.md** - Explicación simple del sistema

### Información Adicional
- **VERIFICAR_CORREOS_GMAIL.md** - Cómo buscar los correos en Gmail
- **GUIA_EVENTBRIDGE.md** - Tutorial técnico de EventBridge
- **ANALISIS_COSTOS_AWS.md** - Análisis detallado de costos AWS

### Proyecto General
- **README.md** - Documentación general del proyecto CRUD
- **GUIA_INSTALACION.md** - Guía para instalar el proyecto

---

## 🔧 Scripts Útiles

### EventBridge (Tarea 3)
- **control_eventbridge.ps1** ⭐ - Control completo (activar/desactivar/estado/logs)
- **verificar_ejecuciones_eventbridge.ps1** - Ver estado y últimas ejecuciones
- **deploy_eventbridge.ps1** - Script de despliegue original

### Otros
- **ver_logs_aws.ps1** - Ver logs de CloudWatch
- **start.ps1** - Iniciar backend y frontend localmente

---

## 📂 Carpetas Importantes

- **backend/** - API FastAPI con Python
- **frontend/** - Aplicación Flutter
- **infra/lambdas/email_lambda/** - Código de la Lambda de emails
- **terraform/** - Configuración de infraestructura (no usado en despliegue final)
- **docs/** - Documentación adicional del proyecto
- **archivos_obsoletos/** - Archivos de tareas anteriores (ignorar)

---

## 🚀 Comandos Rápidos

### Ver estado de EventBridge
\`\`\`powershell
.\control_eventbridge.ps1 estado
\`\`\`

### Activar EventBridge (envío automático)
\`\`\`powershell
.\control_eventbridge.ps1 activar
\`\`\`

### Desactivar EventBridge (detener envíos)
\`\`\`powershell
.\control_eventbridge.ps1 desactivar
\`\`\`

### Ver logs en tiempo real
\`\`\`powershell
.\control_eventbridge.ps1 logs
\`\`\`

### Iniciar proyecto localmente
\`\`\`powershell
.\start.ps1
\`\`\`

---

## 📊 Para Tu Presentación

**Archivos principales a mostrar:**
1. ⭐ **EVIDENCIA_TAREA3_EVENTBRIDGE.md** - Toda la evidencia
2. ⭐ Correos en Gmail - Demostración visual
3. ⭐ **control_eventbridge.ps1 estado** - Estado del sistema

**Archivos de respaldo:**
- ANALISIS_COSTOS_AWS.md - Si preguntan por costos
- QUE_AUTOMATIZAMOS.md - Explicación simple
- GUIA_EVENTBRIDGE.md - Detalles técnicos

---

**Última actualización:** 11 de noviembre de 2025
