## 2026-01-23 - Input Validation Feedback
**Learning:** Users may perceive the app as broken if a primary action button fails silently without feedback.
**Action:** Always provide inline validation errors or toast messages when preventing a form submission.

## 2026-01-24 - Frictionless Forms
**Learning:** Users expect forms to work seamlessly with password managers and keyboard navigation (Next/Done).
**Action:** Always wrap login/register forms in `AutofillGroup` and explicitly set `textInputAction` and `autofillHints` on inputs.
