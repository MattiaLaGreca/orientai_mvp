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
}
