import 'package:flutter/material.dart';
import 'explore/explore_screen.dart';
import 'my_games/my_games_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const ExploreScreen(),
    const MyGamesScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Лента"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Мои игры"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Чаты"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
        ],
      ),
    );
  }
}