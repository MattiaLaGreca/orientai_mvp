import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orientai/services/ai_service.dart';
import 'package:orientai/utils/ai_wrappers.dart';

// Mocks
class MockGenerativeModelWrapper extends Mock implements GenerativeModelWrapper {}
class MockChatSessionWrapper extends Mock implements ChatSessionWrapper {}
class MockGenerateContentResponseWrapper extends Mock implements GenerateContentResponseWrapper {}

void main() {
  late OrientAIService service;
  late MockGenerativeModelWrapper mockModel;
  late MockChatSessionWrapper mockChat;

  setUpAll(() {
    registerFallbackValue(Content.text(''));
  });

  setUp(() {
    service = OrientAIService();
    mockModel = MockGenerativeModelWrapper();
    mockChat = MockChatSessionWrapper();
  });

  group('OrientAIService Tests', () {
    test('init starts a chat session', () {
      // Arrange
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChat);

      // Act
      service.init('Mario', 'Details', false, modelOverride: mockModel);

      // Assert
      verify(() => mockModel.startChat(history: any(named: 'history'))).called(1);
    });

    test('sendMessage returns text from AI', () async {
      // Arrange
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChat);
      service.init('Mario', 'Details', false, modelOverride: mockModel);

      final mockResponse = MockGenerateContentResponseWrapper();
      when(() => mockResponse.text).thenReturn('Ciao Mario!');
      when(() => mockChat.sendMessage(any())).thenAnswer((_) async => mockResponse);

      // Act
      final result = await service.sendMessage('Ciao');

      // Assert
      expect(result, 'Ciao Mario!');
      verify(() => mockChat.sendMessage(any())).called(1);
    });

    test('sendMessage handles exceptions gracefully', () async {
      // Arrange
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChat);
      service.init('Mario', 'Details', false, modelOverride: mockModel);

      when(() => mockChat.sendMessage(any())).thenThrow(Exception('Network Error'));

      // Act
      final result = await service.sendMessage('Ciao');

      // Assert
      expect(result, contains('errore momentaneo'));
    });

    test('sendMessageWithStreaming accumulates text correctly', () async {
      // Arrange
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChat);
      service.init('Mario', 'Details', false, modelOverride: mockModel);

      final chunk1 = MockGenerateContentResponseWrapper();
      when(() => chunk1.text).thenReturn('Ciao ');
      final chunk2 = MockGenerateContentResponseWrapper();
      when(() => chunk2.text).thenReturn('Mondo!');

      when(() => mockChat.sendMessageStream(any()))
          .thenAnswer((_) => Stream.fromIterable([chunk1, chunk2]));

      // Act
      String partialAccumulator = '';
      final result = await service.sendMessageWithStreaming('Ciao', (partial) {
        partialAccumulator = partial;
      });

      // Assert
      expect(result, 'Ciao Mondo!');
      expect(partialAccumulator, 'Ciao Mondo!');
    });

    test('sendMessageWithStreaming handles exceptions gracefully', () async {
      // Arrange
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChat);
      service.init('Mario', 'Details', false, modelOverride: mockModel);

      when(() => mockChat.sendMessageStream(any())).thenThrow(Exception('Stream Error'));

      // Act
      String partialAccumulator = '';
      final result = await service.sendMessageWithStreaming('Ciao', (partial) {
        partialAccumulator = partial;
      });

      // Assert
      expect(result, contains('errore momentaneo'));
    });
  });
}
