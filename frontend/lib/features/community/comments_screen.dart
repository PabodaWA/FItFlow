import 'package:fitflow/features/community/community_models.dart';
import 'package:fitflow/features/community/community_widgets.dart';
import 'package:flutter/material.dart';

const maxCommentLength = 180;

String? validateComment(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Write a comment.';
  if (text.length > maxCommentLength) {
    return 'Use $maxCommentLength characters or fewer.';
  }
  return null;
}

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onPostChanged,
  });

  final CommunityPost post;
  final CommunityProfile currentUser;
  final ValueChanged<CommunityPost> onPostChanged;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  late CommunityPost _post;
  String? _error;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final error = validateComment(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    final updated = _post.addComment(
      CommunityComment(
        id: newCommunityCommentId(),
        authorName: widget.currentUser.name,
        initials: widget.currentUser.initials,
        avatarColor: widget.currentUser.avatarColor,
        text: _controller.text.trim(),
        timeLabel: 'Just now',
      ),
    );
    setState(() {
      _post = updated;
      _error = null;
      _controller.clear();
    });
    widget.onPostChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _post.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: _post.comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const Key('comments-list'),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: _post.comments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final comment = _post.comments[index];
                      return _CommentTile(comment: comment);
                    },
                  ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('comment-field'),
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: maxCommentLength,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Add a comment',
                              counterText: '',
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('send-comment-button'),
                          tooltip: 'Send comment',
                          onPressed: _send,
                          icon: Icon(
                            Icons.send_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommunityAvatar(
          initials: comment.initials,
          color: comment.avatarColor,
          size: 36,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: comment.authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '  ${comment.timeLabel}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
