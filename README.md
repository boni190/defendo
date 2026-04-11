# Defendo v6.1.1

[![Windows](https://img.shields.io/badge/Windows-11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![Node](https://img.shields.io/badge/Node-18+-339933?logo=node.js)](https://nodejs.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Toolkit Windows-first para endurecer proyectos Node.js/TypeScript y Windows 11 sin romper gaming.**

Defendo reduce la superficie de ataque de supply chain, valida entornos, audita dependencias y endurece Windows 11 manteniendo compatibilidad total con Riot Vanguard y League of Legends.

> Validado en producción: Windows 11 25H2 (build 26200) + Node 24.14.1

---

## Quickstart

### 1. Hardening Windows (una vez por máquina)

```powershell
# Como Administrador
pwsh -ExecutionPolicy Bypass -File .\defendo.ps1 windows --mode Gaming
```

### 2. En tu proyecto Node.js

```powershell
cd mi-proyecto
pwsh -ExecutionPolicy Bypass -File .\defendo.ps1 init
pwsh -ExecutionPolicy Bypass -File .\defendo.ps1 doctor
pwsh -ExecutionPolicy Bypass -File .\defendo.ps1 audit
```

---

## Gaming Safe

| Característica | Estado |
|----------------|--------|
| Riot Vanguard | Funcional |
| HVCI / Memory Integrity | Activado |
| Credential Guard | Activado |
| Secure Boot | Verificado |
| League of Legends | Sin lag |

---

## Comandos

- `windows --mode Gaming` - Hardening Windows 11
- `init` - Inicializa proyecto Node
- `doctor` - Valida entorno
- `audit` - Audita dependencias
- `install` - Instala con baseline
- `ci` - Para pipelines

Ver [docs/COMMANDS.md](docs/COMMANDS.md) para detalles.

---

## Que hace

**Windows:**
- VBS, HVCI, Credential Guard
- LSA Protection
- 14 ASR rules (12 enforce, 2 audit)
- Firewall endurecido
- Deshabilita SMB1, Telnet, PowerShell v2

**Node.js:**
- .npmrc con save-exact=true
- Validación de lockfile
- Detección de versiones sin pin
- Scan heurístico node_modules

---

## Requisitos

- Windows 11 build 22000+
- PowerShell 7.0+
- Node.js 18+ (para proyectos)
- Permisos Admin (para windows)

---

## Migracion v5 a v6

Antes: 3 scripts separados
Ahora: `.\defendo.ps1 windows --mode Gaming`

---

## Licencia

MIT License

---

**Defendo v6.1.1** - Windows-first, gaming-safe, production-ready.
