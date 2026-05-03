import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> meetups = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.dio.get('/profile/my-meetups');
      setState(() => meetups = List<dynamic>.from(res.data as List));
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить чаты');
    } catch (_) {
      setState(() => error = 'Не удалось загрузить чаты');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Чаты')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : meetups.isEmpty
                  ? const Center(child: Text('Пока нет ваших встреч'))
                  : ListView.builder(
                      itemCount: meetups.length,
                      itemBuilder: (context, index) {
                        final meetup = meetups[index] as Map<String, dynamic>;
                        final game = meetup['game'] as Map<String, dynamic>?;
                        return ListTile(
                          title: Text(game?['title']?.toString() ?? 'Чат встречи'),
                          subtitle: Text(meetup['location']?.toString() ?? ''),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                meetupId: meetup['id'] as int,
                                title: game?['title']?.toString() ?? 'Чат встречи',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
