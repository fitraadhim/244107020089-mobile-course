import 'package:campus_notify/features/ai_assistant/domain/entities/ai_reply.dart';
import 'package:campus_notify/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'package:campus_notify/features/ai_assistant/domain/usecases/ask_ai_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiRepository implements AiAssistantRepository {
  const _FakeAiRepository();

  @override
  Future<AiReply> ask(String question) async {
    return AiReply(text: 'Jawaban untuk $question', fromFallback: false);
  }
}

void main() {
  test('use case meneruskan pertanyaan yang valid ke repository', () async {
    final reply = await const AskAiAssistant(_FakeAiRepository())
        .call('Jadwal?');

    expect(reply.text, 'Jawaban untuk Jadwal?');
    expect(reply.fromFallback, isFalse);
  });

  test('use case menolak pertanyaan kosong sebelum memanggil API', () {
    expect(
      () => const AskAiAssistant(_FakeAiRepository()).call('  '),
      throwsArgumentError,
    );
  });
}
