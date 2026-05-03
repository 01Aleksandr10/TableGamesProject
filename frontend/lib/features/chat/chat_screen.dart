import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';

class ChatScreen extends StatefulWidget {
  final int meetupId;
  final String title;

  const ChatScreen({super.key, required this.meetupId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.dio.get('/chat/${widget.meetupId}/messages');
      setState(() => messages = List<dynamic>.from(res.data as List));
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить сообщения');
    } catch (_) {
      setState(() => error = 'Не удалось загрузить сообщения');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => isSending = true);
    try {
      await ApiClient.dio.post('/chat/${widget.meetupId}/messages', data: {'text': text});
      _controller.clear();
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'Не удалось отправить сообщение')),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : messages.isEmpty
                        ? const Center(child: Text('Сообщений пока нет'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index] as Map<String, dynamic>;
                              return Card(
                                child: ListTile(
                                  title: Text(msg['sender_nickname']?.toString() ?? 'Игрок'),
                                  subtitle: Text(msg['text']?.toString() ?? ''),
                                  trailing: Text(msg['sent_at']?.toString().substring(11, 16) ?? ''),
                                ),
                              );
                            },
                          ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Введите сообщение'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isSending ? null : _send,
                    icon: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
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
