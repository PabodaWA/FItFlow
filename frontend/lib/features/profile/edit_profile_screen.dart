import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_widgets.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final MemberProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late FitnessGoal _goal;
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _goal = widget.profile.goal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      widget.profile.copyWith(
        name: name,
        initials: initialsFor(name),
        goal: _goal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final draftName = _nameController.text.trim();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: ListView(
              key: const Key('edit-profile-form'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Center(
                  child: ProfileAvatar(
                    initials: draftName.isEmpty
                        ? widget.profile.initials
                        : initialsFor(draftName),
                    color: widget.profile.avatarColor,
                    size: 96,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your name and fitness goal.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('edit-profile-name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: maxProfileNameLength,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                    counterText: '',
                  ),
                  validator: validateProfileName,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 22),
                const ProfileSectionTitle('Fitness goal'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final goal in FitnessGoal.values)
                      ChoiceChip(
                        key: Key('edit-goal-${goal.name}'),
                        label: Text(goal.label),
                        selected: goal == _goal,
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) setState(() => _goal = goal);
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        labelStyle: TextStyle(
                          color: goal == _goal
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: goal == _goal
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton(
                  key: const Key('save-profile'),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
