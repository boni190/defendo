# Defendo

Defendo es un toolkit **Windows-first** para endurecer proyectos Node.js y TypeScript frente a riesgos de supply chain, instalaciones inseguras y scripts de build no aprobados.

No promete seguridad absoluta. Su objetivo es **reducir superficie de ataque**, **hacer visible el riesgo** y **forzar hábitos seguros** en el ciclo de instalación y auditoría de dependencias.

## Qué hace

- prepara un baseline de seguridad por proyecto
- valida el entorno antes de instalar o auditar
- endurece flujos con npm, pnpm y Yarn
- audita `package.json`, lockfiles y `node_modules`
- aplica allowlists pequeñas y revisables
- genera reporting para revisión humana y CI

## Comandos principales

- `init`
- `doctor`
- `install`
- `audit`
- `ci`
- `verify-report`

## Quickstart

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init --manager auto --with-ci-files
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 ci
```

## Documentación Técnica

Para profundizar en el toolkit, revisa la documentación integrada en este repositorio:
- [Arquitectura y Diseño](./docs/ARCHITECTURE.md)
- [Referencia de Comandos](./docs/COMMANDS.md)
- [Configuración, Allowlists y Hallazgos](./docs/CONFIGURATION.md)
- [Limitaciones y Operabilidad](./docs/LIMITATIONS_AND_ROADMAP.md)
