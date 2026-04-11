# Windows Hardening

Defendo aplica hardening a Windows 11 mediante un conjunto de configuraciones de seguridad que se activan con el comando `windows`.

```powershell
pwsh -ExecutionPolicy Bypass -File defendo.ps1 windows --mode Gaming
```

---

## Qué hace cada componente

### 1. Punto de Restauración

Antes de cualquier cambio, Defendo crea un punto de restauración del sistema. Si algo sale mal, puedes revertir desde la configuración de Windows.

### 2. VBS (Virtualization-Based Security)

Habilita la seguridad basada en virtualización. Usa el hipervisor de Windows para crear regiones de memoria aisladas.

- **Registry**: `HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\EnableVirtualizationBasedSecurity = 1`
- **Plataforma**: Requiere UEFI + Secure Boot + TPM 2.0
- **Efecto**: Aísla procesos críticos del kernel en un contenedor seguro

### 3. HVCI (Hypervisor-Enforced Code Integrity)

Verifica que todo el código que se ejecuta en modo kernel esté firmado. Previene la carga de drivers maliciosos.

- **Registry**: `HKLM:\...\HypervisorEnforcedCodeIntegrity\Enabled = 1`
- **Requiere reinicio** para activarse completamente

### 4. Credential Guard

Aísla las credenciales (hashes NTLM, tickets Kerberos) en un contenedor VBS. Previene ataques pass-the-hash.

- **LsaCfgFlags = 1**: Habilita con bloqueo UEFI
- **RunAsPPL = 1**: LSA corre como Protected Process Light
- **RunAsPPLBoot = 1**: Protección activa desde el arranque

### 5. ASR (Attack Surface Reduction) Rules

Reglas de Microsoft Defender que bloquean vectores de ataque comunes:

| Regla | GUID | Acción |
|-------|------|--------|
| Bloquear contenido ejecutable de email | `be9ba2d9-53ea-4cdc-84e5-9b1eeee46550` | Bloquear |
| Bloquear ejecución de scripts ofuscados | `5beb7efe-fd9a-4556-801d-275e5ffc04cc` | Audit* |
| Bloquear procesos de Office creando hijos | `d4f940ab-401b-4efc-aadc-ad5f3c50688a` | Bloquear |
| Bloquear robo de credenciales de lsass.exe | `9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2` | Bloquear |
| Bloquear procesos no firmados desde USB | `b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4` | Bloquear |
| Bloquear abuso de drivers vulnerables | `56a863a9-875e-4185-98a7-b882c64b5ce5` | Bloquear |
| Bloquear persistencia vía WMI | `e6db77e5-3df2-4cf1-b95a-636979351e5b` | Bloquear |
| Bloquear llamadas API de Win32 desde macros | `92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b` | Bloquear |
| Bloquear ejecución desde apps de comunicación | `01443614-cd74-433a-b99e-2ecdc07bfc25` | Audit* |

**\*Modo Gaming**: Las reglas marcadas como "Audit" se ponen en modo observación para evitar interferencias con anti-cheat. En modos `Workstation` y `Max` se aplican en bloqueo.

### 6. Deshabilitación de Servicios y Features

- **SMB1Protocol**: Protocolo legacy con vulnerabilidades conocidas (EternalBlue)
- **TelnetClient**: Protocolo sin cifrado
- **RemoteRegistry**: Acceso remoto al registro de Windows
- **TeamViewer/SharedAccess**: Servicios de acceso remoto innecesarios

### 7. Firewall

Configura Windows Firewall en los tres perfiles (Domain, Private, Public):
- Inbound: **Block** por defecto
- Outbound: **Allow** por defecto

---

## Por qué no rompe Vanguard

Riot Vanguard (anti-cheat de League of Legends y VALORANT) **requiere** varias de las mismas tecnologías que Defendo activa:

1. **VBS/HVCI**: Vanguard verifica que estén activos. Defendo los habilita.
2. **TPM + Secure Boot**: Vanguard los valida. Defendo no los modifica (son hardware/firmware).
3. **Servicios `vgc` y `vgk`**: En modo Gaming, Defendo los configura en inicio automático y los inicia si están detenidos.
4. **ASR selectivo**: Las reglas que podrían interferir con la inyección legítima de Vanguard en procesos del juego se ponen en modo audit, no en bloqueo.

### Verificación post-hardening

```powershell
# Ejecutar auditoría (no requiere Admin)
pwsh -ExecutionPolicy Bypass -File defendo.ps1 windows --action Audit
```

La auditoría reporta:

| Campo | Valor esperado | Significado |
|-------|---------------|-------------|
| VBS Status | `2` | VBS corriendo |
| HVCI Running | `True` | Code integrity activa |
| Credential Guard | `True` | Credenciales aisladas |
| TPM Present | `True` | TPM detectado |
| SecureBoot | `True` | Arranque seguro |
| Vanguard vgc | `Running` | Servicio Vanguard activo |
| Vanguard vgk | `Running` | Driver Vanguard activo |
| Defender RealTime | `True` | Protección en tiempo real |

Si algún campo no muestra el valor esperado tras reiniciar, verifica que tu hardware soporte VBS (BIOS > Virtualization > Enabled).

---

## Acciones disponibles

| Acción | Qué ejecuta |
|--------|------------|
| `All` (default) | Hardening completo + auditoría |
| `Hardening` | Solo aplica cambios de seguridad |
| `Audit` | Solo genera reporte sin modificar nada |
| `PostHardening` | Deshabilita servicios innecesarios |

```powershell
# Solo auditar sin cambiar nada
pwsh -File defendo.ps1 windows --action Audit

# Solo hardening, sin post-hardening ni audit
pwsh -File defendo.ps1 windows --action Hardening --mode Gaming
```
