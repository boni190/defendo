# Arquitectura y Diseño de Defendo

Defendo está diseñado con una arquitectura específica para entornos Windows y scripts de PowerShell. Se apoya fuertemente en un modelo de políticas cerradas para proveer seguridad heurística.

## Enfoque Windows-First

Defendo es nativo de PowerShell, requiriendo `pwsh` y operando bajo directrices modernas.
- **Compatibilidad estricta**: Todo el código se diseña para ser compatible con `Set-StrictMode -Version Latest`, lo que significa que no se toleran variables no inicializadas ni propiedades inexistentes, garantizando una ejecución robusta y predecible.
- **Integración con el SO**: Al funcionar desde Windows y PowerShell, su diseño se beneficia de herramientas de compresión locales, integración con CI de entornos Microsoft, y capacidades criptográficas directamente accesibles vía comandos nativos o librerías de .NET incluidas.

## Modelo de Seguridad y Supply Chain

Defendo intercepta los flujos de trabajo habituales. En lugar de un wrapper inseguro, actúa como una puerta (gatekeeper).
1. **Pre-validación**: Escanea y audita los lockfiles y el estado real del disco (`node_modules`) *antes* de continuar.
2. **Filosofía Fail-closed**: Cualquier dependencia que trate de compilar builds no estandarizados, conectar a repositorios fuera de la allowlist, o utilizar lifecycle scripts sospechosos (postinstall, etc.) bloqueará la instalación hasta que reciba luz verde manual.
3. **Escaneo de Disco vs Lockfile**: Compara lo que dice el package manager (el lockfile) con lo que existe en el disco (`node_modules/` o `.pnpm/`), permitiendo encontrar dependencias mutadas de forma persistente.
4. **Verificabilidad Criptográfica**: Todos los reportes (de ci, audit) van firmados con `SHA256` o `HMAC` (vía `DEFENDO_REPORT_KEY`), previniendo un encubrimiento de las alertas inyectando reportes limpios.
