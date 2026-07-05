import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            physics: const BouncingScrollPhysics(),
            children: const [
              _WelcomePage(),
              _AttendancePage(),
              _PlanningPage(),
              _StudyHubPage(),
              _ReadyPage(),
            ],
          ),

          // Bottom Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: LayoutTokens.screenPadding,
                right: LayoutTokens.screenPadding,
                top: SpacingTokens.xl,
                bottom:
                    MediaQuery.of(context).padding.bottom + SpacingTokens.xl,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0),
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip or Empty space
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
                    child: TextButton(
                      onPressed: _currentPage < _totalPages - 1
                          ? _finishOnboarding
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: ColorTokens.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.sm,
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),

                  // Page Indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_totalPages, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ColorTokens.primary
                              : ColorTokens.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Start Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage < _totalPages - 1
                        ? IconButton(
                            key: const ValueKey('next'),
                            onPressed: _nextPage,
                            style: IconButton.styleFrom(
                              backgroundColor: ColorTokens.primary,
                              foregroundColor: ColorTokens.onPrimary,
                              padding: const EdgeInsets.all(SpacingTokens.md),
                            ),
                            icon: const Icon(Symbols.arrow_forward),
                          )
                        : FilledButton(
                            key: const ValueKey('start'),
                            onPressed: _finishOnboarding,
                            style: FilledButton.styleFrom(
                              backgroundColor: ColorTokens.primary,
                              foregroundColor: ColorTokens.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.xl,
                                vertical: SpacingTokens.md,
                              ),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared Layout Widget for consistency
// -----------------------------------------------------------------------------
class _OnboardingPageLayout extends StatelessWidget {
  const _OnboardingPageLayout({
    required this.heroVisual,
    required this.title,
    required this.subtitle,
  });

  final Widget heroVisual;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top + SpacingTokens.xxxl;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topPadding),
          Expanded(flex: 3, child: Center(child: heroVisual)),
          Expanded(
            flex: 2,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuint,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 1: Welcome
// -----------------------------------------------------------------------------
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPageLayout(
      heroVisual: _WelcomeHero(),
      title: 'Your college life,\norganized.',
      subtitle:
          'Everything you need in one place. Say goodbye to scattered notes, missed deadlines, and attendance anxiety.',
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorTokens.primary.withValues(alpha: 0.2),
              ColorTokens.primary.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: ColorTokens.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 40,
              left: 40,
              child: _FloatingIconCard(
                icon: Symbols.calendar_month,
                color: ColorTokens.tertiary,
                delay: 200,
              ),
            ),
            const Positioned(
              bottom: 60,
              left: 30,
              child: _FloatingIconCard(
                icon: Symbols.fact_check,
                color: ColorTokens.success,
                delay: 400,
              ),
            ),
            const Positioned(
              top: 70,
              right: 30,
              child: _FloatingIconCard(
                icon: Symbols.description,
                color: ColorTokens.info,
                delay: 600,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              decoration: BoxDecoration(
                color: ColorTokens.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorTokens.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Symbols.school,
                size: 48,
                color: ColorTokens.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingIconCard extends StatelessWidget {
  const _FloatingIconCard({
    required this.icon,
    required this.color,
    required this.delay,
  });

  final IconData icon;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 2: Attendance
// -----------------------------------------------------------------------------
class _AttendancePage extends StatelessWidget {
  const _AttendancePage();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPageLayout(
      heroVisual: _AttendanceHero(),
      title: 'Attendance',
      subtitle:
          'Know exactly where you stand before attendance becomes a problem.',
    );
  }
}

class _AttendanceHero extends StatelessWidget {
  const _AttendanceHero();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: 0.85 * value,
                strokeWidth: 12,
                backgroundColor: ColorTokens.surfaceContainerHighest,
                color: ColorTokens.success,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(85 * value).toInt()}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Safe',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: ColorTokens.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 3: Stay on Top
// -----------------------------------------------------------------------------
class _PlanningPage extends StatelessWidget {
  const _PlanningPage();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPageLayout(
      heroVisual: _PlanningHero(),
      title: 'Never Miss What\'s Next',
      subtitle:
          'Your schedule, deadlines, and events neatly organized so you always stay ahead.',
    );
  }
}

class _PlanningHero extends StatelessWidget {
  const _PlanningHero();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _MockCard(
          delay: 0,
          yOffset: -40,
          rotate: -0.05,
          color: ColorTokens.primary,
          icon: Symbols.assignment,
          title: 'Math Assignment',
          subtitle: 'Due Tomorrow',
        ),
        _MockCard(
          delay: 200,
          yOffset: 40,
          rotate: 0.05,
          color: ColorTokens.tertiary,
          icon: Symbols.event,
          title: 'Database Lecture',
          subtitle: '10:00 AM - Room 402',
        ),
      ],
    );
  }
}

class _MockCard extends StatelessWidget {
  const _MockCard({
    required this.delay,
    required this.yOffset,
    required this.rotate,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final int delay;
  final double yOffset;
  final double rotate;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        // Wait for delay before starting animation (simulated)
        final adjustedValue =
            (value - (delay / 1000)).clamp(0.0, 1.0) / (1 - (delay / 1000));

        return Transform.translate(
          offset: Offset(0, yOffset + (40 * (1 - adjustedValue))),
          child: Transform.rotate(
            angle: rotate * adjustedValue,
            child: Opacity(
              opacity: adjustedValue.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusXl,
          border: Border.all(color: ColorTokens.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: RadiusTokens.borderRadiusMd,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ColorTokens.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// -----------------------------------------------------------------------------
// Screen 4: Study Hub
// -----------------------------------------------------------------------------
class _StudyHubPage extends StatelessWidget {
  const _StudyHubPage();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPageLayout(
      heroVisual: _StudyHubHero(),
      title: 'Your Study Hub',
      subtitle:
          'Your notes, PDFs, previous papers, and study material are always with you—even without an internet connection.',
    );
  }
}

class _StudyHubHero extends StatelessWidget {
  const _StudyHubHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Folders in background
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-40 * value, -30 * value),
              child: Opacity(
                opacity: (value * 0.6).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: const _FolderIcon(color: ColorTokens.info),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(40 * value, -10 * value),
              child: Opacity(
                opacity: (value * 0.8).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: const _FolderIcon(color: ColorTokens.warning),
        ),

        // Main File Card
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceContainerHighest,
              borderRadius: RadiusTokens.borderRadiusXl,
              border: Border.all(color: ColorTokens.outlineVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.xl),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.picture_as_pdf,
                    size: 48,
                    color: ColorTokens.primary,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Container(
                  height: 8,
                  width: 80,
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FolderIcon extends StatelessWidget {
  const _FolderIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(
        Symbols.folder,
        size: 64,
        color: color.withValues(alpha: 0.8),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 5: Ready
// -----------------------------------------------------------------------------
class _ReadyPage extends StatelessWidget {
  const _ReadyPage();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPageLayout(
      heroVisual: _ReadyHero(),
      title: 'You\'re Ready',
      subtitle:
          'Dive in and experience a smarter way to handle your college journey.',
    );
  }
}

class _ReadyHero extends StatelessWidget {
  const _ReadyHero();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: ColorTokens.success.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Symbols.check_circle,
            size: 80,
            color: ColorTokens.success,
          ),
        ),
      ),
    );
  }
}
