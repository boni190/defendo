# Limitaciones y Roadmap

Defendo no promete seguridad absoluta ni reemplaza el análisis dinámico o el sentido común en desarrollo de software. Pretende **reducir superficie de ataque**, **hacer visible el riesgo** y **forzar hábitos seguros**.

## Limitaciones Reales de Defendo

- **El analizador usa heurísticas:** No escanea dinámicamente cómo se comportan los procesos de forma aislada, sino que audita las descripciones (ej. Lockfiles o análisis estático básico).
- **No es un EDR ni un bloqueador en tiempo real:** Si el comando `npm run build` interno del paquete arranca un malware indetectable vía análisis estático, el script se consumará.
- **El Permission Model de Node:** Node.js no funciona como un sandbox completamente seguro. Reduce la superficie, pero los bindings C++, N-API o configuraciones vulnerables pueden eludir un control mal gestionado de Defendo.
- **Factor Humano:** Defendo delega en el programador sus excepciones. Un equipo introduciendo comodines `"*"` en el `allowlist` neutralizará al toolkit.
- **Cuentas Comprometidas:** Una vulneración en un CI de proveedor no detectada donde un publicador sube dependencias fraudulentas en una minor version puede llegar a ser ignorada.

## Siguiente Fase (Roadmap)

1. **Parser Robusto para `package-lock.json v3`**
   - El ecosistema requiere control férreo de tipos para su validación de la propiedad "packages" y dependencias encadenadas. El parser no debe asumir propiedades JSON de versión `v3` sin verificaciones estrictas y seguras para su entorno en PowerShell.
2. **Reducción de Falsos Positivos**
   - Creación de colecciones de perfiles por defecto (trusted packages como tsc, webpack, etc.) integradas mediante módulos validados por la comunidad.
3. **Expansión: Extensión de Soporte (Futuro Modo Python)**
   - El mismo baseline seguro en operaciones, con soporte offline de reporte, será llevado a proyectos Python con manejo local de entorno como `uv` o `Poetry`.
