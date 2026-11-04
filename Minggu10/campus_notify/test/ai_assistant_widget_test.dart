import 'package:campus_notify/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chat screen menampilkan panduan privasi awal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantPage()));

    expect(find.textContaining('Jangan kirim data pribadi'), findsOneWidget);
    expect(find.byTooltip('Kirim pertanyaan'), findsOneWidget);
  });
}
