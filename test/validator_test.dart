import 'package:flutter_test/flutter_test.dart';
import 'package:orientai/utils/validators.dart';

void main() {
  // Use the shared validator to ensure we test the actual app logic
  final emailRegex = Validators.emailRegex;

  group('Email Validator Security Tests', () {
    test('Valid emails should pass', () {
      expect(emailRegex.hasMatch('test@example.com'), true);
      expect(emailRegex.hasMatch('john.doe@sub.domain.co.uk'), true);
      expect(emailRegex.hasMatch('user+tag@gmail.com'), true);
      expect(emailRegex.hasMatch('123@numbers.com'), true);
      expect(emailRegex.hasMatch('u_s-e.r@domain.org'), true);
    });

    test('Invalid emails should fail', () {
      expect(emailRegex.hasMatch('plainaddress'), false, reason: 'No @ symbol');
      expect(emailRegex.hasMatch('@example.com'), false, reason: 'Missing local part');
      expect(emailRegex.hasMatch('test@'), false, reason: 'Missing domain');
      expect(emailRegex.hasMatch('test@.com'), false, reason: 'Domain starts with dot');
      expect(emailRegex.hasMatch('test@domain.'), false, reason: 'Domain ends with dot');
      expect(emailRegex.hasMatch('test@domain'), false, reason: 'Missing TLD');
      expect(emailRegex.hasMatch('test@domain.a'), false, reason: 'TLD too short');
      expect(emailRegex.hasMatch('test@domain..com'), false, reason: 'Double dot in domain');
    });

    test('Injection attempts should fail (basic)', () {
      // Basic check that we don't allow spaces or obviously bad chars that might indicate injection attempts in some contexts
      expect(emailRegex.hasMatch('test@exa mple.com'), false);
      expect(emailRegex.hasMatch('test@example.com<script>'), false);
      expect(emailRegex.hasMatch('test@example.com; DROP TABLE'), false);
    });
  });

  group('Name Validator Security Tests', () {
    test('Valid names should pass', () {
      expect(Validators.validateName('Mario'), null);
      expect(Validators.validateName('Maria Rossi'), null);
      expect(Validators.validateName('O\'Connor'), null);
    });

    test('Empty name should fail', () {
      expect(Validators.validateName(''), "Inserisci il nome");
      expect(Validators.validateName('  '), "Inserisci il nome");
      expect(Validators.validateName(null), "Inserisci il nome");
    });

    test('Long name should fail', () {
      final longName = 'A' * 51;
      expect(Validators.validateName(longName), "Nome troppo lungo (max 50 caratteri)");
    });

    test('Injection attempts (Newlines/Tabs) should fail', () {
      // Prompt Injection prevention
      expect(Validators.validateName('Mario\nRossi'), "Il nome non può contenere caratteri speciali o 'a capo'");
      expect(Validators.validateName('Mario\tRossi'), "Il nome non può contenere caratteri speciali o 'a capo'");
      expect(Validators.validateName('Sentinel\rAdmin'), "Il nome non può contenere caratteri speciali o 'a capo'");
    });
  });

  group('Interests Validator Security Tests', () {
    test('Valid interests should pass', () {
      expect(Validators.validateInterests('Amo la matematica e la fisica.'), null);
    });

    test('Empty interests should fail', () {
      expect(Validators.validateInterests(''), "Inserisci i tuoi interessi");
      expect(Validators.validateInterests(null), "Inserisci i tuoi interessi");
    });

    test('Very long interests should fail', () {
      final longText = 'A' * 501;
      expect(Validators.validateInterests(longText), "Testo troppo lungo (max 500 caratteri)");
    });
  });

  group('Prompt Sanitization Security Tests', () {
    test('Should replace newlines and tabs with spaces', () {
      const input = "Line1\nLine2\tTabbed\rReturn";
      final output = Validators.sanitizeForPrompt(input);
      // Expect "Line1 Line2 Tabbed Return" (normalized spaces)
      expect(output, "Line1 Line2 Tabbed Return");
    });

    test('Should remove other control characters', () {
      const input = "Test\x00Null\x1BEscape";
      final output = Validators.sanitizeForPrompt(input);
      expect(output, "Test Null Escape");
    });

    test('Should preserve safe characters', () {
      const input = "Mario Rossi, 123! @Test.";
      final output = Validators.sanitizeForPrompt(input);
      expect(output, input);
    });

    test('Should trim result', () {
      const input = "  Mario  \n";
      final output = Validators.sanitizeForPrompt(input);
      expect(output, "Mario");
    });
  });

  group('URL Security Tests', () {
    test('Safe URLs should pass', () {
      expect(Validators.isSafeUrl('http://example.com'), true);
      expect(Validators.isSafeUrl('https://secure.site.org/page?query=1'), true);
      expect(Validators.isSafeUrl('HTTPS://UPPERCASE.COM'), true);
    });

    test('Unsafe URLs should fail', () {
      expect(Validators.isSafeUrl('javascript:alert(1)'), false);
      expect(Validators.isSafeUrl('file:///etc/passwd'), false);
      expect(Validators.isSafeUrl('data:text/html,<script>'), false);
      expect(Validators.isSafeUrl('ftp://server.com'), false); // Only http/s allowed
    });

    test('Malformed/Empty URLs should fail', () {
      expect(Validators.isSafeUrl(''), false);
      expect(Validators.isSafeUrl(null), false);
      expect(Validators.isSafeUrl('justtext'), false);
      expect(Validators.isSafeUrl('www.google.com'), false, reason: 'Missing scheme');
    });
  });
}
