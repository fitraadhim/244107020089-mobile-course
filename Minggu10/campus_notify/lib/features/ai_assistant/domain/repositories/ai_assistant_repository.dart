import '../entities/ai_reply.dart';

abstract interface class AiAssistantRepository {
  Future<AiReply> ask(String question);
}
