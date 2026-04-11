# Install

## Windows
1. Copy `defendo.ps1` to `C:\Tools\defendo\defendo.ps1`.
2. Run `Unblock-File C:\Tools\defendo\defendo.ps1`.
3. Validate with `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 doctor`.

## Project Setup
1. Open the Node project directory.
2. Run `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 init --manager auto`.
3. Run `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 install`.
4. Run `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 audit`.

## Windows Hardening
- Gaming profile: `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 windows --mode Gaming`
- Workstation profile: `pwsh -ExecutionPolicy Bypass -File C:\Tools\defendo\defendo.ps1 windows --mode Workstation`

## Notes
- `audit` requires a lockfile for a clean result.
- Reports are written under `.defendo/reports/`.
