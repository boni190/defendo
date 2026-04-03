# Modelo de seguridad

Defendo reduce riesgo, pero no convierte un proyecto en invulnerable.

## Qué intenta mitigar

- paquetes maliciosos o comprometidos
- scripts inesperados durante instalación o build
- dependencias exóticas desde fuentes no habituales
- downgrades o cambios de procedencia
- señales sospechosas en node_modules como ofuscación, acceso a shell, red o entorno

## Cómo lo hace

- baseline endurecido por package manager
- verificación del proyecto y del entorno
- auditoría heurística de manifiestos, lockfiles y node_modules
- allowlists explícitas y versionables
- reporting para revisión humana y CI

## Qué no promete

- no garantiza seguridad total
- no sustituye revisión humana
- no elimina por sí solo todos los falsos positivos
- no convierte el permission model de Node en una frontera de seguridad completa

## Principios

1. minimizar superficie de ataque
2. preferir configuraciones explícitas
3. excepciones pequeñas y justificadas
4. fail-closed cuando el riesgo lo exige
5. no esconder hallazgos reales para reducir ruido

## Política de findings

- Critical y High deben revisarse antes de promover cambios
- Medium puede requerir tuning o mejora del parser
- Low informa de contexto o ruido conocido, pero no debe ignorarse sin criterio

## Filosofía de allowlists

La allowlist correcta es específica:

- mejor por paquete y versión
- mejor por categoría concreta
- mejor por regex de archivo muy acotada que por silencios globales

## Riesgos residuales

- toolchains modernos generan ruido legítimo
- los lockfiles complejos pueden requerir parsers más robustos
- algunos paquetes esconden comportamiento a través de código generado o empaquetado

Por eso Defendo debe verse como una capa práctica de reducción de riesgo, no como una promesa absoluta.
