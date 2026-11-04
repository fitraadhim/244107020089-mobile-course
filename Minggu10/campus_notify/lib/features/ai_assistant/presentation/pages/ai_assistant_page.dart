import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_assistant_providers.dart';

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final _questionController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSavingKey = false;

  @override
  void dispose() {
    _questionController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showMessage('API key tidak boleh kosong.');
      return;
    }

    setState(() => _isSavingKey = true);
    try {
      await ref.read(aiAssistantDataSourceProvider).saveApiKey(apiKey);
      if (!mounted) return;
      _apiKeyController.clear();
      _showMessage('API key tersimpan dengan aman.');
    } on ArgumentError catch (error) {
      if (mounted) {
        _showMessage(error.message?.toString() ?? 'API key tidak valid.');
      }
    } finally {
      if (mounted) setState(() => _isSavingKey = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _ask() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isLoading) return;

    _questionController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isLoading = true;
    });

    try {
      final reply = await ref.read(askAiAssistantProvider).call(question);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: reply.text,
            isUser: false,
            fromFallback: reply.fromFallback,
          ),
        );
      });
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          _ChatMessage(
            text: error.message?.toString() ?? 'Pertanyaan tidak valid.',
            isUser: false,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Assistant')),
      body: Column(
        children: [
          _ApiKeyPanel(
            controller: _apiKeyController,
            isSaving: _isSavingKey,
            onSave: _saveApiKey,
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Tanyakan informasi kampus.\n'
                      'Jangan kirim data pribadi atau rahasia.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _ask(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _ask,
                    icon: const Icon(Icons.send),
                    tooltip: 'Kirim pertanyaan',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiKeyPanel extends StatelessWidget {
  const _ApiKeyPanel({
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfigurasi API key Gemini',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Key disimpan di secure storage perangkat dan tidak ditampilkan.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Tempel API key di sini',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Simpan API key'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.fromFallback = false,
  });

  final String text;
  final bool isUser;
  final bool fromFallback;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final color = message.isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.text),
              if (message.fromFallback)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Mode offline',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
