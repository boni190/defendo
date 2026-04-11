# Migración de v5 a v6

Defendo v6 es una reescritura completa que unifica todo en un solo archivo PowerShell. Esta guía cubre los cambios y cómo migrar.

---

## Cambios principales

### Un solo archivo

**v5** usaba múltiples scripts y módulos:
```
defendo/
├── defendo.ps1
├── modules/
│   ├── audit.psm1
│   ├── install.psm1
│   └── doctor.psm1
├── hardening/
│   └── windows-hardening.ps1
└── config/
    └── ...
```

**v6** unifica todo en un archivo:
```
defendo/
└── defendo.ps1
```

### Cero dependencias

v5 requería módulos PowerShell externos y configuración previa. v6 no requiere nada más que PowerShell 7+ y el propio archivo.

### Hardening integrado

En v5, el hardening de Windows era un script separado (`windows-hardening.ps1`) que se ejecutaba independientemente. En v6, es un comando más:

```powershell
# v5 (antes)
pwsh -File hardening/windows-hardening.ps1 -Mode Gaming

# v6 (ahora)
pwsh -File defendo.ps1 windows --mode Gaming
```

### Gaming mode nativo

En v5, la compatibilidad con Vanguard requería configuración manual de exclusiones ASR y servicios. En v6, `--mode Gaming` lo maneja automáticamente.

---

## Guía de migración paso a paso

### 1. Respaldar configuración actual

```powershell
# Copiar config de v5 por si necesitas referencia
Copy-Item -Path ".defendo" -Destination ".defendo-v5-backup" -Recurse
```

### 2. Reemplazar archivos

```powershell
# Eliminar scripts antiguos
Remove-Item -Path "C:\Tools\defendo\*" -Recurse -Force

# Copiar v6
Copy-Item defendo.ps1 -Destination "C:\Tools\defendo\defendo.ps1"
```

### 3. Re-inicializar proyectos

```powershell
cd C:\dev\mi-proyecto

# Eliminar config v5
Remove-Item -Path ".defendo" -Recurse -Force

# Inicializar con v6
pwsh -File C:\Tools\defendo\defendo.ps1 init
```

### 4. Actualizar scripts CI

Si tenías scripts CI que llamaban a comandos v5, actualiza las invocaciones:

```yaml
# v5 (antes)
- run: pwsh -File defendo.ps1 audit --format json --output report.json

# v6 (ahora)
- run: pwsh -ExecutionPolicy Bypass -File defendo.ps1 ci
```

El comando `ci` es un alias de `audit` que retorna exit code 1 si hay findings bloqueantes.

### 5. Verificar hardening

Si habías aplicado hardening con v5, ejecuta una auditoría con v6 para verificar:

```powershell
pwsh -File defendo.ps1 windows --action Audit
```

---

## Mapeo de comandos v5 -> v6

| v5 | v6 | Notas |
|----|-----|-------|
| `defendo.ps1 init --with-ci-files` | `defendo.ps1 init` | CI files ya no se generan automáticamente |
| `defendo.ps1 audit --format json` | `defendo.ps1 audit` | Siempre genera JSON en `.defendo/reports/` |
| `defendo.ps1 verify-report` | *(eliminado)* | Los reportes se leen directamente del JSON |
| `defendo.ps1 install --safe` | `defendo.ps1 install` | Siempre instala con el baseline |
| `windows-hardening.ps1 -Mode Gaming` | `defendo.ps1 windows --mode Gaming` | Integrado como subcomando |
| `windows-hardening.ps1 -AuditOnly` | `defendo.ps1 windows --action Audit` | Flag renombrado |

---

## Opciones eliminadas

| Opción v5 | Razón |
|-----------|-------|
| `--with-ci-files` | Genera CI config manualmente según tu plataforma |
| `--format` | Siempre JSON, formato estandarizado |
| `--output` | Reportes siempre en `.defendo/reports/` con timestamp |
| `verify-report` | Lee el JSON directamente |
| `--safe` flag en install | Install siempre usa el baseline detectado |

---

## Configuración

La estructura de `.defendo/config.json` se mantiene compatible:

```json
{
  "version": "6.0.0",
  "manager": "npm",
  "policy": {
    "critical": "block",
    "high": "block",
    "medium": "warn",
    "low": "info"
  },
  "allowlist": []
}
```

Si tienes un `config.json` de v5 con campos adicionales, v6 los ignorará sin error.

---

## Troubleshooting

### "Ejecuta como Administrador"

El comando `windows` requiere elevación. Abre PowerShell 7 como Admin:
```powershell
Start-Process pwsh -Verb RunAs
```

### Vanguard no arranca tras hardening

Verifica que los servicios estén activos:
```powershell
Get-Service vgc, vgk | Format-Table Name, Status, StartType
```

Si están detenidos, re-ejecuta:
```powershell
pwsh -File defendo.ps1 windows --mode Gaming
```

### HVCI no se activa tras reinicio

Verifica soporte de hardware:
1. BIOS: Virtualization Technology = Enabled
2. BIOS: Secure Boot = Enabled
3. TPM 2.0 presente y activo

```powershell
# Verificar
pwsh -File defendo.ps1 windows --action Audit
```
