## 2024-05-23 - Persistent Error Storage Risk
**Vulnerability:** Service exceptions were being returned directly to the UI and subsequently saved to Firestore as chat messages.
**Learning:** In this architecture, the chat history acts as a permanent log of what the "AI" said. If the AI service fails and returns an error string, that error becomes part of the permanent record. This elevates a transient information leak (displaying an error) to a persistent one (storing the stack trace in the DB).
**Prevention:** Enforce strict "boundary sanitization" for any service that feeds data into a persistent store. Never return raw exception strings from service layers.

## 2024-05-24 - API Key Leak via Exception Logs
**Vulnerability:** Raw exception logging (`print(e)`) in the service layer could potentially expose sensitive API Keys if the exception message (e.g., from an HTTP client) includes the request URL or headers.
**Learning:** Standard exception strings are not safe for production logs when handling sensitive third-party integrations.
**Prevention:** Implement a dedicated secure logging wrapper (`_logSecurely`) that explicitly sanitizes/redacts known secrets from error messages before outputting them.
