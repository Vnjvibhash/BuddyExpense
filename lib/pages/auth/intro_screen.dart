import 'package:buddyexpense/pages/auth/login_screen.dart';
import 'package:buddyexpense/theme.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  int _currentPage = 0;

  final List<IntroData> _introPages = [
    IntroData(
      title: 'Split Bills Easily',
      description:
          'Share expenses with friends and family effortlessly. No more awkward money conversations.',
      icon: Icons.people_outline,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      illustration: '💰',
    ),
    IntroData(
      title: 'Track Everything',
      description:
          'Keep detailed records of all your shared expenses. Know who owes what at a glance.',
      icon: Icons.analytics_outlined,
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
      illustration: '📊',
    ),
    IntroData(
      title: 'Settle Up Simply',
      description:
          'One-tap settlements make paying back friends quick and painless.',
      icon: Icons.credit_card_outlined,
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      illustration: '✨',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.6)),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _colorAnimation = ColorTween(
      begin: _introPages[0].gradient[0],
      end: _introPages[0].gradient[1],
    ).animate(_backgroundController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _introPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        duration: const Duration(milliseconds: 800),
        child: const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _introPages[_currentPage].gradient[0].withOpacity(0.3),
                  _introPages[_currentPage].gradient[1].withOpacity(0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                center: Alignment.topLeft,
                radius: 2.0,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopSection(),
                  Expanded(child: _buildPageView()),
                  _buildBottomSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                'Buddy Expense',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          if (_currentPage < _introPages.length - 1)
            TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
        _animationController.reset();
        _animationController.forward();
      },
      itemCount: _introPages.length,
      itemBuilder: (context, index) => _buildPage(_introPages[index]),
    );
  }

  Widget _buildPage(IntroData data) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: _build3DIcon(data),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    data.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DIcon(IntroData data) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.gradient[0].withOpacity(0.8), data.gradient[1]],
        ),
        boxShadow: [
          BoxShadow(
            color: data.gradient[0].withOpacity(0.3),
            offset: const Offset(0, 20),
            blurRadius: 40,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: data.gradient[1].withOpacity(0.2),
            offset: const Offset(0, -5),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background floating elements
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildFloatingElement(
                    0.7,
                    0.2,
                    8,
                    data.gradient[0].withOpacity(0.2),
                  ),
                  _buildFloatingElement(
                    0.2,
                    0.8,
                    12,
                    data.gradient[1].withOpacity(0.2),
                  ),
                  _buildFloatingElement(
                    0.8,
                    0.7,
                    6,
                    data.gradient[0].withOpacity(0.15),
                  ),
                ],
              );
            },
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.illustration, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Icon(data.icon, size: 32, color: Colors.white.withOpacity(0.9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(double x, double y, double size, Color color) {
    return Positioned(
      left: x * 200,
      top: y * 200,
      child: Transform.rotate(
        angle: _backgroundController.value * 2 * 3.14159,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: Spacing.xl),
          _buildNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_introPages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? _introPages[_currentPage].gradient[1]
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: _introPages[_currentPage].gradient[1],
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _introPages[_currentPage].gradient[1].withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentPage < _introPages.length - 1
                  ? 'Continue'
                  : 'Get Started',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(
              _currentPage < _introPages.length - 1
                  ? Icons.arrow_forward
                  : Icons.login,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class IntroData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String illustration;

  IntroData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.illustration,
  });
}
