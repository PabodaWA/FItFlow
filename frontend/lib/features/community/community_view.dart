import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/community/comments_screen.dart';
import 'package:fitflow/features/community/community_mock_data.dart';
import 'package:fitflow/features/community/community_models.dart';
import 'package:fitflow/features/community/community_widgets.dart';
import 'package:fitflow/features/community/create_post_screen.dart';
import 'package:flutter/material.dart';

const _likeColor = Color(0xFFE11D48);
const _achievementColor = Color(0xFFB86E00);

class CommunityView extends StatefulWidget {
  const CommunityView({super.key, this.initialFeed});

  /// Local feed shown before a community backend is connected.
  final CommunityFeed? initialFeed;

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  late CommunityFeed _feed;
  var _filter = CommunityFeedFilter.all;

  @override
  void initState() {
    super.initState();
    _feed = widget.initialFeed ?? CommunityMockData.feed;
  }

  Future<void> _createPost() async {
    final post = await Navigator.of(context).push<CommunityPost>(
      fadePageRoute<CommunityPost>(
        builder: (context) => CreatePostScreen(author: _feed.profile),
      ),
    );
    if (!mounted || post == null) return;
    setState(() => _feed = _feed.publish(post));
  }

  Future<void> _openComments(CommunityPost post) {
    return Navigator.of(context).push<void>(
      fadePageRoute<void>(
        builder: (context) => CommentsScreen(
          post: post,
          currentUser: _feed.profile,
          onPostChanged: (updated) {
            setState(() => _feed = _feed.replacePost(updated));
          },
        ),
      ),
    );
  }

  Future<void> _share(CommunityPost post) async {
    final shared = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => _ShareSheet(caption: post.caption),
    );
    if (!mounted || shared != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared: ${post.caption}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleLike(CommunityPost post) {
    setState(() => _feed = _feed.replacePost(post.toggleLike()));
  }

  String get _emptyMessage => switch (_filter) {
    CommunityFeedFilter.all => 'No posts yet. Share your first workout.',
    CommunityFeedFilter.posts => 'No fitness posts yet.',
    CommunityFeedFilter.achievements => 'No workout achievements yet.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visiblePosts = _feed.postsFor(_filter);

    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('community-list'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Community',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Workouts and achievements from your circle.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                _ProfileCard(profile: _feed.profile),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('create-post-button'),
                  onPressed: _createPost,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Post'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Feed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in CommunityFeedFilter.values)
                      ChoiceChip(
                        key: Key('feed-filter-${filter.name}'),
                        label: Text(filter.label),
                        selected: filter == _filter,
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) setState(() => _filter = filter);
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        labelStyle: TextStyle(
                          color: filter == _filter
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: filter == _filter
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (visiblePosts.isEmpty)
                  _EmptyFeed(message: _emptyMessage)
                else
                  for (var index = 0; index < visiblePosts.length; index++) ...[
                    if (index > 0) const SizedBox(height: 14),
                    _PostCard(
                      post: visiblePosts[index],
                      onLike: () => _toggleLike(visiblePosts[index]),
                      onComment: () => _openComments(visiblePosts[index]),
                      onShare: () => _share(visiblePosts[index]),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: _cardDecoration(colorScheme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommunityAvatar(
                  key: const Key('profile-avatar'),
                  initials: profile.initials,
                  color: profile.avatarColor,
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        key: const Key('profile-name'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.handle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.bio,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: formatCommunityCount(profile.postCount),
                    label: 'Posts',
                    valueKey: const Key('profile-post-count'),
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: formatCommunityCount(profile.followers),
                    label: 'Followers',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: formatCommunityCount(profile.following),
                    label: 'Following',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label, this.valueKey});

  final String value;
  final String label;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            key: valueKey,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: VerticalDivider(
        width: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final achievement = post.achievement;

    return DecoratedBox(
      key: Key('post-card-${post.id}'),
      decoration: _cardDecoration(colorScheme),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  CommunityAvatar(
                    key: Key('post-avatar-${post.id}'),
                    initials: post.author.initials,
                    color: post.author.avatarColor,
                    size: 42,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${post.author.handle} · ${post.timeLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (achievement != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: _AchievementBanner(
                  title: achievement,
                  detail: post.achievementDetail,
                ),
              ),
            CommunityPhoto(
              key: Key('post-image-${post.id}'),
              image: post.image,
              height: 188,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text(
                post.caption,
                key: Key('post-caption-${post.id}'),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _PostAction(
                      key: Key('like-button-${post.id}'),
                      icon: post.liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      count: formatCommunityCount(post.likes),
                      countKey: Key('like-count-${post.id}'),
                      label: likesLabel(post.likes),
                      color: post.liked ? _likeColor : null,
                      onPressed: onLike,
                    ),
                  ),
                  Expanded(
                    child: _PostAction(
                      key: Key('comment-button-${post.id}'),
                      icon: Icons.chat_bubble_outline,
                      count: formatCommunityCount(post.comments.length),
                      countKey: Key('comment-count-${post.id}'),
                      label: commentsLabel(post.comments.length),
                      onPressed: onComment,
                    ),
                  ),
                  Expanded(
                    child: _PostAction(
                      key: Key('share-button-${post.id}'),
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onPressed: onShare,
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

class _AchievementBanner extends StatelessWidget {
  const _AchievementBanner({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _achievementColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: _achievementColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _achievementColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

class _PostAction extends StatelessWidget {
  const _PostAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.count,
    this.countKey,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? count;
  final Key? countKey;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: 6),
                    if (count != null) ...[
                      Text(
                        count!,
                        key: countKey,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: foreground,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      key: const Key('community-empty'),
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 36, color: colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Share post',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('confirm-share-button'),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme colorScheme) {
  return BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
