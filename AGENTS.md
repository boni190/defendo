# AGENTS.md

Este repositorio contiene **Defendo**, un toolkit Windows-first para endurecer proyectos Node.js frente a riesgos de supply chain y automatizar un baseline de instalación/auditoría más seguro.

## Qué debe entender cualquier agente o colaborador

Defendo **no es** un simple wrapper de `npm install`.

Defendo combina:

- baseline de configuración endurecida
- validaciones previas del entorno/proyecto
- instalación controlada
- auditoría heurística de `package.json`, lockfiles y `node_modules`
- allowlists revisables
- reporting para CI

## Objetivo del proyecto

Reducir el riesgo de:

- paquetes maliciosos o comprometidos
- scripts inesperados de instalación/build
- dependencias exóticas no aprobadas
- downgrades o cambios de procedencia
- ofuscación, acceso a shell, child_process, red o lectura agresiva de entorno

## Principios de ingeniería

1. **Windows-first y PowerShell nativo**.
2. **Compatibilidad real con `Set-StrictMode -Version Latest`**.
3. **Nada de acceso optimista a propiedades opcionales de JSON**.
4. **Fail-closed en CI cuando el riesgo lo justifique**.
5. **No sobredocumentar capacidades inexistentes**.
6. **No vender falsa seguridad**.
7. **Toda excepción debe ser explícita, pequeña y revisable**.

## Reglas obligatorias para cambios

### Parser y datos

- No asumir que una propiedad existe en objetos deserializados desde JSON.
- Usar comprobaciones explícitas de propiedades con `PSObject.Properties['key']` cuando aplique.
- Evitar patrones frágiles que dependan de Member Access Enumeration bajo StrictMode.
- Tratar `package-lock.json` v3, `pnpm-lock.yaml` y `yarn.lock` como fuentes de verdad de distinta forma.

### Reporting

- Todo hallazgo debe incluir categoría, severidad, evidencia y ruta.
- La severidad debe ser razonable: no inflar findings por ruido de toolchain legítimo.
- Los informes firmados o con hash deben ser verificables.

### Allowlists

- Preferir allowlists por `paquete@versión` frente a allowlists amplias.
- Evitar `ignoredPackages` globales salvo toolchains muy conocidos y documentados.
- Toda excepción nueva debe quedar documentada en config o docs.

### Seguridad

- No presentar el Permission Model de Node como frontera de seguridad total.
- No desactivar protecciones para "hacerlo pasar".
- Cualquier reducción de severidad debe explicarse.

## Qué documentación mantener actualizada

Cada cambio relevante debe reflejarse en:

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/WINDOWS_USAGE.md`
- `docs/SECURITY_MODEL.md`

## Tareas prioritarias actuales

1. mejorar parser de `package-lock.json` v3 con `-AsHashtable`
2. reducir falsos positivos de toolchain legítimo
3. preparar modo Python para proyectos como Huellas
4. endurecer integración CI
5. añadir tests reales para regresiones de StrictMode

## Estilo de trabajo esperado

- cambios pequeños y verificables
- documentación junto al código
- mensajes de commit claros
- no introducir magia opaca
- no romper compatibilidad Windows para ganar elegancia teórica
