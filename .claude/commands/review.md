---
description: Revisa la calidad del código (rama de trabajo vs develop, o revisión general) — solo lectura, no modifica código
---

Analiza el código de la app **High Achiever** para asegurar calidad, prevenir deuda técnica y cumplir estándares de Google Play. Su alcance se adapta a la rama actual.

**IMPORTANTE — Solo lectura:** Este comando **analiza y reporta, NO modifica código**. Si quiero que apliques los arreglos, te lo pediré explícitamente tras ver el reporte.

Argumentos recibidos: `$ARGUMENTS`
- vacío → comportamiento automático según la rama (ver abajo).
- `<ruta>` → limitar la revisión a ese archivo/carpeta.
- `staged` → revisar solo los cambios en *staging* (`git diff --staged`).
- `<rama-base>` → comparar contra esa rama base en vez de la predeterminada.

## Protocolo

1. **Determinar la rama base y el diff:**
   - `git fetch` primero para no comparar contra una base desactualizada.
   - **Detectar la rama base de integración (NO asumir `main`):** en este repo es **`develop`**. Si existe `develop`, úsala como base; si no, cae a `main`. Si pasé una rama en `$ARGUMENTS`, usa esa.
   - `git branch --show-current` para saber la rama actual.
   - **Si estoy en la rama base (`develop`):** revisión general de toda la app (arquitectura, pantallas principales, estado global, componentes clave).
   - **Si estoy en una rama de trabajo:** auditar **solo los cambios de esta rama**:
     - Committeados: `git diff develop...HEAD` (tres puntos = *merge-base*; NO uses `git diff develop` sin puntos).
     - Sin commitear: incluir *staging*/*working tree* con `git status` y `git diff HEAD`.
   - Céntrate únicamente en ese diff, no en todo el código.

2. **Análisis automatizado (correr antes de la revisión manual):**
   - `flutter analyze` → errores y lints.
   - `dart format --output=none --set-exit-if-changed` sobre los archivos del diff → formato.
   - `flutter test` → si hay tests que cubran lo cambiado.
   - Reporta estos resultados antes del análisis a criterio.

3. **Buenas prácticas Flutter/Dart:**
   - Constructores `const` para optimizar rebuilds.
   - Manejo de estado (`Provider`): ¿rebuilds innecesarios?
   - *Memory leaks*: `Controllers`, `Timers`, `Listeners`, `StreamSubscriptions` con su `dispose()`/`cancel()`.
   - `BuildContext` tras un `await` (`use_build_context_synchronously`): `if (!mounted) return;`.
   - `setState()`/notificaciones tras `dispose`: chequear `mounted`.
   - Errores en async: `Future`s sin `try/catch`, excepciones no capturadas, `await` faltantes.
   - Listas largas con `Column`/`ListView` sin `.builder` ni límites.

4. **Estándares de Google Play:**
   - No bloquear comportamiento nativo (ej. botón atrás en Android) de forma incorrecta.
   - Sin operaciones pesadas en el hilo principal (riesgo de ANR).

5. **Reporte final (Markdown).** Cada hallazgo cita `archivo:línea`, severidad y fix concreto:
   - 🟢 **Lo Bueno**
   - 🟡 **Sugerencias / Deuda Técnica** (`archivo:línea` + propuesta)
   - 🔴 **Bugs / Bloqueos** (`archivo:línea` + por qué bloquea + fix sugerido)
   - 🚦 **Veredicto:** ¿Listo para merge a `develop`? (Sí/No) y qué falta.
