import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aura_clean/screens/onboarding_screen.dart';
import 'package:aura_clean/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoColor;
  
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  bool _showLogo = false;
  
  // Configuration
  static const int particleCount = 3000;
  static const Duration animationDuration = Duration(milliseconds: 4000);
  
  // Colors
  static const List<Color> initialColors = [
    Color(0xFF4B5563), // Gray
    Color(0xFF6B7280), // Gray
    Color(0xFF9CA3AF), // Gray
  ];
  
  static const List<Color> targetColors = [
    Color(0xFF34D399), // Teal
    Color(0xFF818CF8), // Indigo
    Color(0xFFA78BFA), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimation();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    ));
    
    _logoScale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoColor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final radius = 50 + _random.nextDouble() * 200;
      
      _particles.add(Particle(
        x: 200 + cos(angle) * radius,
        y: 200 + sin(angle) * radius,
        vx: (_random.nextDouble() - 0.5) * 0.5,
        vy: (_random.nextDouble() - 0.5) * 0.5,
        radius: 0.5 + _random.nextDouble() * 1.0,
        initialColor: initialColors[i % initialColors.length],
        targetColor: targetColors[i % targetColors.length],
      ));
    }
  }

  void _startAnimation() async {
    // Start particle animation
    _particleController.forward();
    
    // Wait for vortex to complete
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      setState(() {
        _showLogo = true;
      });
      
      // Start logo animation
      _logoController.forward();
      
      // Wait for logo animation to complete
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (mounted) {
        // Navigate to next screen
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    if (mounted) {
      if (onboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            children: [
              // Particle animation canvas
              if (!_showLogo)
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(400, 400),
                      painter: ParticlePainter(
                        particles: _particles,
                        progress: _particleController.value,
                      ),
                    );
                  },
                ),
              
              // Logo container
              if (_showLogo)
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo placeholder with pulsing animation
                            AnimatedBuilder(
                              animation: _logoColor,
                              builder: (context, child) {
                                final colorProgress = _logoColor.value;
                                final pulseValue = (sin(colorProgress * 2 * pi * 2) + 1) / 2;
                                
                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.lerp(
                                        const Color(0xFFA78BFA),
                                        const Color(0xFF34D399),
                                        pulseValue,
                                      )!,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.lerp(
                                          const Color(0xFFA78BFA),
                                          const Color(0xFF34D399),
                                          pulseValue,
                                        )!.withValues(alpha: 0.3),
                                        blurRadius: 30,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                            // Brand name
                            const Text(
                              'Aura Clean',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w100,
                                color: Color(0xFFE5E7EB),
                                letterSpacing: 1.0,
                                fontFamily: 'Manjari',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Particle {
  double x, y, vx, vy, radius;
  final Color initialColor;
  final Color targetColor;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.initialColor,
    required this.targetColor,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  
  ParticlePainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Clear with translucent background for motion trails
    final paint = Paint()
      ..color = const Color(0xFF111827).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
    
    // Calculate vortex progress (1.0s to 3.5s)
    final vortexProgress = (progress * 4 - 1).clamp(0.0, 1.0);
    
    for (final particle in particles) {
      if (vortexProgress > 0) {
        // Calculate distance from center
        final dx = centerX - particle.x;
        final dy = centerY - particle.y;
        final dist = sqrt(dx * dx + dy * dy);
        
        if (dist > 0) {
          // Attraction force towards center
          final force = (1 - (dist / (size.width / 2))) * 0.1;
          particle.vx += (dx / dist) * force;
          particle.vy += (dy / dist) * force;
          
          // Rotational force for swirl effect
          final swirlStrength = min(1.0, vortexProgress * 2);
          particle.vx += -dy * 0.001 * swirlStrength;
          particle.vy += dx * 0.001 * swirlStrength;
        }
      }
      
      // Apply velocity and friction
      particle.vx *= 0.98;
      particle.vy *= 0.98;
      particle.x += particle.vx;
      particle.y += particle.vy;
      
      // Draw particle
      final particlePaint = Paint()
        ..color = Color.lerp(
          particle.initialColor,
          particle.targetColor,
          vortexProgress,
        )!
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        particlePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
