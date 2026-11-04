import '../entities/ai_reply.dart';
import '../repositories/ai_assistant_repository.dart';

class AskAiAssistant {
  const AskAiAssistant(this._repository);

  final AiAssistantRepository _repository;

  Future<AiReply> call(String question) {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw ArgumentError('Pertanyaan tidak boleh kosong.');
    }
    return _repository.ask(trimmedQuestion);
  }
}
