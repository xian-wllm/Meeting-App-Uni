// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Screens
import '../screens/social/social_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/match-messagerie/match_screen.dart';
import '../screens/profile/profile_screen.dart';

// ========== NAVIGATION BOTTOM ========== //
class NavigationBottom extends StatefulWidget {
  const NavigationBottom({super.key});

  @override
  State<NavigationBottom> createState() => _NavigationBottomState();
}

class _NavigationBottomState extends State<NavigationBottom> {
  int _selectedIndex = 0;
  late Future<void> _pageLoadFutures;

  final List<Widget> _pages = [
    const HomePage(),
    const SocialPage(),
    const MessageriePage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageLoadFutures = _loadInitialPage();
  }

  Future<void> _loadInitialPage() async {
    await _loadPageData(_selectedIndex);
  }

  Future<void> _loadPageData(int index) async {
    if (_pages[index] is LazyLoadingPage) {
      await (_pages[index] as LazyLoadingPage).loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _pageLoadFutures,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: GNav(
                backgroundColor: Theme.of(context).colorScheme.background,
                color: Theme.of(context).colorScheme.onBackground,
                activeColor: Theme.of(context).colorScheme.primary,
                tabBackgroundColor: Theme.of(context).colorScheme.background,
                gap: 8,
                padding: const EdgeInsets.all(16),
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.people_alt,
                    text: 'Social',
                  ),
                  GButton(
                    icon: Icons.favorite,
                    text: 'Matches',
                  ),
                  GButton(
                    icon: Icons.calendar_month,
                    text: 'Calendar',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) async {
                  await _loadPageData(index);
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

abstract class LazyLoadingPage {
  Future<void> loadData();
}