import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../config/theme.dart';
import '../utils/constants.dart';
import '../utils/permissions.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.translate,
      title: 'مرحباً بك في هشوم ترجمة 🪶',
      description: 'مترجم صوتي ذكي يترجم كلامك فوراً\nيتعرف على اللغة تلقائياً ويحولها للغة اللي تبيها',
      color: AppTheme.primaryColor,
    ),
    _OnboardingPage(
      icon: Icons.mic,
      title: 'ترجمة صوتية فورية 🎙️',
      description: 'تكلم بأي لغة والتطبيق يترجم ويتكلم بالصوت\nاختر الصوت اللي يعجبك من مكتبة الأصوات',
      color: AppTheme.secondaryColor,
    ),
    _OnboardingPage(
      icon: Icons.videogame_asset,
      title: 'يشتغل في الخلفية 🎮',
      description: 'شغّل الترجمة وارجع لتطبيقك\nيشتغل فوق TikTok والألعاب واللايفات\nزر عائم للتحكم بكل شي',
      color: AppTheme.accentColor,
    ),
    _OnboardingPage(
      icon: Icons.people,
      title: 'محادثات ثنائية 🗣️',
      description: 'تكلم عربي وهو يسمع إنجليزي\nوهو يتكلم إنجليزي وأنت تسمع عربي\nكل واحد يسمع بلغته!',
      color: AppTheme.successColor,
    ),
    _OnboardingPage(
      icon: Icons.security,
      title: 'صلاحيات مطلوبة 🔐',
      description: 'نحتاج إذن الميكروفون للترجمة الصوتية\nوإذن العرض فوق التطبيقات للزر العائم\nبياناتك آمنة 100%',
      color: AppTheme.warningColor,
    ),
  ];

  void _skip() => _finishOnboarding();
  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _requestPermissionsAndFinish();
    }
  }

  Future<void> _requestPermissionsAndFinish() async {
    await AppPermissions.requestAll();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'تخطي ←',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [page.color, page.color.withOpacity(0.5)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.color.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(page.icon, size: 60, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 48),
                        FadeInUp(
                          child: Text(
                            page.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInUp(
                          delay: Duration(milliseconds: 200),
                          child: Text(
                            page.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots + Button
            Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == i
                              ? _pages[_currentPage].color
                              : AppTheme.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'التالي →' : 'ابدأ الآن! 🚀',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
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

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
