# Referencia de Comandos

Defendo utiliza un script principal `defendo.ps1` que rige la ejecución a través de submódulos. Cada comando tiene un propósito claro.

## `init`

**Uso:** `pwsh defendo.ps1 init [--manager <npm|pnpm|yarn|auto>] [--with-ci-files]`

Prepara un proyecto inyectando el baseline de seguridad de Defendo. 
- Inicializa el directorio local `.defendo` de configuraciones.
- Crea el fichero `.defendo/config.json` inicial.
- Establece la configuración por defecto para detectar de forma temprana ejecuciones inseguras.

## `doctor`

**Uso:** `pwsh defendo.ps1 doctor`

Ejecuta diagnósticos iniciales sobre el entorno para evaluar si es apto para instalaciones seguras.
- Verifica versiones mínimas de Node.js, `npm`/`pnpm`/`yarn`.
- Comprueba políticas de ejecución de scripts de PowerShell para el entorno.

## `install`

**Uso:** `pwsh defendo.ps1 install [paquete@version]`

Intermedia el proceso de instalación nativo.
- Audita primero el estado actual y el árbol a instalar.
- Si no hay alertas de seguridad en los `lifecycle scripts` o dependencias no admitidas, delega al gestor la instalación.

## `audit`

**Uso:** `pwsh defendo.ps1 audit`

El nucleo analítico del toolkit offline. Escanea, analiza y produce recomendaciones.
- Genera un reporte JSON y Markdown (dentro de `.defendo/reports/`).
- Firmará criptográficamente ambos reportes.

## `ci`

**Uso:** `pwsh defendo.ps1 ci`

Adaptación silenciosa y binaria (`Exit-Code`) pensada para pipelines.
- Funciona integramente en modo *fail-closed*. 
- Un simple "finding" de severidad alta romperá la build a no ser que se documente en los *allowlists*.
- No muestra prompts interactivos.

## `verify-report`

**Uso:** `pwsh defendo.ps1 verify-report --signature <ruta_al_sig_json>`

Validación pura. Usa las firmas almacenadas, o claves HMAC (`DEFENDO_REPORT_KEY`), para garantizar que un `defendo-audit-**.json` no ha sido mutado tras su generación.
