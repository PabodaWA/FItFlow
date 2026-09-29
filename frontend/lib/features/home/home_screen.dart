import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/home/dashboard_view.dart';
import 'package:fitflow/features/home/placeholder_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _openPlaceholder({
    required String title,
    required String message,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      fadePageRoute<void>(
        builder: (context) => PlaceholderScreen(
          title: title,
          message: message,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: switch (_index) {
        0 => DashboardView(
          onProfileTap: () => setState(() => _index = 4),
          onStartWorkout: () => _openPlaceholder(
            title: 'Full Body Strength',
            message: 'This workout will be available soon.',
            icon: Icons.fitness_center,
          ),
          onViewRecommendation: () => _openPlaceholder(
            title: 'AI Coach',
            message: 'Your recommendation will be available soon.',
            icon: Icons.auto_awesome,
          ),
        ),
        1 => const PlaceholderTab(
          title: 'Workouts',
          message: 'Workout plans will show up here.',
          icon: Icons.fitness_center,
        ),
        2 => const PlaceholderTab(
          title: 'Nutrition',
          message: 'Nutrition tracking will show up here.',
          icon: Icons.restaurant_outlined,
        ),
        3 => const PlaceholderTab(
          title: 'Community',
          message: 'Community features will show up here.',
          icon: Icons.groups_outlined,
        ),
        _ => const PlaceholderTab(
          title: 'Profile',
          message: 'Your profile will show up here.',
          icon: Icons.person_outline,
        ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

void openHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil<void>(
    fadePageRoute<void>(builder: (context) => const HomeScreen()),
    (route) => false,
  );
}
