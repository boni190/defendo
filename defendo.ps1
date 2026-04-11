<#
.SYNOPSIS
Defendo v6 - Toolkit Windows-first unificado para Node.js + Hardening
.DESCRIPTION
Unifica: defendo.ps1 + hardening v5 + audit + doctor + install
Todo en un solo archivo, sin dependencias externas.

INSTALACIÓN:
  1. Copiar a C:\Tools\defendo\defendo.ps1
  2. Ejecutar desde cualquier proyecto

USO:
  # Hardening Windows (una vez por máquina)
  pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 windows --mode Gaming

  # En tu proyecto Node
  cd C:\dev\mi-proyecto
  pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init
  pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor
  pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit
#>
param(
    [Parameter(Position=0)][string]$Command = "help",
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest
$DefendoVersion = "6.1.1"
$DefendoRoot = $PSScriptRoot

function Write-Defendo {
    param([string]$Msg, [string]$Level="INFO")
    $color = switch($Level){ "OK" {"Green"} "WARN" {"Yellow"} "ERROR" {"Red"} default {"Gray"} }
    Write-Host "[$Level] $Msg" -ForegroundColor $color
}

function Get-Arg { param([string]$Name,[string]$Default=$null)
    for($i=0;$i -lt $Args.Count;$i++){
        if($Args[$i] -eq $Name -and $i+1 -lt $Args.Count){ return $Args[$i+1] }
        if($Args[$i] -like "$Name=*"){ return $Args[$i].Split("=",2)[1] }
    }
    return $Default
}
function Test-Arg { param([string]$Name); return $Args -contains $Name }

#region WINDOWS HARDENING
function Invoke-WindowsHardening {
    param([string]$Mode="Gaming", [string]$Action="All")
    
    function Test-Admin {
        $id=[Security.Principal.WindowsIdentity]::GetCurrent()
        $p=New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    if(-not (Test-Admin)){ throw "Ejecuta como Administrador" }
    
    $logDir = Join-Path $DefendoRoot "logs"
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $log = Join-Path $logDir "defendo-windows-$(Get-Date -Format yyyyMMdd_HHmmss).log"
    
    Write-Defendo "=== DEFENDO WINDOWS HARDENING Mode=$Mode ===" "OK"
    
    # 1. Restore point
    if($Action -in @("All","Hardening")){
        try {
            Enable-ComputerRestore -Drive $env:SystemDrive -ErrorAction SilentlyContinue | Out-Null
            Checkpoint-Computer -Description "Defendo-$Mode" -RestorePointType MODIFY_SETTINGS
            Write-Defendo "Punto de restauración creado" "OK"
        } catch { Write-Defendo "Restore point: $($_.Exception.Message)" "WARN" }
    }
    
    # 2. VBS/HVCI/Credential Guard (requerido por Vanguard)
    if($Action -in @("All","Hardening")){
        Write-Defendo "Configurando VBS/HVCI..."
        $keys = @(
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard";n="EnableVirtualizationBasedSecurity";v=1},
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard";n="RequirePlatformSecurityFeatures";v=3},
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity";n="Enabled";v=1},
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa";n="LsaCfgFlags";v=1},
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa";n="RunAsPPL";v=1},
            @{p="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa";n="RunAsPPLBoot";v=1}
        )
        foreach($k in $keys){
            if(-not (Test-Path $k.p)){ New-Item $k.p -Force | Out-Null }
            Set-ItemProperty -Path $k.p -Name $k.n -Value $k.v -Type DWord -Force
        }
        Write-Defendo "VBS/HVCI configurado (requiere reinicio)" "OK"
    }
    
    # 3. ASR Rules
    if($Action -in @("All","Hardening")){
        Write-Defendo "Aplicando ASR rules..."
        $asr = @{
            "56a863a9-875e-4185-98a7-b882c64b5ce5"=1; "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2"=1
            "d4f940ab-401b-4efc-aadc-ad5f3c50688a"=1; "3b576869-a4ec-4529-8536-b80a7769e899"=1
            "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84"=1; "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550"=1
            "d3e037e1-3eb8-44c8-a917-57927947596d"=1; "e6db77e5-3df2-4cf1-b95a-636979351e5b"=1
            "d1e49aac-8f56-4280-b9ba-993a6d77406c"=1; "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"=1
            "c1db55ab-c21a-4637-bb3f-a12568109d35"=1; "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b"=1
        }
        $auditVal = if($Mode -eq "Gaming"){2}else{1}
        $asr["5beb7efe-fd9a-4556-801d-275e5ffc04cc"]=$auditVal
        $asr["01443614-cd74-433a-b99e-2ecdc07bfc25"]=$auditVal
        
        try {
            Add-MpPreference -AttackSurfaceReductionRules_Ids $asr.Keys -AttackSurfaceReductionRules_Actions $asr.Values -ErrorAction Stop
            Write-Defendo "ASR aplicado" "OK"
        } catch { Write-Defendo "ASR: $($_.Exception.Message)" "WARN" }
    }
    
    # 4. Servicios y features
    if($Action -in @("All","Hardening")){
        foreach($f in @("SMB1Protocol","TelnetClient")){ 
            try { Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction Stop | Out-Null } catch {}
        }
        try { Set-Service RemoteRegistry -StartupType Disabled; Stop-Service RemoteRegistry -Force -ErrorAction SilentlyContinue } catch {}
        
        if($Mode -eq "Gaming"){
            foreach($s in @("vgc","vgk")){ 
                try { Set-Service $s -StartupType Automatic; Start-Service $s -ErrorAction SilentlyContinue } catch {}
            }
            Write-Defendo "Vanguard protegido" "OK"
        }
    }
    
    # 5. Firewall
    if($Action -in @("All","Hardening")){
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow
        Write-Defendo "Firewall configurado" "OK"
    }
    
    # 6. Post-hardening
    if($Action -in @("All","PostHardening")){
        foreach($s in @("TeamViewer","TVService","SharedAccess")){
            try { Stop-Service $s -Force -ErrorAction SilentlyContinue; Set-Service $s -StartupType Disabled } catch {}
        }
        Write-Defendo "Servicios innecesarios deshabilitados" "OK"
    }
    
    # 7. Audit
    if($Action -in @("All","Audit")){
        Write-Defendo "Generando auditoría..."
        $audit = @()
        $audit += "=== DEFENDO AUDIT $(Get-Date) ==="
        $audit += ""
        try {
            $dg = Get-CimInstance -Namespace root/Microsoft/Windows/DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop
            $audit += "VBS Status: $($dg.VirtualizationBasedSecurityStatus) (2=Running)"
            $audit += "HVCI Running: $($dg.SecurityServicesRunning -contains 2)"
            $audit += "Credential Guard: $($dg.SecurityServicesRunning -contains 1)"
        } catch { $audit += "VBS: No disponible" }
        $audit += ""
        try {
            $tpm = Get-Tpm
            $audit += "TPM: Present=$($tpm.TpmPresent) Ready=$($tpm.TpmReady)"
            $audit += "SecureBoot: $(Confirm-SecureBootUEFI)"
        } catch {}
        $audit += ""
        try {
            $vg = Get-Service vgc,vgk -ErrorAction Stop
            $audit += "Vanguard: $($vg | ForEach-Object { "$($_.Name)=$($_.Status)" })"
        } catch { $audit += "Vanguard: No instalado" }
        $audit += ""
        try {
            $mp = Get-MpComputerStatus
            $audit += "Defender: RealTime=$($mp.RealTimeProtectionEnabled) Tamper=$($mp.IsTamperProtected)"
        } catch {}
        
        $auditPath = Join-Path $logDir "windows-audit-$(Get-Date -Format yyyyMMdd_HHmmss).txt"
        $audit | Out-File $auditPath -Encoding UTF8
        Write-Defendo "Auditoría: $auditPath" "OK"
        $audit | ForEach-Object { Write-Host $_ }
    }
    
    Write-Defendo "=== COMPLETADO ===" "OK"
    Write-Host "`nReinicia para aplicar HVCI completamente." -ForegroundColor Yellow
}
#endregion

#region NODE.JS FUNCTIONS
function Initialize-Project {
    param($Manager="auto")
    $proj = Get-Location
    if(-not (Test-Path "package.json")){ Write-Defendo "No package.json en $proj" "ERROR"; return }
    
    Write-Defendo "Inicializando Defendo en $proj"
    $defendoDir = ".defendo"
    New-Item -ItemType Directory -Path $defendoDir -Force | Out-Null
    New-Item -ItemType Directory -Path "$defendoDir/reports" -Force | Out-Null
    
    # Detectar manager
    if($Manager -eq "auto"){
        if(Test-Path "pnpm-lock.yaml"){ $Manager="pnpm" }
        elseif(Test-Path "yarn.lock"){ $Manager="yarn" }
        else { $Manager="npm" }
    }
    Write-Defendo "Package manager: $Manager"
    
    # Config
    $config = @{
        version = $DefendoVersion
        manager = $Manager
        created = (Get-Date).ToString("o")
        policy = @{ critical="block"; high="block"; medium="warn"; low="info" }
        allowlist = @()
    }
    $config | ConvertTo-Json -Depth 4 | Out-File "$defendoDir/config.json" -Encoding UTF8
    
    # .npmrc endurecido
    if($Manager -eq "npm"){
        @"
audit-level=moderate
fund=false
save-exact=true
package-lock=true
"@ | Out-File ".npmrc" -Encoding ASCII -Append
    }
    
    # AGENTS.md
    @"
# Defendo Security Baseline

Este proyecto usa Defendo v$DefendoVersion para endurecer dependencias.

## Comandos
- `defendo doctor` - valida entorno
- `defendo audit` - audita dependencias
- `defendo install` - instala con baseline

## Política
- Critical/High: bloquean CI
- Medium: revisar
- Low: informativo
"@ | Out-File "AGENTS.md" -Encoding UTF8
    
    Write-Defendo "Proyecto inicializado" "OK"
}

function Invoke-Doctor {
    $proj = Get-Location
    Write-Defendo "Doctor: $proj"
    
    $checks = @()
    
    # Node
    try { $node = node --version; $checks += "[OK] Node $node" } catch { $checks += "[FAIL] Node no encontrado" }
    
    # Package manager
    $pm = "npm"
    if(Test-Path "pnpm-lock.yaml"){ $pm="pnpm" }
    elseif(Test-Path "yarn.lock"){ $pm="yarn" }
    $checks += "[OK] Manager: $pm"
    
    # package.json
    if(Test-Path "package.json"){ $checks += "[OK] package.json presente" } else { $checks += "[WARN] No package.json" }
    
    # Defendo config
    if(Test-Path ".defendo/config.json"){ 
        $checks += "[OK] Defendo configurado"
        try {
            $cfg = Get-Content ".defendo/config.json" | ConvertFrom-Json
            $checks += "[OK] Defendo v$($cfg.version)"
        } catch {}
    } else { $checks += "[WARN] Ejecuta 'defendo init'" }
    
    # Windows hardening (si aplica)
    try {
        $dg = Get-CimInstance -Namespace root/Microsoft/Windows/DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop
        if($dg.SecurityServicesRunning -contains 2){ $checks += "[OK] HVCI activo" } else { $checks += "[WARN] HVCI inactivo" }
        if($dg.SecurityServicesRunning -contains 1){ $checks += "[OK] Credential Guard activo" }
    } catch {}
    
    $checks | ForEach-Object { Write-Host $_ }
}

function Invoke-Audit {
    $proj = Get-Location
    Write-Defendo "Audit: $proj"
    
    if(-not (Test-Path "package.json")){ Write-Defendo "No package.json" "ERROR"; return }
    
    $reportDir = ".defendo/reports"
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $report = "$reportDir/defendo-audit-$ts.json"
    
    $findings = @()
    
    # 1. Check package.json
    $pkg = Get-Content "package.json" | ConvertFrom-Json
    if($pkg.PSObject.Properties.Name -contains "dependencies" -and $pkg.dependencies){
        foreach($dep in $pkg.dependencies.PSObject.Properties){
            if($dep.Value -match "[\^\~]"){ 
                $findings += @{ id="PKG-PINNING"; severity="Medium"; package=$dep.Name; version=$dep.Value; message="Usa rango, mejor pin exacto" }
            }
        }
    }
    if($pkg.PSObject.Properties.Name -contains "devDependencies" -and $pkg.devDependencies){
        foreach($dep in $pkg.devDependencies.PSObject.Properties){
            if($dep.Value -match "[\^\~]"){ 
                $findings += @{ id="PKG-PINNING-DEV"; severity="Low"; package=$dep.Name; version=$dep.Value; message="Dev dep con rango" }
            }
        }
    }
    
    # 2. Check lockfile
    $lockFile = $null
    if(Test-Path "package-lock.json"){ $lockFile="package-lock.json" }
    elseif(Test-Path "pnpm-lock.yaml"){ $lockFile="pnpm-lock.yaml" }
    
    if($lockFile){ $findings += @{ id="LOCK-PRESENT"; severity="Info"; message="Lockfile $lockFile encontrado" } }
    else { $findings += @{ id="LOCK-MISSING"; severity="High"; message="Sin lockfile" } }
    
    # 3. Scan node_modules (heurístico básico)
    if(Test-Path "node_modules"){
        $suspicious = Get-ChildItem "node_modules" -Recurse -File -Include *.js -ErrorAction SilentlyContinue | Select-Object -First 100 | Where-Object {
            $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            $content -match "eval\(|child_process|require\(['""]http" -and $_.Length -lt 50000
        } | Select-Object -First 5
        
        foreach($f in $suspicious){
            $findings += @{ id="MOD-SUSPICIOUS"; severity="Low"; file=$f.FullName.Replace($PWD,""); message="Patrón sospechoso" }
        }
    }
    
    $result = @{
        timestamp = (Get-Date).ToString("o")
        project = $proj.Path
        defendoVersion = $DefendoVersion
        findings = $findings
        summary = @{
            critical = @($findings | Where-Object severity -eq "Critical").Count
            high = @($findings | Where-Object severity -eq "High").Count
            medium = @($findings | Where-Object severity -eq "Medium").Count
            low = @($findings | Where-Object severity -eq "Low").Count
        }
    }
    
    $result | ConvertTo-Json -Depth 5 | Out-File $report -Encoding UTF8
    
    Write-Defendo "Findings: Critical=$($result.summary.critical) High=$($result.summary.high) Medium=$($result.summary.medium) Low=$($result.summary.low)" "OK"
    Write-Defendo "Reporte: $report" "OK"
    
    if($result.summary.critical -gt 0 -or $result.summary.high -gt 0){
        Write-Defendo "Bloqueantes encontrados" "WARN"
        exit 1
    }
}

function Invoke-Install {
    $pkgs = $Args
    $pm = "npm"
    if(Test-Path "pnpm-lock.yaml"){ $pm="pnpm" }
    elseif(Test-Path "yarn.lock"){ $pm="yarn" }
    
    Write-Defendo "Instalando con $pm..."
    if($pkgs.Count -gt 0){
        & $pm install $pkgs
    } else {
        & $pm install
    }
}
#endregion

#region MAIN
switch($Command.ToLower()){
    "windows" {
        $mode = Get-Arg "--mode" "Gaming"
        $action = Get-Arg "--action" "All"
        Invoke-WindowsHardening -Mode $mode -Action $action
    }
    "init" {
        $manager = Get-Arg "--manager" "auto"
        Initialize-Project -Manager $manager
    }
    "doctor" { Invoke-Doctor }
    "audit" { Invoke-Audit }
    "install" { Invoke-Install }
    "ci" { Invoke-Audit }
    "version" { Write-Host "Defendo v$DefendoVersion" }
    "help" {
        Write-Host @"
Defendo v$DefendoVersion - Toolkit Windows-first

COMANDOS:
  windows --mode Gaming|Workstation|Max [--action All|Hardening|Audit]
    Endurece Windows 11 (requiere Admin). Gaming mantiene Vanguard.

  init [--manager auto|npm|pnpm|yarn]
    Inicializa proyecto Node.js

  doctor
    Valida entorno

  audit
    Audita dependencias

  install [paquete...]
    Instala con baseline

EJEMPLOS:
  # Una vez por máquina
  pwsh -File defendo.ps1 windows --mode Gaming

  # Por proyecto
  cd mi-proyecto
  pwsh -File C:\Tools\defendo\defendo.ps1 init
  pwsh -File C:\Tools\defendo\defendo.ps1 audit
"@
    }
    default { Write-Defendo "Comando desconocido: $Command. Usa 'help'" "ERROR" }
}
#endregion
