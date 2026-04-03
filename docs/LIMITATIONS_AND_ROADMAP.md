# Limitaciones y roadmap

Defendo reduce riesgo, pero no convierte un proyecto en invulnerable.

## Limitaciones reales

### No es un sandbox total

Defendo no convierte el entorno Node en una frontera de seguridad hermética.

### El análisis es principalmente heurístico

La auditoría de `node_modules` busca señales sospechosas, pero no ejecuta un análisis dinámico completo ni puede resolver por sí sola todos los casos ambiguos.

### El factor humano sigue importando

Una allowlist demasiado amplia, una revisión superficial o una cuenta comprometida pueden anular parte del valor de la herramienta.

### El ruido existe

Los toolchains modernos pueden generar falsos positivos legítimos. La respuesta correcta es mejorar la clasificación y afinar allowlists, no desactivar el sistema entero.

## Roadmap prioritario

### 1. Parser robusto para `package-lock.json` v3

Objetivo:

- tratar correctamente esquemas actuales de npm
- manejar el root package y estructuras opcionales sin romper StrictMode
- reducir findings `LOCK-PARSE` que no representan riesgo real

### 2. Reducción de falsos positivos

Objetivo:

- mejorar clasificación de toolchains legítimos
- reducir ruido en frontends modernos
- mantener findings realmente accionables

### 3. Modo Python

Objetivo:

- extender la filosofía de Defendo a proyectos Python
- dar soporte a flujos con hashes y locking más estricto
- cubrir casos como `pip-tools` o `uv`

### 4. Tests de regresión

Objetivo:

- evitar regresiones bajo `Set-StrictMode -Version Latest`
- cubrir findings, allowlists y reporting
- mantener comportamiento reproducible en Windows

### 5. CI y reporting más fuertes

Objetivo:

- mejorar experiencia de gate en pipelines
- endurecer verificación de informes
- dejar más clara la trazabilidad de decisiones

## Dirección del proyecto

La dirección correcta para Defendo es seguir siendo práctico, explícito y Windows-first. No debe crecer a costa de introducir magia opaca o una falsa sensación de seguridad.
