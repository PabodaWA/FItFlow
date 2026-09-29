import 'package:fitflow/features/community/community_models.dart';
import 'package:flutter/material.dart';

/// Local feed shown until a community backend is connected.
abstract final class CommunityMockData {
  static const strength = CommunityImage(
    id: 'strength',
    label: 'Strength session',
    icon: Icons.fitness_center,
    start: Color(0xFF145C38),
    end: Color(0xFF3DDC97),
  );

  static const run = CommunityImage(
    id: 'run',
    label: 'Morning run',
    icon: Icons.directions_run,
    start: Color(0xFF1D4ED8),
    end: Color(0xFF22D3EE),
  );

  static const record = CommunityImage(
    id: 'record',
    label: 'Personal record',
    icon: Icons.emoji_events,
    start: Color(0xFFB45309),
    end: Color(0xFFFBBF24),
  );

  static const mobility = CommunityImage(
    id: 'mobility',
    label: 'Mobility work',
    icon: Icons.self_improvement,
    start: Color(0xFF6D28D9),
    end: Color(0xFFF472B6),
  );

  static const hiit = CommunityImage(
    id: 'hiit',
    label: 'HIIT finisher',
    icon: Icons.timer,
    start: Color(0xFFBE123C),
    end: Color(0xFFFB7185),
  );

  static const outdoor = CommunityImage(
    id: 'outdoor',
    label: 'Outdoor session',
    icon: Icons.park,
    start: Color(0xFF0F766E),
    end: Color(0xFF86EFAC),
  );

  static const images = <CommunityImage>[
    strength,
    run,
    record,
    mobility,
    hiit,
    outdoor,
  ];

  static const jordan = CommunityProfile(
    id: 'jordan',
    name: 'Jordan Hale',
    handle: '@jordan',
    initials: 'JH',
    avatarColor: Color(0xFF1B7F4E),
    postCount: 8,
    followers: 248,
    following: 86,
    bio: 'Strength training, five days a week.',
  );

  static const maya = CommunityProfile(
    id: 'maya',
    name: 'Maya Chen',
    handle: '@maya',
    initials: 'MC',
    avatarColor: Color(0xFF2F6FED),
    postCount: 21,
    followers: 512,
    following: 140,
    bio: 'Lifting and chasing the next PR.',
  );

  static const sam = CommunityProfile(
    id: 'sam',
    name: 'Sam Ortiz',
    handle: '@sam',
    initials: 'SO',
    avatarColor: Color(0xFFB86E00),
    postCount: 14,
    followers: 190,
    following: 97,
    bio: 'Easy miles before work.',
  );

  static const priya = CommunityProfile(
    id: 'priya',
    name: 'Priya Nair',
    handle: '@priya',
    initials: 'PN',
    avatarColor: Color(0xFF7C3AED),
    postCount: 11,
    followers: 163,
    following: 74,
    bio: 'Mobility after every hard session.',
  );

  static const feed = CommunityFeed(
    profile: jordan,
    posts: [
      CommunityPost(
        id: 'full-body',
        author: jordan,
        caption: 'Completed my Full Body Workout 💪',
        image: strength,
        kind: CommunityPostKind.achievement,
        achievement: 'Full Body Workout',
        achievementDetail: '45 min · 420 kcal',
        likes: 128,
        liked: false,
        timeLabel: '2h',
        comments: [
          CommunityComment(
            id: 'comment-finisher',
            authorName: 'Maya Chen',
            initials: 'MC',
            avatarColor: Color(0xFF2F6FED),
            text: 'That finisher looked tough.',
            timeLabel: '1h',
          ),
          CommunityComment(
            id: 'comment-tomorrow',
            authorName: 'Sam Ortiz',
            initials: 'SO',
            avatarColor: Color(0xFFB86E00),
            text: 'Saving this for tomorrow.',
            timeLabel: '45m',
          ),
        ],
      ),
      CommunityPost(
        id: 'squat-pr',
        author: maya,
        caption: 'Hit a new squat personal record.',
        image: record,
        kind: CommunityPostKind.achievement,
        achievement: 'Squat PR',
        achievementDetail: '100 kg · 3 reps',
        likes: 96,
        liked: true,
        timeLabel: '5h',
        comments: [
          CommunityComment(
            id: 'comment-strong',
            authorName: 'Jordan Hale',
            initials: 'JH',
            avatarColor: Color(0xFF1B7F4E),
            text: 'Huge lift. That bar speed looked easy.',
            timeLabel: '4h',
          ),
        ],
      ),
      CommunityPost(
        id: 'easy-run',
        author: sam,
        caption: 'Easy 5K before the sunrise.',
        image: run,
        kind: CommunityPostKind.post,
        likes: 54,
        liked: false,
        timeLabel: '8h',
        comments: [],
      ),
      CommunityPost(
        id: 'mobility',
        author: priya,
        caption: 'Ten minutes of hip mobility after leg day.',
        image: mobility,
        kind: CommunityPostKind.post,
        likes: 37,
        liked: false,
        timeLabel: '1d',
        comments: [
          CommunityComment(
            id: 'comment-needed',
            authorName: 'Maya Chen',
            initials: 'MC',
            avatarColor: Color(0xFF2F6FED),
            text: 'Needed this after squats.',
            timeLabel: '20h',
          ),
        ],
      ),
    ],
  );
}
