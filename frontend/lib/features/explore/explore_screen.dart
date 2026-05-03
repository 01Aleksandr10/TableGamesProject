import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'create_meetup_screen.dart';
import 'meetup_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(exploreProvider.notifier).loadMeetups());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Лента встреч')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMeetupScreen()),
          );
          if (!mounted) return;
          await ref.read(exploreProvider.notifier).loadMeetups();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(exploreProvider.notifier).loadMeetups(),
        child: state.isLoading && state.meetups.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 300),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : state.error != null && state.meetups.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 200),
                      Center(child: Text(state.error!)),
                    ],
                  )
                : ListView.builder(
                    itemCount: state.meetups.length,
                    itemBuilder: (context, i) => MeetupCard(meetup: state.meetups[i]),
                  ),
      ),
    );
  }
}
