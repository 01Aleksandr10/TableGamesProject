import 'package:flutter/material.dart';

import 'meetup_detail_screen.dart';

class MeetupCard extends StatelessWidget {
  final dynamic meetup;

  const MeetupCard({super.key, required this.meetup});

  Color getStatusColor() {
    final count = meetup['current_participants'] ?? 0;
    final max = meetup['max_participants'] ?? 6;
    if (count >= max) return Colors.red;
    if (count == max - 1) return Colors.orange;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final game = meetup['game'] as Map<String, dynamic>?;
    final host = meetup['host'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(game?['title']?.toString() ?? 'Игра'),
        subtitle: Text(
          '${meetup['date_time']}\n${meetup['location']}\nОрганизатор: ${host?['nickname'] ?? '—'}',
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getStatusColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${meetup['current_participants']}/${meetup['max_participants']}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetupDetailScreen(meetupId: meetup['id'] as int),
          ),
        ),
      ),
    );
  }
}
