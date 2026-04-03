# Arquitectura de Defendo

Defendo es un toolkit PowerShell con foco en Windows para endurecer proyectos JavaScript y TypeScript.

## Bloques principales

1. Detección del proyecto y del package manager
2. Generación de baseline y configuración
3. Instalación controlada
4. Auditoría heurística
5. Reporting y CI

## Componentes

### defendo.ps1

Es el punto de entrada del usuario y expone comandos como init, doctor, install, audit, ci y verify-report.

### src/Defendo.Win.psm1

Contiene la lógica principal del toolkit:

- detección de npm, pnpm y yarn
- lectura de package.json
- escritura de configuración endurecida
- validación del entorno
- escaneo de lockfiles
- escaneo heurístico de node_modules
- filtrado por allowlists
- generación de informes

## Flujo operativo

### init

Prepara el baseline de seguridad y genera configuración y documentación local.

### doctor

Valida que el entorno y el proyecto tienen una base coherente antes de instalar o auditar.

### install

Instala dependencias usando el baseline endurecido del proyecto.

### audit

Busca señales sospechosas en manifiestos, lockfiles y node_modules y produce un informe revisable.

### ci

Ejecuta el gate automatizado y falla cuando aparecen findings bloqueantes según la política configurada.

## Configuración

La configuración local vive en .defendo/config.json.

Puede incluir:

- umbrales por severidad
- allowlists por paquete
- allowlists por paquete y versión
- excepciones puntuales por categoría o ruta
- política de CI

## Requisitos de diseño

- compatibilidad real con StrictMode
- Windows-first
- excepciones explícitas y pequeñas
- no vender falsa seguridad

## Limitaciones actuales

- el parser de package-lock.json v3 todavía puede mejorarse
- el escaneo heurístico de toolchains modernos puede producir ruido
- el modo Python aún no está implementado
