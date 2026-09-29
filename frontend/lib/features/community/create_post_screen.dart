import 'package:fitflow/features/community/community_mock_data.dart';
import 'package:fitflow/features/community/community_models.dart';
import 'package:fitflow/features/community/community_widgets.dart';
import 'package:flutter/material.dart';

const maxCaptionLength = 220;

String? validateCaption(String? value) {
  final caption = value?.trim() ?? '';
  if (caption.isEmpty) return 'Add a caption.';
  if (caption.length > maxCaptionLength) {
    return 'Use $maxCaptionLength characters or fewer.';
  }
  return null;
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.author});

  final CommunityProfile author;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  CommunityImage? _selected;
  String? _imageError;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _publish() {
    final captionValid = _formKey.currentState?.validate() ?? false;
    final imageValid = _selected != null;
    if (!captionValid || !imageValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
        _imageError = imageValid ? null : 'Select an image.';
      });
      return;
    }

    final post = CommunityPost(
      id: newCommunityPostId(),
      author: widget.author,
      caption: _captionController.text.trim(),
      image: _selected!,
      kind: CommunityPostKind.post,
      likes: 0,
      liked: false,
      comments: const [],
      timeLabel: 'Just now',
    );
    Navigator.of(context).pop(post);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Create Post'),
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
              key: const Key('create-post-form'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Text(
                  'Share a workout',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a photo, add a caption, and publish it to your feed.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                _ImagePreview(image: _selected, hasError: _imageError != null),
                if (_imageError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _imageError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Text(
                  'Photos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final columns = constraints.maxWidth >= 520 ? 3 : 2;
                    final tileWidth =
                        (constraints.maxWidth - (columns - 1) * spacing) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final image in CommunityMockData.images)
                          SizedBox(
                            width: tileWidth,
                            height: tileWidth / 0.78,
                            child: _ImageChoice(
                              key: Key('community-image-${image.id}'),
                              image: image,
                              selected: image.id == _selected?.id,
                              onTap: () => setState(() {
                                _selected = image;
                                _imageError = null;
                              }),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                TextFormField(
                  key: const Key('post-caption-field'),
                  controller: _captionController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: maxCaptionLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Caption',
                    alignLabelWithHint: true,
                    hintText: 'Share how the workout went',
                    counterText: '',
                  ),
                  validator: validateCaption,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const Key('publish-post-button'),
                  onPressed: _publish,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Publish post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.hasError});

  final CommunityImage? image;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = image;

    if (selected != null) {
      return CommunityPhoto(
        key: const Key('selected-post-image'),
        image: selected,
        height: 180,
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasError ? colorScheme.error : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Select an image',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageChoice extends StatelessWidget {
  const _ImageChoice({
    super.key,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final CommunityImage image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CommunityPhoto(
                        image: image,
                        borderRadius: 12,
                        showLabel: false,
                      ),
                      if (selected)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  image.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
