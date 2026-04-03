# Uso en Windows

## Instalación del toolkit

Ejemplo de despliegue local:

```powershell
New-Item -ItemType Directory -Force C:\Tools | Out-Null
Expand-Archive -LiteralPath .\Defendo.Win.v0.2.1.zip -DestinationPath C:\Tools -Force
Rename-Item C:\Tools\Defendo.Win.v0.2.1 C:\Tools\defendo
```

## Comandos básicos

### Inicializar un proyecto

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init --manager auto --with-ci-files
```

### Validar baseline

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor
```

### Instalar dependencias

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 install
```

### Auditar

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
```

### Ejecutar gate de CI

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 ci
```

## Artefactos por proyecto

Defendo suele generar:

- .defendo/config.json
- .defendo/reports
- .npmrc o configuración equivalente
- AGENTS.md
- SECURITY-DEPENDENCIES.md
- workflows de CI opcionales

## Recomendaciones

- ejecutar init una vez por repo
- ejecutar doctor antes de cambios grandes
- usar install en vez del install manual del gestor
- revisar findings High y Critical antes de permitir merges
- mantener allowlists pequeñas y revisables

## Nota práctica

En proyectos con frontend moderno puede aparecer ruido de toolchain. La forma correcta de tratarlo es ajustar allowlists con criterio, no desactivar el auditor entero.
