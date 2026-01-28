class Validators {
  // 🔒 Sentinel Security Check: Stricter Regex for Input Validation
  // Allows alphanumeric, dots, underscores, percents, plus, minus. Requires domain and TLD.
  // Disallows consecutive dots in domain.
  static final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');

  /// 🔒 Sentinel Security: Sanitizes user input
  /// Trims whitespace and removes invisible control characters (0x00-0x1F)
  /// except standard whitespace (newline \n, tab \t, carriage return \r).
  static String cleanMessage(String input) {
    // 1. Trim whitespace
    var output = input.trim();

    // 2. Remove non-printable control characters.
    // We want to KEEP: \t (0x09), \n (0x0A), \r (0x0D).
    // So we remove 0x00-0x08, 0x0B-0x0C, 0x0E-0x1F, and 0x7F (DEL)
    output = output.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    return output;
  }

  /// 🔒 Sentinel Security: Validates Name
  /// - Max length: 50
  /// - No control characters (incl. newlines) to prevent Prompt Injection
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Inserisci il nome";
    if (value.length > 50) return "Nome troppo lungo (max 50 caratteri)";
    // Disallow ALL control characters including \n, \r, \t
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(value)) {
      return "Il nome non può contenere caratteri speciali o 'a capo'";
    }
    return null;
  }

  /// 🔒 Sentinel Security: Validates Interests
  /// - Max length: 500
  static String? validateInterests(String? value) {
    if (value == null || value.trim().isEmpty) return "Inserisci i tuoi interessi";
    if (value.length > 500) return "Testo troppo lungo (max 500 caratteri)";
    return null;
  }

  /// 🔒 Sentinel Security: Sanitizes input for Prompt Context
  /// Removes all control characters (including newlines and tabs) to prevent Prompt Injection via header manipulation.
  static String sanitizeForPrompt(String input) {
    // Remove all control characters including \n, \r, \t (0x00-0x1F and 0x7F)
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
  }
}
