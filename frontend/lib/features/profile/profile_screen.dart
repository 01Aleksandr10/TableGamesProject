import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? error;

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
      final response = await ApiClient.dio.get('/profile/me');
      if (!mounted) return;
      setState(() => profile = Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => error = e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить профиль');
    } catch (_) {
      if (!mounted) return;
      setState(() => error = 'Не удалось загрузить профиль');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  int _buildReputation() {
    final id = (profile?['id'] as num?)?.toInt() ?? 1;
    return 50 + Random(id * 7919).nextInt(51);
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: _ProfileAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: const _ProfileAppBar(),
        body: Center(
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
        ),
      );
    }

    final nickname = profile?['nickname']?.toString().trim();
    final email = profile?['email']?.toString() ?? '';
    final displayName = (nickname == null || nickname.isEmpty) ? 'Пользователь' : nickname;
    final reputation = _buildReputation();
    final rating = (profile?['rating'] as num?)?.toDouble() ?? 5.0;

    return Scaffold(
      appBar: const _ProfileAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'П',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.badge_outlined,
              title: 'Имя',
              value: displayName,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.workspace_premium_outlined,
              title: 'Репутация',
              value: '$reputation',
              subtitle: 'Случайно сгенерированный показатель для MVP',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.star_border,
              title: 'Рейтинг',
              value: rating.toStringAsFixed(1),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Настройки'),
                    subtitle: const Text('Открыть окно настроек'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openSettings,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Выйти из аккаунта'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Профиль'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_none),
              title: Text('Уведомления'),
              subtitle: Text('Заглушка для MVP'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.palette_outlined),
              title: Text('Оформление'),
              subtitle: Text('Заглушка для MVP'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.security_outlined),
              title: Text('Приватность'),
              subtitle: Text('Заглушка для MVP'),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Это окно настроек уже открывается, но логика переключателей пока не реализована — как ты и просила.',
          ),
        ],
      ),
    );
  }
}
