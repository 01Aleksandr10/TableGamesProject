import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';

class CreateMeetupScreen extends StatefulWidget {
  const CreateMeetupScreen({super.key});

  @override
  State<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends State<CreateMeetupScreen> {
  final _location = TextEditingController(text: 'Москва, парк Горького');
  final _max = TextEditingController(text: '4');
  final _desc = TextEditingController();
  final _date = TextEditingController(text: DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 16));

  List<dynamic> games = [];
  int? selectedGameId;
  bool isLoading = true;
  bool isSaving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _location.dispose();
    _max.dispose();
    _desc.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      final res = await ApiClient.dio.get('/games');
      games = List<dynamic>.from(res.data as List);
      if (games.isNotEmpty) {
        selectedGameId = games.first['id'] as int;
      }
    } on DioException catch (e) {
      error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить список игр';
    } catch (_) {
      error = 'Не удалось загрузить список игр';
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _create() async {
    if (selectedGameId == null) return;
    setState(() => isSaving = true);
    try {
      await ApiClient.dio.post('/meetups', data: {
        'game_id': selectedGameId,
        'date_time': DateTime.parse(_date.text).toIso8601String(),
        'location': _location.text,
        'max_participants': int.tryParse(_max.text) ?? 4,
        'description': _desc.text,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'Не удалось создать встречу')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось создать встречу')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать встречу')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedGameId,
                        items: games
                            .map(
                              (game) => DropdownMenuItem<int>(
                                value: game['id'] as int,
                                child: Text(game['title'].toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => selectedGameId = value),
                        decoration: const InputDecoration(labelText: 'Игра'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _date,
                        decoration: const InputDecoration(labelText: 'Дата и время (YYYY-MM-DDTHH:MM)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _location,
                        decoration: const InputDecoration(labelText: 'Место / онлайн'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _max,
                        decoration: const InputDecoration(labelText: 'Макс. участников'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _desc,
                        decoration: const InputDecoration(labelText: 'Описание'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSaving ? null : _create,
                        child: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Создать встречу'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
