import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_widgets.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final ProfileSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late var _reminders = widget.settings.workoutReminders;
  late var _summary = widget.settings.weeklySummary;
  late var _metric = widget.settings.useMetricUnits;

  void _save() {
    Navigator.of(context).pop(
      ProfileSettings(
        workoutReminders: _reminders,
        weeklySummary: _summary,
        useMetricUnits: _metric,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            key: const Key('settings-list'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                'Reminders and how progress is measured.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: profileCardDecoration(colorScheme).boxShadow,
                ),
                child: Material(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('setting-reminders'),
                        title: const Text('Workout reminders'),
                        subtitle: const Text('Daily nudge to train.'),
                        value: _reminders,
                        onChanged: (value) =>
                            setState(() => _reminders = value),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        key: const Key('setting-weekly-summary'),
                        title: const Text('Weekly summary'),
                        subtitle: const Text(
                          'A recap of workouts and calories.',
                        ),
                        value: _summary,
                        onChanged: (value) => setState(() => _summary = value),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        key: const Key('setting-metric'),
                        title: const Text('Use kilograms'),
                        subtitle: const Text(
                          'Weight progress uses pounds when this is off.',
                        ),
                        value: _metric,
                        onChanged: (value) => setState(() => _metric = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('save-settings'),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
