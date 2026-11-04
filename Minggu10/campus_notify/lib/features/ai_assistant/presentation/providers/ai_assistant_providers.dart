import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ai_assistant_datasource.dart';
import '../../data/repositories/ai_assistant_repository_impl.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/usecases/ask_ai_assistant.dart';

final aiAssistantDataSourceProvider = Provider<AiAssistantDataSource>((ref) {
  return AiAssistantDataSource(client: Dio());
});

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepositoryImpl(ref.watch(aiAssistantDataSourceProvider));
});

final askAiAssistantProvider = Provider<AskAiAssistant>((ref) {
  return AskAiAssistant(ref.watch(aiAssistantRepositoryProvider));
});
