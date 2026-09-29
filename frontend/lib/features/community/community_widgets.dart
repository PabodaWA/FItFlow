import 'package:fitflow/features/community/community_models.dart';
import 'package:flutter/material.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 44,
  });

  final String initials;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
          height: 1,
        ),
      ),
    );
  }
}

class CommunityPhoto extends StatelessWidget {
  const CommunityPhoto({
    super.key,
    required this.image,
    this.height,
    this.borderRadius = 18,
    this.showLabel = true,
  });

  final CommunityImage image;
  final double? height;
  final double borderRadius;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [image.start, image.end],
              ),
            ),
          ),
          Positioned(
            right: -28,
            top: -36,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Icon(image.icon, color: Colors.white, size: 30),
            ),
          ),
          if (showLabel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                  child: Text(
                    image.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (height == null) return photo;
    return SizedBox(height: height, width: double.infinity, child: photo);
  }
}
