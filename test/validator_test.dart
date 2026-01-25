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
}
