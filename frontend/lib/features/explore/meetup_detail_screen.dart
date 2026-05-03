import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../chat/chat_screen.dart';

class MeetupDetailScreen extends StatefulWidget {
  final int meetupId;

  const MeetupDetailScreen({super.key, required this.meetupId});

  @override
  State<MeetupDetailScreen> createState() => _MeetupDetailScreenState();
}

class _MeetupDetailScreenState extends State<MeetupDetailScreen> {
  dynamic meetup;
  bool isLoading = true;
  bool isJoining = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final res = await ApiClient.dio.get('/meetups/${widget.meetupId}');
      setState(() => meetup = res.data);
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить встречу');
    } catch (_) {
      setState(() => error = 'Не удалось загрузить встречу');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _join() async {
    setState(() => isJoining = true);
    try {
      await ApiClient.dio.post('/participation/${widget.meetupId}/join');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы присоединились к встрече')),
      );
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'Не удалось присоединиться')),
      );
    } finally {
      if (mounted) {
        setState(() => isJoining = false);
      }
    }
  }

  Future<void> _leave() async {
    setState(() => isJoining = true);
    try {
      await ApiClient.dio.delete('/participation/${widget.meetupId}/leave');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из встречи')),
      );
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'Не удалось выйти')),
      );
    } finally {
      if (mounted) {
        setState(() => isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(error!)));
    }

    final game = meetup['game'] as Map<String, dynamic>?;
    final host = meetup['host'] as Map<String, dynamic>?;
    final count = meetup['current_participants'] ?? 0;
    final max = meetup['max_participants'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(game?['title']?.toString() ?? 'Встреча')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Организатор: ${host?['nickname'] ?? '—'}'),
            const SizedBox(height: 8),
            Text('Когда: ${meetup['date_time']}'),
            const SizedBox(height: 8),
            Text('Где: ${meetup['location']}'),
            const SizedBox(height: 8),
            Text('Участников: $count/$max'),
            const SizedBox(height: 8),
            Text('Статус: ${meetup['status']}'),
            const SizedBox(height: 16),
            Text(meetup['description']?.toString() ?? 'Без описания'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: isJoining ? null : _join,
                  child: isJoining
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Присоединиться'),
                ),
                OutlinedButton(
                  onPressed: isJoining ? null : _leave,
                  child: const Text('Покинуть'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        meetupId: widget.meetupId,
                        title: game?['title']?.toString() ?? 'Чат встречи',
                      ),
                    ),
                  ),
                  child: const Text('Открыть чат'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
