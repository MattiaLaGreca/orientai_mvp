import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orientai/services/ai_service.dart';
import 'package:orientai/utils/ai_wrappers.dart';

class MockGenerativeModel extends Mock implements GenerativeModelWrapper {}
class MockChatSession extends Mock implements ChatSessionWrapper {}
class MockGenerateContentResponse extends Mock implements GenerateContentResponseWrapper {}

void main() {
  late OrientAIService aiService;
  late MockGenerativeModel mockModel;
  late MockChatSession mockChat;

  setUp(() {
    aiService = OrientAIService();
    mockModel = MockGenerativeModel();
    mockChat = MockChatSession();
    registerFallbackValue(Content.text(''));
  });

  group('OrientAIService Tests', () {
    test('sendMessage returns text from response', () async {
      // Init service with mocks
      aiService.init('Mario', 'Informatica', true, modelOverride: mockModel, chatOverride: mockChat);

      final mockResponse = MockGenerateContentResponse();
      when(() => mockResponse.text).thenReturn("Ciao Mario!");

      when(() => mockChat.sendMessage(any())).thenAnswer((_) async => mockResponse);

      final response = await aiService.sendMessage("Ciao");

      expect(response, "Ciao Mario!");
      verify(() => mockChat.sendMessage(any())).called(1);
    });

    test('sendMessage handles errors gracefully', () async {
       aiService.init('Mario', 'Informatica', true, modelOverride: mockModel, chatOverride: mockChat);

       when(() => mockChat.sendMessage(any())).thenThrow(Exception("Network Error"));

       final response = await aiService.sendMessage("Ciao");

       expect(response, "Si è verificato un errore momentaneo. Per favore riprova.");
    });
  });
}
