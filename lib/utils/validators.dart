class Validators {
  // 🔒 Sentinel Security Check: Stricter Regex for Input Validation
  // Allows alphanumeric, dots, underscores, percents, plus, minus. Requires domain and TLD.
  // Disallows consecutive dots in domain.
  static final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');
}
