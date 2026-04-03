# Configuración y Excepciones

Defendo sigue estrictamente una filosofía **Fail-Closed**. Todo lo que se desvia del baseline seguro será bloqueado y reportado como un "finding" hasta su comprobación y aprobación via un allowlist.

## Allowlists (`.defendo/config.json`)

Las allowlists permiten declarar excepciones para ciertos paquetes, evitando que un encontrar genere bloqueos (o falsos positivos conocidos).
Las excepciones se gestionan de dos maneras:
- `packages`: Confianza total en el paquete para todas sus versiones.
- `packageVersions`: Confianza parcial. Requiere `<nombre_paquete>@<versión_exacta>`. El uso de `packageVersions` es siempre recomendable.

**Importante:** Nunca asumas las propiedades como opcionales al hacer un bypass lógico si modificas el parseo de estos listados manualmente. La configuración JSON es validada de forma estricta.

```json
{
  "allowlists": {
    "lifecycle": {
      "packages": [],
      "packageVersions": ["esbuild@0.25.3"]
    },
    "network": {
      "packages": [],
      "packageVersions": ["sharp@0.34.1"]
    }
  }
}
```

## Findings y Severidades

En los reportes de auditoría, las alertas (`findings`) se clasifican en:
- **Low**: Recomendaciones operativas (ejemplo de dependencias anticuadas sin parches CVE aparentes en DB loca).
- **Medium**: Permisos de lectura anómalos o peticiones de red sospechosas pero no críticas.
- **High / Critical**: Invocaciones a shell de comandos, binarios ofuscados o intentos de sobreescribir permisos en los lifecycle hooks (e.g. `postinstall`). Suponen **bloqueo inmediato** en el CI.

*Regla Operativa:* **No silencies hallazgos reales para reducir ruido**. Investiga la alerta. Si el paquete requiere dicho acceso para operar con normalidad (como `esbuild` en sus builds C++), añádelo explícitamente a un allowlist de esa versión concreta.
