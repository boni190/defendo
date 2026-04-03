# Comandos

Este documento describe el comportamiento esperado de los comandos principales de Defendo.

## init

Prepara el baseline de seguridad del repositorio.

### Objetivos

- detectar el package manager
- escribir configuración endurecida
- generar documentación operativa local
- preparar el proyecto para auditoría y CI

### Efectos típicos

- crea `.defendo/config.json`
- escribe `.npmrc` o la configuración equivalente del gestor detectado
- genera `AGENTS.md`
- genera `SECURITY-DEPENDENCIES.md`
- puede añadir archivos de CI

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init --manager auto --with-ci-files
```

## doctor

Valida que el proyecto y el entorno local tienen una base coherente antes de instalar o auditar.

### Comprueba

- presencia de `package.json` cuando aplica
- coherencia del lockfile
- detección correcta del package manager
- baseline esperado del proyecto
- inconsistencias obvias de configuración

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor
```

## install

Instala dependencias usando el baseline endurecido del proyecto.

### Objetivos

- evitar instalaciones con configuración insegura por defecto
- respetar políticas del manager detectado
- dejar el árbol listo para una auditoría inmediata

### Notas

- no sustituye revisión humana
- no promete bloquear cualquier paquete malicioso
- debe usarse como ruta normal de instalación en el repo protegido

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 install
```

También puede usarse con una dependencia concreta:

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 install nombre-paquete@1.2.3
```

## audit

Realiza una auditoría heurística sobre manifiestos, lockfiles y `node_modules`.

### Tipos de hallazgo comunes

- `PKG-PINNING`
- `LOCK-PARSE`
- `MOD-NETWORK`
- `MOD-SHELL`
- `MOD-ENV`
- `MOD-OBFUSCATION`

### Salida esperada

- informe JSON en `.defendo/reports/`
- resumen por severidad
- evidencia revisable por ruta y categoría

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
```

## ci

Ejecuta el gate de CI en modo fail-closed según la política configurada.

### Objetivo

- bloquear promoción cuando aparezcan findings con severidad bloqueante
- mantener comportamiento reproducible en pipelines

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 ci
```

## verify-report

Verifica la integridad de un informe generado previamente.

### Qué valida

- hash SHA-256 del informe
- firma HMAC opcional si la política la usa

### Uso

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 verify-report --signature .\.defendo\reports\defendo-audit-YYYYMMDD_HHMMSS.sig.json
```

## Principio operativo

Los comandos deben funcionar correctamente en Windows y bajo `Set-StrictMode -Version Latest`. Cualquier cambio futuro debe preservar esa compatibilidad.
