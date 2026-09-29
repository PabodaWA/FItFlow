import 'package:fitflow/features/community/comments_screen.dart';
import 'package:fitflow/features/community/community_mock_data.dart';
import 'package:fitflow/features/community/community_models.dart';
import 'package:fitflow/features/community/community_view.dart';
import 'package:fitflow/features/community/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample feed matches the local community posts', () {
    final feed = CommunityMockData.feed;
    final fullBody = feed.posts.first;

    expect(feed.profile.name, 'Jordan Hale');
    expect(feed.profile.handle, '@jordan');
    expect(feed.profile.postCount, 8);
    expect(feed.profile.followers, 248);
    expect(feed.profile.following, 86);
    expect(feed.posts, hasLength(4));
    expect(fullBody.caption, 'Completed my Full Body Workout 💪');
    expect(fullBody.kind, CommunityPostKind.achievement);
    expect(fullBody.achievement, 'Full Body Workout');
    expect(fullBody.likes, 128);
    expect(fullBody.liked, isFalse);
    expect(fullBody.comments, hasLength(2));
    expect(fullBody.comments.first.text, 'That finisher looked tough.');
    expect(fullBody.image.label, 'Strength session');
    expect(feed.postsFor(CommunityFeedFilter.achievements), hasLength(2));
    expect(feed.postsFor(CommunityFeedFilter.posts), hasLength(2));
    expect(feed.postsFor(CommunityFeedFilter.posts).map((post) => post.id), [
      'easy-run',
      'mobility',
    ]);
  });

  test('likes, comments, and publishing keep the previous feed unchanged', () {
    final feed = CommunityMockData.feed;
    final original = feed.posts.first;
    final liked = original.toggleLike();
    final commented = liked.addComment(
      const CommunityComment(
        id: 'comment-new',
        authorName: 'Jordan Hale',
        initials: 'JH',
        avatarColor: Color(0xFF1B7F4E),
        text: 'Count me in.',
        timeLabel: 'Just now',
      ),
    );
    final published = feed.publish(
      CommunityPost(
        id: 'new-post',
        author: feed.profile,
        caption: 'New session in the books.',
        image: CommunityMockData.hiit,
        kind: CommunityPostKind.post,
        likes: 0,
        liked: false,
        comments: const [],
        timeLabel: 'Just now',
      ),
    );

    expect(original.likes, 128);
    expect(original.liked, isFalse);
    expect(original.comments, hasLength(2));
    expect(liked.likes, 129);
    expect(liked.liked, isTrue);
    expect(liked.toggleLike().likes, 128);
    expect(commented.comments, hasLength(3));
    expect(commented.comments.last.text, 'Count me in.');
    expect(feed.posts, hasLength(4));
    expect(feed.profile.postCount, 8);
    expect(published.posts.first.caption, 'New session in the books.');
    expect(published.profile.postCount, 9);
    expect(published.posts, hasLength(5));

    const alreadyLiked = CommunityPost(
      id: 'zero',
      author: CommunityMockData.jordan,
      caption: 'Rest day',
      image: CommunityMockData.outdoor,
      kind: CommunityPostKind.post,
      likes: 0,
      liked: true,
      comments: [],
      timeLabel: 'Now',
    );
    expect(alreadyLiked.toggleLike().likes, 0);
    expect(alreadyLiked.toggleLike().liked, isFalse);
  });

  test('counts use thousands separators and captions are validated', () {
    expect(formatCommunityCount(0), '0');
    expect(formatCommunityCount(128), '128');
    expect(formatCommunityCount(1248), '1,248');
    expect(likesLabel(1), 'Like');
    expect(likesLabel(2), 'Likes');
    expect(commentsLabel(1), 'Comment');
    expect(commentsLabel(0), 'Comments');
    expect(validateCaption('  '), 'Add a caption.');
    expect(validateCaption('Finished the session.'), isNull);
    expect(validateCaption('a' * 221), 'Use 220 characters or fewer.');
    expect(validateComment(''), 'Write a comment.');
    expect(validateComment('Nice work.'), isNull);
    expect(validateComment('a' * 181), 'Use 180 characters or fewer.');
  });

  testWidgets('feed shows the profile, example post, likes, and comments', (
    tester,
  ) async {
    await pumpCommunity(tester, size: const Size(390, 2200));

    expect(find.text('Community'), findsWidgets);
    expect(find.text('Jordan Hale'), findsWidgets);
    expect(find.text('@jordan'), findsWidgets);
    expect(find.text('Strength training, five days a week.'), findsOneWidget);
    expect(find.text('Posts'), findsWidgets);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('248'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.byKey(const Key('profile-avatar')), findsOneWidget);
    expect(find.byKey(const Key('create-post-button')), findsOneWidget);

    expect(find.text('Completed my Full Body Workout 💪'), findsOneWidget);
    expect(find.text('Full Body Workout'), findsOneWidget);
    expect(find.text('Achievement'), findsWidgets);
    expect(find.text('45 min · 420 kcal'), findsOneWidget);
    expect(find.text('Strength session'), findsOneWidget);
    expect(find.byKey(const Key('post-avatar-full-body')), findsOneWidget);
    expect(find.byKey(const Key('post-image-full-body')), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Likes'), findsWidgets);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Comments'), findsWidgets);
    expect(find.text('Share'), findsWidgets);
    expect(find.text('Hit a new squat personal record.'), findsOneWidget);
    expect(find.text('Easy 5K before the sunrise.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('feed-filter-achievements')));
    await tester.pumpAndSettle();
    expect(find.text('Completed my Full Body Workout 💪'), findsOneWidget);
    expect(find.text('Squat PR'), findsOneWidget);
    expect(find.text('Easy 5K before the sunrise.'), findsNothing);

    await tester.tap(find.byKey(const Key('feed-filter-posts')));
    await tester.pumpAndSettle();
    expect(find.text('Completed my Full Body Workout 💪'), findsNothing);
    expect(find.text('Easy 5K before the sunrise.'), findsOneWidget);
    expect(
      find.text('Ten minutes of hip mobility after leg day.'),
      findsOneWidget,
    );
  });

  testWidgets('liking a post updates the count', (tester) async {
    await pumpCommunity(tester, size: const Size(390, 2200));

    expect(likeCount(tester, 'full-body'), '128');
    await tester.tap(find.byKey(const Key('like-button-full-body')));
    await tester.pump();
    expect(likeCount(tester, 'full-body'), '129');
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

    await tester.tap(find.byKey(const Key('like-button-full-body')));
    await tester.pump();
    expect(likeCount(tester, 'full-body'), '128');
  });

  testWidgets('comments can be read and added', (tester) async {
    await pumpCommunity(tester, size: const Size(390, 2200));

    await tester.tap(find.byKey(const Key('comment-button-full-body')));
    await tester.pumpAndSettle();
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('That finisher looked tough.'), findsOneWidget);
    expect(find.text('Saving this for tomorrow.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('comment-field')),
      'Count me in.',
    );
    await tester.tap(find.byKey(const Key('send-comment-button')));
    await tester.pump();
    expect(find.text('Count me in.'), findsOneWidget);
    expect(find.text('Write a comment.'), findsNothing);

    await tester.tap(find.byKey(const Key('send-comment-button')));
    await tester.pump();
    expect(find.text('Write a comment.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(commentCount(tester, 'full-body'), '3');
    expect(find.text('Count me in.'), findsNothing);
  });

  testWidgets('an empty comment thread explains that nothing is posted', (
    tester,
  ) async {
    await pumpCommunity(tester, size: const Size(390, 2400));

    await tester.scrollUntilVisible(
      find.byKey(const Key('comment-button-easy-run')),
      400,
      scrollable: communityList,
    );
    await tester.tap(find.byKey(const Key('comment-button-easy-run')));
    await tester.pumpAndSettle();
    expect(find.text('No comments yet.'), findsOneWidget);
    expect(find.text('Easy 5K before the sunrise.'), findsOneWidget);
  });

  testWidgets('sharing a post confirms the caption', (tester) async {
    await pumpCommunity(tester, size: const Size(390, 2200));

    await tester.tap(find.byKey(const Key('share-button-full-body')));
    await tester.pumpAndSettle();
    expect(find.text('Share post'), findsOneWidget);
    expect(find.text('Completed my Full Body Workout 💪'), findsWidgets);

    await tester.tap(find.byKey(const Key('confirm-share-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.text('Shared: Completed my Full Body Workout 💪'),
      findsOneWidget,
    );
  });

  testWidgets('publishing a post adds it to the top of the feed', (
    tester,
  ) async {
    await pumpCommunity(tester, size: const Size(390, 2200));

    await tester.tap(find.byKey(const Key('create-post-button')));
    await tester.pumpAndSettle();
    expect(find.text('Create Post'), findsOneWidget);
    expect(find.text('Select an image'), findsOneWidget);

    await tester.tap(find.byKey(const Key('publish-post-button')));
    await tester.pump();
    expect(find.text('Select an image.'), findsOneWidget);
    expect(find.text('Add a caption.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('community-image-hiit')));
    await tester.pump();
    expect(find.text('Select an image.'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('post-caption-field')),
      'New session in the books.',
    );
    await tester.tap(find.byKey(const Key('publish-post-button')));
    await tester.pumpAndSettle();

    expect(find.text('Share a workout'), findsNothing);
    expect(find.text('New session in the books.'), findsOneWidget);
    expect(find.text('HIIT finisher'), findsOneWidget);
    expect(find.text('@jordan · Just now'), findsOneWidget);
    expect(profilePostCount(tester), '9');
    expect(publishedLikeCount(tester), '0');
  });

  testWidgets('leaving create post does not publish', (tester) async {
    await pumpCommunity(tester, size: const Size(390, 1600));

    await tester.tap(find.byKey(const Key('create-post-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community-image-outdoor')));
    await tester.enterText(
      find.byKey(const Key('post-caption-field')),
      'Should not publish',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Should not publish'), findsNothing);
    expect(find.text('Outdoor session'), findsNothing);
    expect(profilePostCount(tester), '8');
  });

  testWidgets('an empty feed invites the first post', (tester) async {
    await pumpCommunity(
      tester,
      feed: const CommunityFeed(profile: CommunityMockData.jordan, posts: []),
    );

    expect(find.byKey(const Key('community-empty')), findsOneWidget);
    expect(
      find.text('No posts yet. Share your first workout.'),
      findsOneWidget,
    );
    expect(find.text('Completed my Full Body Workout 💪'), findsNothing);
  });

  testWidgets('community layouts avoid overflow', (tester) async {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(800, 400),
    ];

    for (final size in sizes) {
      await pumpCommunity(tester, size: size);
      await exerciseCommunity(tester);
    }

    await pumpCommunity(tester, size: const Size(340, 700), textScale: 1.4);
    await exerciseCommunity(tester);
  });
}

String likeCount(WidgetTester tester, String postId) {
  return tester.widget<Text>(find.byKey(Key('like-count-$postId'))).data!;
}

String commentCount(WidgetTester tester, String postId) {
  return tester.widget<Text>(find.byKey(Key('comment-count-$postId'))).data!;
}

String profilePostCount(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('profile-post-count'))).data!;
}

String publishedLikeCount(WidgetTester tester) {
  final finder = find.byWidgetPredicate((widget) {
    final label = widget.key?.toString() ?? '';
    return widget is Text &&
        label.contains('like-count-') &&
        !label.contains('full-body') &&
        !label.contains('squat-pr') &&
        !label.contains('easy-run') &&
        !label.contains('mobility');
  });
  expect(finder, findsOneWidget);
  return tester.widget<Text>(finder).data!;
}

Finder get communityList => outerScrollable(const Key('community-list'));

Finder outerScrollable(Key listKey) {
  return find.byElementPredicate((element) {
    final widget = element.widget;
    if (widget is! Scrollable || widget.axisDirection != AxisDirection.down) {
      return false;
    }
    var underList = false;
    var nested = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is Scrollable) nested = true;
      if (ancestor.widget.key == listKey) underList = true;
      return true;
    });
    return underList && !nested;
  });
}

Future<void> exerciseCommunity(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Ten minutes of hip mobility after leg day.'),
    400,
    scrollable: communityList,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  await tester.scrollUntilVisible(
    find.byKey(const Key('create-post-button')),
    -400,
    scrollable: communityList,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('create-post-button')));
  await tester.pumpAndSettle();
  final form = outerScrollable(const Key('create-post-form'));
  await tester.scrollUntilVisible(
    find.text('Publish post'),
    400,
    scrollable: form,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await tester.pageBack();
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(
    find.byKey(const Key('comment-button-full-body')),
    400,
    scrollable: communityList,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('comment-button-full-body')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('comment-button-full-body')));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await tester.pageBack();
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(const Key('share-button-full-body')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('share-button-full-body')));
  await tester.pumpAndSettle();
  expect(find.text('Share post'), findsOneWidget);
  expect(tester.takeException(), isNull);
  await tester.tap(find.byKey(const Key('confirm-share-button')));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> pumpCommunity(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  CommunityFeed? feed,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F4E)),
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: Scaffold(body: CommunityView(initialFeed: feed)),
    ),
  );
  await tester.pumpAndSettle();
}
