---
description: Documenta en el vault de Obsidian lo que se hizo en el update (crea o actualiza notas)
---

Al finalizar un cambio/feature/fix en la app **High Achiever**, documenta lo que se hizo en el vault de Obsidian: crea notas nuevas o actualiza las existentes según corresponda. La documentación de Obsidian captura el **por qué** y el **cómo funciona** (lo que el código no dice); **nunca duplica el código**.

Si el usuario pasó argumentos, úsalos como pista del alcance a documentar: $ARGUMENTS

## Ubicación del vault
`/Users/kaolof/Documents/Obsidian Vault/High achiever/`

## Estructura del vault (respetarla siempre)
- `High Achiever — MOC.md` → índice central. Enlaza a todo. Tiene una tabla de **Estado de features**.
- `High Achiever — Arquitectura y Flujos.md` → diagramas Mermaid (capas, flujos, secuencias).
- `Areas/` → una nota por feature viva (ej. `Timer (Pomodoro).md`, `Daily Goals.md`, `Notifications & Sounds.md`, `Flip Mode.md`).
- `Decisiones/` → el *por qué* de una decisión técnica + sus trade-offs.
- `Conceptos/` → técnicas reutilizables (ej. reconciliación con epoch, detección de giro).
- `Ideas/` → `Backlog de ideas.md` y demás ideas/pendientes.
- `Diario/` → una entrada por día (`YYYY-MM-DD.md`), copiada de `_Template diario.md`.

## Convenciones (obligatorias)
- Notas en **español**, con frontmatter (`tags`, fechas en formato `YYYY-MM-DD` y **absolutas**, nunca "ayer/hoy").
- Conectar notas con `[[wikilinks]]`. Nunca dejar links rotos: si enlazas algo que no existe, créalo.
- Toda nota relevante arranca con un callout `> [!summary] TL;DR`.
- Las rutas a código se escriben como `` [`archivo.dart`](lib/ruta/archivo.dart) `` (relativas a la raíz del repo).

## Protocolo

1. **Identificar qué se hizo.** Determina el alcance del cambio recién finalizado. Si hay rama de trabajo, básate en `git diff main...HEAD` (archivos/líneas modificados); si no, en lo que se acaba de implementar en la conversación. Resume en 1-2 frases qué cambió y por qué.

2. **Decidir qué notas tocar (crear vs actualizar).** Antes de crear nada, **lista el contenido del vault** y revisa las notas existentes para evitar duplicados.
   - ¿Afecta una **feature existente**? → actualiza su nota en `Areas/`.
   - ¿Es una **feature nueva**? → crea nota en `Areas/` + agrega fila en la tabla de Estado de la MOC.
   - ¿Se tomó una **decisión técnica** (elegir un paquete, un enfoque, un trade-off)? → crea/actualiza nota en `Decisiones/`.
   - ¿Se introdujo una **técnica reutilizable**? → crea/actualiza nota en `Conceptos/`.
   - ¿Cambió un **flujo o la arquitectura**? → actualiza los diagramas Mermaid en `High Achiever — Arquitectura y Flujos.md`.
   - ¿Quedaron **pendientes/ideas/bugs conocidos**? → anótalos en `Ideas/Backlog de ideas.md`.

3. **Aplicar los cambios.**
   - Al **actualizar**: modifica solo lo necesario, actualiza el campo `actualizado:` del frontmatter a la fecha de hoy (absoluta) y mantén el resto intacto.
   - Al **crear**: usa el frontmatter y estructura de las notas hermanas de esa carpeta. Enlázala desde la MOC y desde las notas relacionadas.
   - Mantén la **coherencia de wikilinks** en ambos sentidos.

4. **Entrada de diario (opcional).** Si el cambio lo amerita, crea/actualiza `Diario/YYYY-MM-DD.md` (a partir de `_Template diario.md`) con: qué se hizo, decisiones tomadas (con `[[wikilinks]]`), problemas/dudas y próximos pasos. Si no está claro si conviene, pregunta.

5. **NO documentar lo que ya vive en el repo.** No copies la lista de features (está en README), ni la estructura de carpetas, ni el historial de commits, ni cómo correr la app. Captura solo lo **no obvio** (el por qué, el contexto, el trade-off).

6. **Reporte final.** Entrega un resumen en Markdown de:
   - 📝 **Notas creadas** (con su ruta).
   - ✏️ **Notas actualizadas** (con qué cambió en cada una).
   - 🔗 **Enlaces nuevos** agregados para mantener el grafo conectado.
   - ❓ **Dudas/decisiones** que necesiten confirmación del usuario.