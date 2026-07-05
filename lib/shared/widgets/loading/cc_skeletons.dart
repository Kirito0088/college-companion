import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CCSkeleton extends StatefulWidget {
  const CCSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<CCSkeleton> createState() => _CCSkeletonState();
}

class _CCSkeletonState extends State<CCSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainerHighest.withValues(
              alpha: _animation.value,
            ),
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(RadiusTokens.md),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: CCSkeleton(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Row(
            children: [
              CCSkeleton(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CCSkeleton(width: double.infinity, height: 16),
                    const SizedBox(height: SpacingTokens.sm),
                    CCSkeleton(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CCSkeleton(
          width: 80,
          height: 80,
          borderRadius: BorderRadius.circular(40),
        ),
        const SizedBox(height: SpacingTokens.md),
        const CCSkeleton(width: 150, height: 24),
        const SizedBox(height: SpacingTokens.sm),
        const CCSkeleton(width: 200, height: 16),
      ],
    );
  }
}

class SkeletonNotification extends StatelessWidget {
  const SkeletonNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CCSkeleton(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(width: SpacingTokens.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CCSkeleton(width: double.infinity, height: 16),
                    SizedBox(height: SpacingTokens.xs),
                    CCSkeleton(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
