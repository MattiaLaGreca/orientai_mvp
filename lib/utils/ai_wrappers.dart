import 'package:google_generative_ai/google_generative_ai.dart';

/// Wrapper astratto per GenerativeModel per facilitare il testing (mocking)
abstract class GenerativeModelWrapper {
  ChatSessionWrapper startChat({List<Content>? history});
}

/// Wrapper astratto per ChatSession
abstract class ChatSessionWrapper {
  Future<GenerateContentResponseWrapper> sendMessage(Content content);
  Stream<GenerateContentResponseWrapper> sendMessageStream(Content content);
}

/// Wrapper astratto per la risposta
abstract class GenerateContentResponseWrapper {
  String? get text;
}

/// Implementazione reale che delega a GenerativeModel
class RealGenerativeModel implements GenerativeModelWrapper {
  final GenerativeModel _model;
  RealGenerativeModel(this._model);

  @override
  ChatSessionWrapper startChat({List<Content>? history}) {
    return RealChatSession(_model.startChat(history: history));
  }
}

/// Implementazione reale che delega a ChatSession
class RealChatSession implements ChatSessionWrapper {
  final ChatSession _chat;
  RealChatSession(this._chat);

  @override
  Future<GenerateContentResponseWrapper> sendMessage(Content content) async {
    final response = await _chat.sendMessage(content);
    return RealGenerateContentResponse(response);
  }

  @override
  Stream<GenerateContentResponseWrapper> sendMessageStream(Content content) async* {
    await for (final chunk in _chat.sendMessageStream(content)) {
      yield RealGenerateContentResponse(chunk);
    }
  }
}

/// Implementazione reale della risposta
class RealGenerateContentResponse implements GenerateContentResponseWrapper {
  final GenerateContentResponse _response;
  RealGenerateContentResponse(this._response);

  @override
  String? get text => _response.text;
}
