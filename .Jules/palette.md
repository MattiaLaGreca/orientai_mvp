## 2026-01-23 - Input Validation Feedback
**Learning:** Users may perceive the app as broken if a primary action button fails silently without feedback.
**Action:** Always provide inline validation errors or toast messages when preventing a form submission.

## 2026-01-24 - Frictionless Forms
**Learning:** Users expect forms to work seamlessly with password managers and keyboard navigation (Next/Done).
**Action:** Always wrap login/register forms in `AutofillGroup` and explicitly set `textInputAction` and `autofillHints` on inputs.

## 2026-01-25 - Frictionless Onboarding
**Learning:** Users expect the same frictionless keyboard navigation in onboarding as in login screens.
**Action:** Apply `textInputAction` (Next/Done) and `onSubmitted` handlers to all form sequences, not just authentication.

## 2026-01-26 - Contextual Loading
**Learning:** Replacing the entire screen with a loading spinner causes users to lose context of their action.
**Action:** Use a `Stack` with a `ModalBarrier` (or disabled buttons) to keep the form visible while blocking interaction during async operations.

## 2026-02-27 - Chat Input Experience
**Learning:** Default single-line text fields are frustrating for chat applications as they hide long messages horizontally.
**Action:** Configure chat inputs with `minLines: 1`, `maxLines: 4`, and `textCapitalization: TextCapitalization.sentences` to improve visibility and typing speed.

## 2026-03-05 - Chat Keyboard Dismissal
**Learning:** Users in chat applications expect to be able to read history by scrolling without manually closing the keyboard.
**Action:** Always set `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` on the chat `ListView` to allow intuitive dismissal.

## 2026-03-10 - Chat Input Controls
**Learning:** Users typing long prompts in chat interfaces need a quick way to clear text without holding backspace.
**Action:** Add a clear (X) button suffix to the chat input field that appears only when text is present.

## 2026-03-10 - Stream Performance in Inputs
**Learning:** Initializing streams inside `build` causes unnecessary restarts when keyboard state (setState) changes, causing UI jank.
**Action:** Always initialize `Stream` objects in `initState` to ensure input interactions (typing/clearing) remain 60fps smooth.

## 2026-03-22 - Chat Empty States
**Learning:** Users often experience "writer's block" when facing a blank chat screen without guidance.
**Action:** Provide contextual "suggestion chips" in the empty state to help users start the conversation with one tap.

## 2026-03-23 - Interactive Element Disabled States
**Learning:** Users can be confused when primary action buttons (like 'Send') appear active but do nothing because required conditions (like non-empty text) are unmet.
**Action:** Wrap related input controls in a single reactive listener (e.g., `ValueListenableBuilder`) to comprehensively disable and visually update (e.g., set to grey) both the action button and submission callbacks when input is empty.
