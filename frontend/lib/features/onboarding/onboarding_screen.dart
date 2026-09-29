import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/auth/login_screen.dart';
import 'package:flutter/material.dart';

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const _steps = <_OnboardingStep>[
  _OnboardingStep(
    title: 'Welcome to FitFlow',
    description: 'Build healthier habits and reach your fitness goals.',
    icon: Icons.spa_outlined,
  ),
  _OnboardingStep(
    title: 'Personalized Workouts',
    description: 'Get workouts designed around your fitness goals.',
    icon: Icons.fitness_center,
  ),
  _OnboardingStep(
    title: 'Track Your Progress',
    description: 'Monitor workouts, nutrition, and your progress.',
    icon: Icons.insights_outlined,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  bool get _isLastPage => _pageIndex == _steps.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openAuth() {
    Navigator.of(context).pushReplacement(
      fadePageRoute<void>(builder: (context) => const LoginScreen()),
    );
  }

  void _next() {
    if (_isLastPage) {
      _openAuth();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openAuth,
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _steps.length,
                    onPageChanged: (index) {
                      setState(() => _pageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        controller: _pageController,
                        step: _steps[index],
                        index: index,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _PageIndicator(
                  count: _steps.length,
                  index: _pageIndex,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _next,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Text(
                          _isLastPage ? 'Get Started' : 'Next',
                          key: ValueKey(_isLastPage),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.step,
    required this.index,
  });

  final PageController controller;
  final _OnboardingStep step;
  final int index;

  double _page() {
    if (!controller.hasClients || !controller.position.haveDimensions) {
      return index.toDouble();
    }
    return controller.page ?? index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final distance = (_page() - index).abs().clamp(0.0, 1.0);
        final visibility = 1 - distance;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.55 + (0.45 * visibility),
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - visibility)),
                        child: Transform.scale(
                          scale: 0.92 + (0.08 * visibility),
                          child: _IllustrationPlaceholder(
                            icon: step.icon,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    child!,
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Column(
        children: [
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder({
    required this.icon,
    required this.colorScheme,
  });

  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Illustration placeholder',
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Icon(
          icon,
          size: 88,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final selected = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: selected ? 24 : 8,
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}
