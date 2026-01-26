import 'package:flutter_test/flutter_test.dart';
import 'package:orientai/utils/validators.dart';

void main() {
  group('Input Sanitization Security Tests', () {
    test('cleanMessage should trim whitespace', () {
      const input = '   Hello World   ';
      final result = Validators.cleanMessage(input);
      expect(result, 'Hello World');
    });

    test('cleanMessage should remove invisible control characters', () {
      // \x00 is null, \x1F is unit separator
      const input = 'Hello\x00World\x1F';
      final result = Validators.cleanMessage(input);
      expect(result, 'HelloWorld');
    });

    test('cleanMessage should preserve newlines and tabs', () {
      const input = 'Line 1\nLine 2\tTabbed';
      final result = Validators.cleanMessage(input);
      expect(result, 'Line 1\nLine 2\tTabbed');
    });

    test('cleanMessage should handle mixed inputs', () {
      const input = '  Start\n\x07End  '; // \x07 is bell
      final result = Validators.cleanMessage(input);
      expect(result, 'Start\nEnd');
    });

    test('cleanMessage should handle empty strings', () {
       expect(Validators.cleanMessage(''), '');
       expect(Validators.cleanMessage('   '), '');
    });
  });
}
