import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/auth/auth_scope.dart';
import 'package:fitflow/features/auth/login_screen.dart';
import 'package:fitflow/features/profile/achievements_screen.dart';
import 'package:fitflow/features/profile/edit_profile_screen.dart';
import 'package:fitflow/features/profile/goals_screen.dart';
import 'package:fitflow/features/profile/profile_mock_data.dart';
import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_widgets.dart';
import 'package:fitflow/features/profile/settings_screen.dart';
import 'package:fitflow/features/progress/progress_screen.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    this.initialProfile,
    this.initialSettings,
    this.onProfileChanged,
    this.onSettingsChanged,
  });

  /// Local profile shown before an account backend is connected.
  final MemberProfile? initialProfile;
  final ProfileSettings? initialSettings;
  final ValueChanged<MemberProfile>? onProfileChanged;
  final ValueChanged<ProfileSettings>? onSettingsChanged;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late MemberProfile _profile;
  late ProfileSettings _settings;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile ?? ProfileMockData.jordan;
    _settings = widget.initialSettings ?? ProfileMockData.settings;
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.of(context).push<MemberProfile>(
      fadePageRoute<MemberProfile>(
        builder: (context) => EditProfileScreen(profile: _profile),
      ),
    );
    if (!mounted || updated == null) return;
    setState(() => _profile = updated);
    widget.onProfileChanged?.call(updated);
  }

  Future<void> _openGoals() async {
    final goal = await Navigator.of(context).push<FitnessGoal>(
      fadePageRoute<FitnessGoal>(
        builder: (context) => GoalsScreen(
          goals: ProfileMockData.goals,
          currentGoal: _profile.goal,
        ),
      ),
    );
    if (!mounted || goal == null) return;
    final updated = _profile.copyWith(goal: goal);
    setState(() => _profile = updated);
    widget.onProfileChanged?.call(updated);
  }

  void _openAchievements() {
    Navigator.of(context).push(
      fadePageRoute<void>(
        builder: (context) => const AchievementsScreen(
          achievements: ProfileMockData.achievements,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    final settings = await Navigator.of(context).push<ProfileSettings>(
      fadePageRoute<ProfileSettings>(
        builder: (context) => SettingsScreen(settings: _settings),
      ),
    );
    if (!mounted || settings == null) return;
    setState(() => _settings = settings);
    widget.onSettingsChanged?.call(settings);
  }

  void _openProgress() {
    Navigator.of(context).push(
      fadePageRoute<void>(
        builder: (context) =>
            ProgressScreen(useMetricUnits: _settings.useMetricUnits),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'You can sign in again anytime to pick up your training.',
          ),
          actions: [
            TextButton(
              key: const Key('cancel-logout'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm-logout'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) return;
    await AuthScope.maybeOf(context)?.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil<void>(
      fadePageRoute<void>(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('profile-list'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your training summary.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                _IdentityCard(profile: _profile),
                const SizedBox(height: 12),
                _StatsRow(profile: _profile),
                const SizedBox(height: 16),
                _ProgressLink(onTap: _openProgress),
                const SizedBox(height: 28),
                const ProfileSectionTitle('Account'),
                const SizedBox(height: 12),
                _AccountMenu(
                  onEdit: _editProfile,
                  onGoals: _openGoals,
                  onAchievements: _openAchievements,
                  onSettings: _openSettings,
                  onLogout: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B7F4E), Color(0xFF124E32)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProfileAvatar(
              key: const Key('profile-image'),
              initials: profile.initials,
              color: profile.avatarColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    key: const Key('profile-name'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        profile.goal.label,
                        key: const Key('profile-goal'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFFD7F5E4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatTile(
            valueKey: const Key('profile-streak'),
            value: formatStatCount(profile.streakDays),
            label: 'Current streak',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFE25B2A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            valueKey: const Key('profile-workouts'),
            value: formatStatCount(profile.workoutsCompleted),
            label: 'Workouts completed',
            icon: Icons.fitness_center,
            color: const Color(0xFF1B7F4E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            valueKey: const Key('profile-calories'),
            value: formatStatCount(profile.caloriesBurned),
            label: 'Calories burned',
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFB86E00),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.valueKey,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final Key valueKey;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    final labelLineHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle?.fontSize ?? 12) *
        (labelStyle?.height ?? 1.2);

    return DecoratedBox(
      decoration: profileCardDecoration(colorScheme, radius: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                key: valueKey,
                maxLines: 1,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: labelLineHeight * 2,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLink extends StatelessWidget {
  const _ProgressLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('open-progress'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: profileCardDecoration(colorScheme, radius: 20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Weekly workouts, calories, and weight.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({
    required this.onEdit,
    required this.onGoals,
    required this.onAchievements,
    required this.onSettings,
    required this.onLogout,
  });

  final VoidCallback onEdit;
  final VoidCallback onGoals;
  final VoidCallback onAchievements;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: profileCardDecoration(colorScheme, radius: 20),
      child: Column(
        children: [
          _MenuTile(
            tileKey: const Key('menu-edit-profile'),
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: onEdit,
          ),
          const Divider(height: 1),
          _MenuTile(
            tileKey: const Key('menu-goals'),
            icon: Icons.flag_outlined,
            title: 'My Goals',
            onTap: onGoals,
          ),
          const Divider(height: 1),
          _MenuTile(
            tileKey: const Key('menu-achievements'),
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            onTap: onAchievements,
          ),
          const Divider(height: 1),
          _MenuTile(
            tileKey: const Key('menu-settings'),
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: onSettings,
          ),
          const Divider(height: 1),
          _MenuTile(
            tileKey: const Key('menu-logout'),
            icon: Icons.logout,
            title: 'Logout',
            onTap: onLogout,
            foreground: colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.tileKey,
    required this.icon,
    required this.title,
    required this.onTap,
    this.foreground,
  });

  final Key tileKey;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = foreground ?? colorScheme.onSurface;

    return InkWell(
      key: tileKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: foreground ?? colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: foreground ?? colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
