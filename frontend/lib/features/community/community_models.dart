import 'package:flutter/material.dart';

enum CommunityPostKind { post, achievement }

enum CommunityFeedFilter { all, posts, achievements }

extension CommunityFeedFilterLabel on CommunityFeedFilter {
  String get label => switch (this) {
    CommunityFeedFilter.all => 'All',
    CommunityFeedFilter.posts => 'Posts',
    CommunityFeedFilter.achievements => 'Achievements',
  };
}

class CommunityImage {
  const CommunityImage({
    required this.id,
    required this.label,
    required this.icon,
    required this.start,
    required this.end,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color start;
  final Color end;
}

class CommunityProfile {
  const CommunityProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.initials,
    required this.avatarColor,
    required this.postCount,
    required this.followers,
    required this.following,
    required this.bio,
  });

  final String id;
  final String name;
  final String handle;
  final String initials;
  final Color avatarColor;
  final int postCount;
  final int followers;
  final int following;
  final String bio;

  CommunityProfile copyWith({int? postCount}) {
    return CommunityProfile(
      id: id,
      name: name,
      handle: handle,
      initials: initials,
      avatarColor: avatarColor,
      postCount: postCount ?? this.postCount,
      followers: followers,
      following: following,
      bio: bio,
    );
  }
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.authorName,
    required this.initials,
    required this.avatarColor,
    required this.text,
    required this.timeLabel,
  });

  final String id;
  final String authorName;
  final String initials;
  final Color avatarColor;
  final String text;
  final String timeLabel;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.caption,
    required this.image,
    required this.kind,
    required this.likes,
    required this.liked,
    required this.comments,
    required this.timeLabel,
    this.achievement,
    this.achievementDetail,
  });

  final String id;
  final CommunityProfile author;
  final String caption;
  final CommunityImage image;
  final CommunityPostKind kind;
  final int likes;
  final bool liked;
  final List<CommunityComment> comments;
  final String timeLabel;
  final String? achievement;
  final String? achievementDetail;

  CommunityPost toggleLike() {
    return copyWith(
      liked: !liked,
      likes: liked ? (likes > 0 ? likes - 1 : 0) : likes + 1,
    );
  }

  CommunityPost addComment(CommunityComment comment) {
    return copyWith(comments: [...comments, comment]);
  }

  CommunityPost copyWith({
    int? likes,
    bool? liked,
    List<CommunityComment>? comments,
  }) {
    return CommunityPost(
      id: id,
      author: author,
      caption: caption,
      image: image,
      kind: kind,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      comments: comments ?? this.comments,
      timeLabel: timeLabel,
      achievement: achievement,
      achievementDetail: achievementDetail,
    );
  }
}

class CommunityFeed {
  const CommunityFeed({required this.profile, required this.posts});

  final CommunityProfile profile;
  final List<CommunityPost> posts;

  List<CommunityPost> postsFor(CommunityFeedFilter filter) {
    return switch (filter) {
      CommunityFeedFilter.all => posts,
      CommunityFeedFilter.posts => [
        for (final post in posts)
          if (post.kind == CommunityPostKind.post) post,
      ],
      CommunityFeedFilter.achievements => [
        for (final post in posts)
          if (post.kind == CommunityPostKind.achievement) post,
      ],
    };
  }

  CommunityFeed publish(CommunityPost post) {
    return CommunityFeed(
      profile: profile.copyWith(postCount: profile.postCount + 1),
      posts: [post, ...posts],
    );
  }

  CommunityFeed replacePost(CommunityPost post) {
    return CommunityFeed(
      profile: profile,
      posts: [
        for (final existing in posts)
          if (existing.id == post.id) post else existing,
      ],
    );
  }
}

String newCommunityPostId() => 'post-${DateTime.now().microsecondsSinceEpoch}';

String newCommunityCommentId() =>
    'comment-${DateTime.now().microsecondsSinceEpoch}';

String formatCommunityCount(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    if (index > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  final formatted = buffer.toString();
  return negative ? '-$formatted' : formatted;
}

String likesLabel(int count) => count == 1 ? 'Like' : 'Likes';

String commentsLabel(int count) => count == 1 ? 'Comment' : 'Comments';
