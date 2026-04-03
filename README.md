# Defendo

Defendo es un toolkit **Windows-first** para endurecer proyectos JavaScript/TypeScript frente a dependencias maliciosas, instalaciones inseguras y scripts de build no aprobados.

Su objetivo no es "prometer seguridad absoluta", sino **reducir superficie de ataque**, **hacer visible el riesgo** y **forzar hábitos seguros** en el ciclo de instalación y auditoría de dependencias.

## Qué hace

Defendo automatiza un baseline de seguridad para repos Node.js y frontends modernos:

- `init`: prepara el repositorio con configuración endurecida y documentación operativa.
- `doctor`: valida que el proyecto y el entorno tengan una base coherente.
- `install`: instala dependencias con políticas más estrictas y baseline de seguridad.
- `audit`: inspecciona `package.json`, lockfiles y `node_modules` para detectar hallazgos sospechosos.
- `ci`: ejecuta un gate fail-closed para integración continua.
- `verify-report`: verifica la firma/hash de informes de auditoría.

## Qué protege

Defendo está orientado a reducir riesgos habituales de supply chain en Node:

- ejecución inesperada de scripts de instalación
- dependencias demasiado recientes o potencialmente comprometidas
- dependencias exóticas desde git/tarballs/URLs no esperadas
- downgrades o cambios de procedencia no deseados
- patrones sospechosos en `node_modules` como `eval`, `Function`, `child_process`, peticiones de red, ofuscación o acceso agresivo a entorno/shell
- falta de pinning exacto de versiones

## Gestores soportados

Defendo detecta y endurece el gestor presente en el proyecto:

- **npm**
- **pnpm**
- **Yarn 4**

> Recomendación actual: para proyectos nuevos, pnpm ofrece la mejor superficie de controles nativos para edad mínima de releases, trust policy y aprobación explícita de builds.

## Estructura prevista

```text
.
├─ defendo.ps1
├─ src/
│  └─ Defendo.Win.psm1
├─ examples/
├─ docs/
└─ .github/
```

## Flujo recomendado

### 1. Inicializar un proyecto

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init --manager auto --with-ci-files
```

### 2. Comprobar baseline

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor
```

### 3. Auditar

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
```

### 4. Gate de CI

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 ci
```

## Artefactos que genera en cada repo

- `.defendo/config.json`
- `.defendo/reports/*`
- `.npmrc` o configuración equivalente del gestor detectado
- `AGENTS.md`
- `SECURITY-DEPENDENCIES.md`
- workflows opcionales de CI

## Filosofía

Defendo sigue una filosofía simple:

1. **fail-closed cuando importa**
2. **configuración explícita mejor que magia**
3. **allowlists pequeñas, revisables y versionables**
4. **no confiar en heurísticas sin evidencia**
5. **no vender el permission model de Node como frontera de seguridad completa**

## Estado actual

La línea actual de trabajo está centrada en:

- baseline Windows/PowerShell
- npm/pnpm/Yarn
- auditoría heurística de `node_modules`
- allowlists por paquete y por `paquete@versión`
- firma/hash de informes
- compatibilidad real con `Set-StrictMode -Version Latest`

## Próximos pasos

- mejorar el parser de `package-lock.json` v3 (`-AsHashtable`)
- añadir modo Python (`pip-tools` / `uv` / hashes)
- mejorar clasificación de toolchains legítimos para reducir falsos positivos
- endurecer CI y reporting

## Documentación

- [Arquitectura](docs/ARCHITECTURE.md)
- [Uso en Windows](docs/WINDOWS_USAGE.md)
- [Modelo de seguridad](docs/SECURITY_MODEL.md)
- [Guía para colaboradores/agentes](AGENTS.md)

## Licencia

Pendiente de definir.
