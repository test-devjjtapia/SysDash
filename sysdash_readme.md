# SysDash 📊

Dashboard simple en terminal para monitoreo de sistema Linux en tiempo real. Muestra información clave sobre temperatura, CPU, batería, alimentación y procesos activos.

![Terminal Dashboard](https://img.shields.io/badge/Terminal-Dashboard-blue)
![Shell Script](https://img.shields.io/badge/Shell-Bash-green)
![Linux](https://img.shields.io/badge/Platform-Linux-orange)

## 📥 Descarga rápida

```bash
# Descarga directa del script
curl -O https://raw.githubusercontent.com/tu-usuario/sysdash/main/sysdash.sh
chmod +x sysdash.sh
./sysdash.sh
```

## 🚀 Características

- **Monitoreo de CPU**: Uso porcentual y frecuencia actual
- **Control térmico**: Temperatura máxima del sistema
- **Gestión de energía**: Estado del perfil de energía y Turbo Boost
- **Estado de batería**: Porcentaje y estado de carga
- **Información de alimentación**: AC conectado o funcionando con batería
- **Ventiladores**: Estado de los ventiladores del sistema
- **Procesos activos**: Top 5 procesos que más CPU consumen
- **Actualización en tiempo real**: Interfaz que se refresca automáticamente

## 📋 Requisitos

### Obligatorios
- **Bash 4.0+**
- **Sistema operativo Linux**
- Acceso a `/proc/stat` y `/sys/`

### Opcionales (para funcionalidad completa)
- `powerprofilesctl` - Para información de perfiles de energía
- `upower` - Para información detallada de batería  
- `sensors` (lm-sensors) - Para monitoreo de ventiladores

## 🔧 Instalación

### Instalación rápida
```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/sysdash.git
cd sysdash

# Hacer ejecutable
chmod +x sysdash.sh

# Ejecutar
./sysdash.sh
```

### Instalación global
```bash
# Copiar a directorio del PATH
sudo cp sysdash.sh /usr/local/bin/sysdash
sudo chmod +x /usr/local/bin/sysdash

# Ejecutar desde cualquier lugar
sysdash
```

### Dependencias opcionales (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install lm-sensors upower power-profiles-daemon
```

### Dependencias opcionales (Arch Linux)
```bash
sudo pacman -S lm_sensors upower power-profiles-daemon
```

### Dependencias opcionales (Fedora/RHEL)
```bash
sudo dnf install lm_sensors upower power-profiles-daemon
```

## 💻 Uso

### Uso básico
```bash
./sysdash.sh
```

### Con intervalo personalizado
```bash
./sysdash.sh 5    # Refresca cada 5 segundos
./sysdash.sh 1    # Refresca cada segundo
```

### Salir del programa
Presiona `Ctrl+C` para salir.

## 📊 Información mostrada

### Cabecera del sistema
- **Fecha y hora actual**
- **Perfil de energía**: balanced, performance, power-saver
- **Turbo Boost**: ENABLED/DISABLED/n/a

### Estado de alimentación
- **Tipo de alimentación**: AC conectado o funcionando con batería
- **Batería**: Porcentaje y estado (charging/discharging/full)

### Rendimiento del sistema
- **CPU uso**: Porcentaje de uso actual
- **Frecuencia**: Frecuencia promedio de todos los núcleos
- **Temperatura máxima**: Mayor temperatura detectada en thermal zones

### Monitoreo adicional
- **Ventiladores**: Estado RPM de hasta 3 ventiladores
- **Top procesos**: 5 procesos que más CPU consumen

## ⚙️ Personalización

### Cambiar intervalo por defecto
Edita la línea 5 del script:
```bash
INTERVAL="${1:-2}"   # Cambiar 2 por el valor deseado
```

### Modificar número de procesos mostrados
En la función `top_cpu_processes()`, cambia:
```bash
NR>=6{exit}    # Cambiar 6 por el número deseado + 1
```

## 🔍 Solución de problemas

### "n/a" en información de batería
```bash
# Instalar upower
sudo apt install upower

# Verificar dispositivos de batería
upower -e
```

### "n/a" en perfil de energía
```bash
# Verificar si el servicio está activo
systemctl status power-profiles-daemon

# Iniciar el servicio si no está activo
sudo systemctl start power-profiles-daemon
```

### "n/a" en información de ventiladores
```bash
# Instalar sensors
sudo apt install lm-sensors

# Detectar sensores
sudo sensors-detect

# Verificar que funciona
sensors
```

### Permisos insuficientes
Si aparecen errores de permisos al acceder a `/sys/`:
```bash
# Verificar que el usuario esté en el grupo adecuado
groups $USER

# El script debería funcionar sin privilegios especiales
```

## 🔒 Consideraciones de seguridad

- El script solo **lee** información del sistema
- No requiere privilegios de root
- No modifica configuraciones del sistema
- Acceso de solo lectura a `/proc/` y `/sys/`

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

### Ideas para contribuir
- Soporte para más distribuciones Linux
- Información de red (ancho de banda)
- Información de almacenamiento (uso de disco)
- Mejoras visuales en la interfaz
- Configuración por archivo de configuración
- Exportar datos a archivo log

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🙏 Reconocimientos

- Inspirado en herramientas como `htop`, `neofetch` y `btop`
- Utiliza herramientas estándar de Linux para máxima compatibilidad
- Diseñado para ser ligero y eficiente

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias:
- Abre un [Issue](https://github.com/tu-usuario/sysdash/issues)
- Descripción detallada del problema
- Información de tu distribución Linux
- Salida de error si la hay

---

**SysDash** - Monitoreo simple y efectivo para tu sistema Linux 🐧