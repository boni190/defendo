# Referencia de Comandos

Todos los comandos se ejecutan con:

```powershell
pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 <comando> [opciones]
```

---

## `windows`

Endurece Windows 11 aplicando VBS, HVCI, Credential Guard, ASR rules, configuración de firewall y deshabilitación de servicios inseguros.

**Requiere**: Administrador

```powershell
defendo.ps1 windows --mode Gaming
defendo.ps1 windows --mode Workstation
defendo.ps1 windows --mode Max
defendo.ps1 windows --mode Gaming --action Audit
defendo.ps1 windows --action Hardening
```

### Opciones

| Opción | Valores | Default | Descripción |
|--------|---------|---------|-------------|
| `--mode` | `Gaming`, `Workstation`, `Max` | `Gaming` | Perfil de hardening |
| `--action` | `All`, `Hardening`, `Audit`, `PostHardening` | `All` | Qué ejecutar |

### Modos

- **Gaming**: Protege servicios Vanguard (`vgc`, `vgk`). ASR conflictivas en audit. Ideal para PCs de gaming + desarrollo.
- **Workstation**: ASR completo en bloqueo. No gestiona Vanguard. Para estaciones de trabajo corporativas.
- **Max**: Máxima seguridad. Todas las reglas en bloqueo. Para entornos de alta seguridad.

### Acciones

- **All**: Ejecuta todo: restore point + hardening + post-hardening + audit.
- **Hardening**: Solo aplica VBS/HVCI/ASR/firewall. No genera reporte.
- **PostHardening**: Solo deshabilita servicios innecesarios (TeamViewer, SharedAccess).
- **Audit**: Solo genera reporte del estado actual sin modificar nada. No requiere Admin.

---

## `init`

Inicializa un proyecto Node.js con la configuración de seguridad de Defendo.

```powershell
cd C:\dev\mi-proyecto
defendo.ps1 init
defendo.ps1 init --manager pnpm
defendo.ps1 init --manager yarn
```

### Opciones

| Opción | Valores | Default | Descripción |
|--------|---------|---------|-------------|
| `--manager` | `auto`, `npm`, `pnpm`, `yarn` | `auto` | Package manager a usar |

### Qué crea

- `.defendo/config.json` - Configuración con políticas de severidad
- `.defendo/reports/` - Directorio para reportes de auditoría
- `.npmrc` endurecido (si usa npm): `audit-level=moderate`, `save-exact=true`, `package-lock=true`
- `AGENTS.md` - Guía de seguridad para agentes AI que trabajen en el proyecto

### Detección automática

Con `--manager auto` (default), detecta el package manager por lockfile:
1. `pnpm-lock.yaml` -> pnpm
2. `yarn.lock` -> yarn
3. Fallback -> npm

---

## `doctor`

Valida que el entorno esté correctamente configurado para trabajar con Defendo.

```powershell
defendo.ps1 doctor
```

### Checks que ejecuta

| Check | Qué valida |
|-------|-----------|
| Node.js | Que esté instalado y accesible |
| Package manager | Detecta npm/pnpm/yarn |
| package.json | Que exista en el directorio actual |
| Defendo config | Que `.defendo/config.json` exista (si no, sugiere `init`) |
| HVCI | Que esté activo (si DeviceGuard disponible) |
| Credential Guard | Que esté activo |

### Salida

```
[OK] Node v20.11.0
[OK] Manager: pnpm
[OK] package.json presente
[OK] Defendo configurado
[OK] HVCI activo
[OK] Credential Guard activo
```

---

## `audit`

Audita las dependencias del proyecto Node.js actual.

```powershell
defendo.ps1 audit
```

### Qué analiza

1. **package.json**: Detecta dependencias con rangos (`^`, `~`) en vez de versiones exactas.
2. **Lockfile**: Verifica que exista `package-lock.json` o `pnpm-lock.yaml`.
3. **node_modules**: Escaneo heurístico buscando patrones sospechosos (`eval()`, `child_process`, `require("http")`).

### Severidades

| Severidad | Política default | Efecto |
|-----------|-----------------|--------|
| Critical | `block` | Exit code 1, bloquea CI |
| High | `block` | Exit code 1, bloquea CI |
| Medium | `warn` | Warning, no bloquea |
| Low | `info` | Informativo |

### Reporte

Genera un JSON en `.defendo/reports/defendo-audit-<timestamp>.json` con:

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "project": "C:\\dev\\mi-proyecto",
  "defendoVersion": "6.0.0",
  "findings": [...],
  "summary": { "critical": 0, "high": 0, "medium": 2, "low": 1 }
}
```

---

## `install`

Instala dependencias usando el package manager detectado.

```powershell
defendo.ps1 install              # instala todo (npm/pnpm/yarn install)
defendo.ps1 install express      # instala paquete específico
defendo.ps1 install lodash axios # instala múltiples paquetes
```

Detecta el package manager por lockfile (igual que `init`).

---

## `ci`

Alias de `audit`. Diseñado para uso en pipelines CI/CD.

```powershell
defendo.ps1 ci
```

Retorna exit code 1 si hay findings Critical o High, permitiendo bloquear el pipeline.

---

## `version`

Muestra la versión de Defendo.

```powershell
defendo.ps1 version
# Output: Defendo v6.0.0
```

---

## `help`

Muestra el resumen de comandos y ejemplos.

```powershell
defendo.ps1 help
```
