import 'package:aura_clean/screens/permissions_screen.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  OnboardingPage(
                    icon: CupertinoIcons.sparkles,
                    title: "Welcome to Aura Clean",
                    description: "Reclaim your phone's storage by easily finding and deleting clutter.",
                  ),
                  OnboardingPage(
                    icon: CupertinoIcons.collections_solid,
                    title: "Find Duplicates & More",
                    description: "Intelligently scan for duplicate photos, similar shots, screenshots, and large videos.",
                  ),
                  OnboardingPage(
                    icon: CupertinoIcons.hand_draw_fill,
                    title: "Simple Gesture Control",
                    description: "Swipe up to delete and down to keep. Cleaning your photo library has never been easier.",
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) => _buildDot(index, context)),
                    ),
                    const Spacer(),
                    CustomButton(
                      text: _currentPage == 2 ? "Get Started" : "Next",
                      onPressed: () {
                        if (_currentPage == 2) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const PermissionsScreen()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF007AFF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(icon, size: 100, color: const Color(0xFF007AFF)),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
