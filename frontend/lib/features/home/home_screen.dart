import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/auth/auth_scope.dart';
import 'package:fitflow/features/ai_workout/ai_workout_screen.dart';
import 'package:fitflow/features/community/community_view.dart';
import 'package:fitflow/features/home/dashboard_view.dart';
import 'package:fitflow/features/nutrition/nutrition_view.dart';
import 'package:fitflow/features/profile/profile_mock_data.dart';
import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_view.dart';
import 'package:fitflow/features/workout/workout_details_screen.dart';
import 'package:fitflow/features/workout/workout_list_view.dart';
import 'package:fitflow/features/workout/workout_mock_data.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.accountName});

  final String? accountName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late MemberProfile _profile = _profileForAccount(widget.accountName);
  ProfileSettings _settings = ProfileMockData.settings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: switch (_index) {
        0 => DashboardView(
          onProfileTap: () => setState(() => _index = 4),
          onStartWorkout: () =>
              openWorkoutDetails(context, WorkoutCatalog.fullBodyStrength),
          onViewRecommendation: () => openAiWorkout(context),
        ),
        1 => const WorkoutListView(),
        2 => const NutritionView(),
        3 => const CommunityView(),
        _ => ProfileView(
          initialProfile: _profile,
          initialSettings: _settings,
          onProfileChanged: (profile) => setState(() => _profile = profile),
          onSettingsChanged: (settings) => setState(() => _settings = settings),
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

MemberProfile _profileForAccount(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return ProfileMockData.jordan;
  return ProfileMockData.jordan.copyWith(
    name: trimmed,
    initials: initialsFor(trimmed),
  );
}

void openHome(BuildContext context) {
  final accountName = AuthScope.maybeOf(context)?.session?.user.name;
  Navigator.of(context).pushAndRemoveUntil<void>(
    fadePageRoute<void>(
      builder: (context) => HomeScreen(accountName: accountName),
    ),
    (route) => false,
  );
}
