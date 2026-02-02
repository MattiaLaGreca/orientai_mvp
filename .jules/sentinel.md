## 2024-05-23 - Persistent Error Storage Risk
**Vulnerability:** Service exceptions were being returned directly to the UI and subsequently saved to Firestore as chat messages.
**Learning:** In this architecture, the chat history acts as a permanent log of what the "AI" said. If the AI service fails and returns an error string, that error becomes part of the permanent record. This elevates a transient information leak (displaying an error) to a persistent one (storing the stack trace in the DB).
**Prevention:** Enforce strict "boundary sanitization" for any service that feeds data into a persistent store. Never return raw exception strings from service layers.

## 2024-05-24 - API Key Leak via Exception Logs
**Vulnerability:** Raw exception logging (`print(e)`) in the service layer could potentially expose sensitive API Keys if the exception message (e.g., from an HTTP client) includes the request URL or headers.
**Learning:** Standard exception strings are not safe for production logs when handling sensitive third-party integrations.
**Prevention:** Implement a dedicated secure logging wrapper (`_logSecurely`) that explicitly sanitizes/redacts known secrets from error messages before outputting them.

## 2024-05-25 - Centralized Input Validation Pattern
**Vulnerability:** Ad-hoc regex validation in UI widgets led to inconsistent security rules and made it impossible to unit test the validation logic accurately (testing the string copy instead of the code).
**Learning:** Security logic (validators, sanitizers) must be decoupled from UI components. Embedding regex strings in widgets makes them hard to test and maintain.
**Prevention:** Extract all validation logic into a shared `lib/utils/validators.dart` module. This ensures the UI and the Tests rely on the exact same source of truth.

## 2026-02-28 - Prompt Injection via User Profile
**Vulnerability:** The AI System Instruction interpolated user data (`$studentName`) directly. A malicious user could inject newlines and fake instructions into their name to override the AI's persona.
**Learning:** Even simple profile fields like "Name" are attack vectors in LLM applications if they are injected into the system prompt.
**Prevention:** Strictly validate inputs destined for Prompt Context. Forbid control characters (newlines, tabs) in short-text fields to prevent instruction boundary hopping.

## 2026-03-01 - System Instruction Injection
**Vulnerability:** The AI System Instruction interpolated user data () directly. A malicious user could inject newlines and fake instructions into their name to override the AI's persona (Prompt Injection).
**Learning:** Even simple profile fields like "Name" are attack vectors in LLM applications if they are injected into the system prompt structure without sanitization.
**Prevention:** Strictly validate and sanitize inputs destined for Prompt Context. Remove control characters (newlines, tabs) to prevent instruction boundary hopping.

## 2026-05-24 - Indirect Prompt Injection via Chat History
**Vulnerability:** Chat history content containing newlines could manipulate the summarizer's system prompt context, potentially allowing users to spoof roles or inject instructions into the summary generation process.
**Learning:** Data from the database (chat history), even if originated from the user previously, must be treated as untrusted when re-contextualized into a new prompt. Structure-preserving characters like newlines are dangerous in flat-text prompts.
**Prevention:** Flatten and sanitize all user/model content before injecting it into meta-prompts like summarization. Used `Validators.sanitizeForPrompt` to strip control characters.
