# Defendo

![Windows 11](https://img.shields.io/badge/Windows%2011-22000%2B-0078D4?logo=windows11&logoColor=white)
![PowerShell 7+](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Defendo-v6.0.0-blue)

**Toolkit Windows-first para endurecer Node.js y Windows 11 sin romper gaming.**

Defendo v6 unifica hardening de Windows 11, auditoría de dependencias Node.js, diagnóstico de entorno e instalación segura en un solo archivo PowerShell. Sin dependencias externas, sin módulos extra.

---

## Quickstart

```powershell
# 1. Hardening Windows (una vez, como Admin)
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 windows --mode Gaming

# 2. Inicializar proyecto Node.js
cd C:\dev\mi-proyecto
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init

# 3. Auditar dependencias
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
```

---

## Comandos

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `windows` | Hardening Windows 11 (VBS, HVCI, ASR, firewall) | `defendo.ps1 windows --mode Gaming` |
| `init` | Inicializa proyecto Node.js con baseline de seguridad | `defendo.ps1 init --manager pnpm` |
| `doctor` | Valida entorno: Node, package manager, HVCI, config | `defendo.ps1 doctor` |
| `audit` | Audita package.json, lockfile y node_modules | `defendo.ps1 audit` |
| `install` | Instala dependencias con el package manager detectado | `defendo.ps1 install express` |
| `ci` | Alias de audit para pipelines CI | `defendo.ps1 ci` |
| `version` | Muestra versión de Defendo | `defendo.ps1 version` |
| `help` | Muestra ayuda completa | `defendo.ps1 help` |

Ver [docs/COMMANDS.md](docs/COMMANDS.md) para referencia completa.

---

## Gaming Safe

Defendo fue diseñado para coexistir con **Riot Vanguard** (League of Legends, VALORANT) y otros anti-cheat que requieren seguridad a nivel kernel.

**Por qué funciona:**

- **VBS/HVCI activados**: Vanguard los requiere. Defendo los habilita, no los desactiva.
- **Credential Guard**: Protege credenciales en memoria. Compatible con Vanguard.
- **Servicios Vanguard protegidos**: En modo `Gaming`, Defendo asegura que `vgc` y `vgk` estén en inicio automático.
- **ASR en modo audit para reglas conflictivas**: Las 2 reglas ASR que pueden interferir con anti-cheat se aplican en modo audit (no bloqueo) cuando usas `--mode Gaming`.

```powershell
# Hardening completo compatible con gaming
pwsh -ExecutionPolicy Bypass -File defendo.ps1 windows --mode Gaming

# Verificar estado
pwsh -ExecutionPolicy Bypass -File defendo.ps1 windows --action Audit
```

Ver [docs/WINDOWS_HARDENING.md](docs/WINDOWS_HARDENING.md) para detalles técnicos.

---

## Modos de Hardening

| Modo | VBS/HVCI | ASR Completo | Vanguard | Uso |
|------|----------|-------------|----------|-----|
| `Gaming` | Sí | Audit en 2 reglas | Protegido | PC de gaming + desarrollo |
| `Workstation` | Sí | Bloqueo total | No aplica | Estación de trabajo |
| `Max` | Sí | Bloqueo total | No aplica | Máxima seguridad |

---

## Requisitos

- **Windows 11** build 22000 o superior
- **PowerShell 7+** (`pwsh`)
- **Administrador** para el comando `windows` (hardening del sistema)
- **Node.js** para comandos `init`, `doctor`, `audit`, `install`

---

## v5 vs v6

| Aspecto | v5 | v6 |
|---------|-----|-----|
| Archivos | Múltiples scripts + módulos | **Un solo archivo** `defendo.ps1` |
| Hardening Windows | Script separado | Integrado en `defendo.ps1 windows` |
| Dependencias | Requería módulos PowerShell | **Cero dependencias** |
| Instalación | Clonar repo + setup | Copiar un archivo |
| Gaming | Configuración manual | `--mode Gaming` automático |
| Auditoría | npm audit wrapper | Heurístico propio + análisis node_modules |

Ver [docs/MIGRATION_v5_to_v6.md](docs/MIGRATION_v5_to_v6.md) para guía de migración.

---

## Documentación

- [Referencia de Comandos](docs/COMMANDS.md)
- [Hardening Windows](docs/WINDOWS_HARDENING.md)
- [Migración v5 a v6](docs/MIGRATION_v5_to_v6.md)

---

## Licencia

[MIT](LICENSE)
