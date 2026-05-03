import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api_client.dart';

class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  List<Map<String, dynamic>> meetups = [];
  bool isLoading = true;
  String? error;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final res = await ApiClient.dio.get('/profile/my-meetups');
      final items = List<dynamic>.from(res.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      items.sort((a, b) => _parseDate(a['date_time']).compareTo(_parseDate(b['date_time'])));

      if (!mounted) return;
      setState(() {
        meetups = items;
        if (items.isNotEmpty) {
          final upcoming = items.where((m) => !_isPast(m)).toList();
          if (upcoming.isNotEmpty) {
            selectedDate = _dateOnly(_parseDate(upcoming.first['date_time']));
          }
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить встречи');
    } catch (_) {
      if (!mounted) return;
      setState(() => error = 'Не удалось загрузить встречи');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isPast(Map<String, dynamic> meetup) => _parseDate(meetup['date_time']).isBefore(DateTime.now());

  List<Map<String, dynamic>> get _upcomingMeetups => meetups.where((m) => !_isPast(m)).toList();

  List<Map<String, dynamic>> get _historyMeetups => meetups.where(_isPast).toList().reversed.toList();

  List<Map<String, dynamic>> get _selectedDayMeetups {
    final items = _upcomingMeetups.where((m) => _sameDay(_parseDate(m['date_time']), selectedDate)).toList();
    items.sort((a, b) => _parseDate(a['date_time']).compareTo(_parseDate(b['date_time'])));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои игры'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Календарь'),
              Tab(text: 'История'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: TabBarView(
                      children: [
                        _CalendarTab(
                          selectedDate: selectedDate,
                          upcomingMeetups: _upcomingMeetups,
                          selectedDayMeetups: _selectedDayMeetups,
                          onDateChanged: (value) {
                            setState(() => selectedDate = _dateOnly(value));
                          },
                        ),
                        _HistoryTab(historyMeetups: _historyMeetups),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> upcomingMeetups;
  final List<Map<String, dynamic>> selectedDayMeetups;
  final ValueChanged<DateTime> onDateChanged;

  const _CalendarTab({
    required this.selectedDate,
    required this.upcomingMeetups,
    required this.selectedDayMeetups,
    required this.onDateChanged,
  });

  bool _hasEventsOnDay(DateTime day) {
    return upcomingMeetups.any((meetup) {
      final date = DateTime.tryParse(meetup['date_time']?.toString() ?? '');
      return date != null && date.year == day.year && date.month == day.month && date.day == day.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2100),
              currentDate: DateTime.now(),
              onDateChanged: onDateChanged,
              selectableDayPredicate: (day) => _hasEventsOnDay(day) || _sameDay(day, selectedDate),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Запланированные встречи на ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (upcomingMeetups.isEmpty)
          const _EmptyState(
            icon: Icons.event_busy,
            title: 'Нет запланированных игр',
            subtitle: 'Когда вступишь или создашь новую встречу, она появится здесь.',
          )
        else if (selectedDayMeetups.isEmpty)
          const _EmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'На выбранную дату игр нет',
            subtitle: 'Выбери другую дату с активной встречей в календаре.',
          )
        else
          ...selectedDayMeetups.map((meetup) => _MeetupTile(meetup: meetup, isHistory: false)),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> historyMeetups;

  const _HistoryTab({required this.historyMeetups});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (historyMeetups.isEmpty)
          const _EmptyState(
            icon: Icons.history_toggle_off,
            title: 'История пока пустая',
            subtitle: 'После прошедших встреч здесь появятся посещённые игры.',
          )
        else
          ...historyMeetups.map((meetup) => _MeetupTile(meetup: meetup, isHistory: true)),
      ],
    );
  }
}

class _MeetupTile extends StatelessWidget {
  final Map<String, dynamic> meetup;
  final bool isHistory;

  const _MeetupTile({required this.meetup, required this.isHistory});

  @override
  Widget build(BuildContext context) {
    final game = meetup['game'] as Map<String, dynamic>?;
    final host = meetup['host'] as Map<String, dynamic>?;
    final rawDate = meetup['date_time']?.toString() ?? '';
    final date = DateTime.tryParse(rawDate);
    final formattedDate = date == null
        ? rawDate
        : '${DateFormat('dd.MM.yyyy').format(date)} в ${DateFormat('HH:mm').format(date)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          child: Icon(isHistory ? Icons.history : Icons.sports_esports),
        ),
        title: Text(game?['title']?.toString() ?? 'Игра'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formattedDate),
              const SizedBox(height: 4),
              Text(meetup['location']?.toString() ?? 'Локация не указана'),
              const SizedBox(height: 4),
              Text('Организатор: ${host?['nickname'] ?? '—'}'),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${meetup['current_participants'] ?? 0}/${meetup['max_participants'] ?? 0}'),
            const SizedBox(height: 4),
            Text(
              isHistory ? 'Посещено' : 'Запланировано',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 52),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
