# 🔍 Cómo Verificar los Correos de EventBridge en Gmail

## ✅ Estado Actual
- **Correos enviados**: 4 en las últimas horas
- **SES Status**: Enviando correctamente (0 bounces, 0 rejects)
- **Cuenta SES**: Modo Sandbox (normal para cuentas nuevas)

## 📧 Dónde Buscar los Correos

### Opción 1: Carpeta de Spam
1. Abre Gmail: https://mail.google.com
2. Ve a la carpeta **"Spam"** (menú lateral izquierdo)
3. Busca correos de: **alexfrank.af04@gmail.com**
4. Asunto: **"Correo Automatizado - EventBridge"**

### Opción 2: Búsqueda Avanzada
Usa estas búsquedas en la barra de Gmail:

```
from:alexfrank.af04@gmail.com
```

```
subject:"Correo Automatizado - EventBridge"
```

```
"Este correo fue enviado automaticamente cada 5 minutos"
```

### Opción 3: Todas las Carpetas
1. En Gmail, haz clic en el menú desplegable de búsqueda
2. Selecciona **"Todo el correo"** o **"Más"**
3. Busca con las queries anteriores

## 🕐 Horarios de Envío (UTC-6)

Los correos se están enviando automáticamente a estas horas:

| Hora (UTC-6) | Estado | Message ID |
|--------------|--------|------------|
| 01:55:57 | ✅ Enviado | 0100019a717c38b7... |
| 02:00:57 | ✅ Enviado | 0100019a7180cc31... |
| 02:05:57 | ✅ Enviado | 0100019a71855ffe... |
| **Cada 5 minutos más...** | 🔄 | - |

## ⚠️ Por Qué Pueden Estar en Spam

Tu cuenta de Amazon SES está en **modo Sandbox**:
- Puedes enviar hasta 200 correos/día
- Solo a emails verificados (alexfrank.af04@gmail.com está verificado ✅)
- Gmail puede clasificarlos como spam porque:
  - No tienes reputación de envío establecida
  - Faltan registros de autenticación (SPF, DKIM, DMARC)
  - El remitente y destinatario son el mismo

## ✅ Cómo Marcarlos como "No es Spam"

Si encuentras los correos en spam:
1. Selecciona los correos
2. Haz clic en **"No es spam"** o **"Marcar como seguro"**
3. Los siguientes correos deberían llegar a la bandeja principal

## 🎯 Confirmar Funcionamiento

**El sistema está funcionando correctamente si:**
- ✅ EventBridge se ejecuta cada 5 minutos
- ✅ Lambda procesa sin errores
- ✅ SES envía correos (0 bounces, 0 rejects)
- ✅ Los correos están en alguna carpeta de Gmail

**Ya tenemos los primeros 3 confirmados en los logs de CloudWatch.**

## 🛑 Detener el Envío Automático

Cuando termines la demostración, ejecuta:

```powershell
# Deshabilitar EventBridge (deja de enviar correos)
aws events disable-rule --name crud-app-email-scheduler --region us-east-1
```

Para reactivarlo:

```powershell
# Reactivar EventBridge
aws events enable-rule --name crud-app-email-scheduler --region us-east-1
```

## 📊 Verificar Estadísticas SES

```powershell
# Ver estadísticas de envío
aws ses get-send-statistics --region us-east-1

# Ver estado de la cuenta
aws sesv2 get-account --region us-east-1
```

## 🎓 Para la Tarea 3

**Evidencia que debes mostrar:**
1. ✅ Regla EventBridge activa (cada 5 minutos)
2. ✅ Logs de CloudWatch con "✅ Correo enviado correctamente"
3. ✅ Estadísticas SES mostrando envíos exitosos
4. ✅ Correos en Gmail (aunque estén en spam, están ahí)

**No importa si están en spam** - lo que importa es demostrar que:
- EventBridge programa la ejecución automática
- Lambda se ejecuta de forma asíncrona
- SES envía los correos exitosamente
- Todo con $0 de costo

---

**Fecha de creación**: 11 de noviembre de 2025  
**Última ejecución verificada**: 02:05:57 (hora local)
