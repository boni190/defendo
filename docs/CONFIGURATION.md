# Configuración

La configuración local de Defendo vive en `.defendo/config.json`.

Su propósito es controlar severidades, allowlists, excepciones específicas y política de CI.

## Filosofía

La configuración debe ser explícita, pequeña, revisable y versionable.

No conviene usar silencios globales amplios para ocultar ruido real.

## Qué puede incluir

- umbrales de severidad
- política de CI
- allowlists por paquete
- allowlists por paquete y versión
- findings ignorados de forma muy acotada

## Allowlists

### Reglas buenas

- preferir `paquete@versión` si el caso lo permite
- limitar por categoría si el hallazgo es muy específico
- documentar siempre el motivo

### Reglas malas

- ignorar paquetes globalmente sin revisión
- silenciar findings porque molestan
- usar regex demasiado amplias que oculten hallazgos futuros

## Findings y severidades

Defendo clasifica hallazgos por severidad para que CI pueda decidir qué bloquear.

### Critical

Indicio serio que debe bloquear promoción.

### High

Señal fuerte que requiere revisión antes de permitir merges o despliegue.

### Medium

Hallazgo relevante que puede requerir tuning, parser más robusto o revisión adicional.

### Low

Ruido conocido, contexto adicional o finding no bloqueante.

## Casos prácticos

### Toolchain frontend legítimo

En stacks como Vite o React puede aparecer ruido de ofuscación, shell o network en paquetes legítimos del toolchain. La forma correcta de tratarlo es con allowlists pequeñas y justificadas.

### Paquete sin nombre claro en node_modules

Si un hallazgo aparece como `<unknown>`, no debe silenciarse automáticamente. Primero hay que inspeccionar el archivo, la ruta y la evidencia.

## Política fail-closed

Recomendación práctica:

- bloquear en Critical
- bloquear en High
- revisar manualmente Medium
- no bloquear por Low

## Buenas prácticas Windows

Dentro de un entorno Windows conviene complementar Defendo con medidas del sistema cuando el contexto lo requiera. Defendo no sustituye esos controles; los complementa.
