## 2026-03-20 - [Fire-and-Forget Pattern in Dart]
**Learning:** Removing `await` from non-critical blocking calls (like stats logging or timestamp updates) significantly improves perceived latency. However, to satisfy linter rules (`unawaited_futures`), use `.ignore()` (Dart 2.15+) or `unawaited(...)` from `dart:async`. Crucially, ensure the unawaited future handles its own exceptions internally to avoid unhandled async errors.
**Action:** When optimizing blocking chains, look for side-effects that don't influence the return value and can be safely unawaited. Always verify internal error handling of the unawaited function.

## 2026-03-20 - [Optimizing Redundant AI Calls]
**Learning:** In conversational AI apps, "summarization" on initialization is expensive (latency + tokens). If the user hasn't sent new messages since the last session, the previous summary is still valid. Detecting this state (empty new messages list) allows skipping the API call entirely.
**Action:** Always check if the "delta" of new data is empty before triggering expensive re-processing or AI summarization steps. Reuse cached/stored results whenever possible.
## 2026-03-24 - [Regex Compilation in Hot Paths]
**Learning:** Input validation methods (sanitization/security) are called frequently. Inline `RegExp` instantiation causes unnecessary recompilation overhead.
**Action:** Always extract `RegExp` to `static final` constants in utility classes like `Validators`.
