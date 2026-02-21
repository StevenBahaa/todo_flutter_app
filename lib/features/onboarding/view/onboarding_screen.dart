import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/features/today/view/today_dashboard_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/local/user_profile_prefs.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  final _nameCtrl = TextEditingController();
  String? _photoPath;

  final _prefs = UserProfilePrefs();

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(x.path);
    final dest = p.join(dir.path, 'profile_photo$ext');

    final saved = await File(x.path).copy(dest);
    setState(() => _photoPath = saved.path);
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
      return;
    }

    await _prefs.saveProfile(name: name, photoPath: _photoPath);
    await _prefs.setOnboardingDone(true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TodayDashboardScreen()),
    );
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_index < 2) {
      _page.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _page.animateToPage(
      2,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: isLast ? null : _skip,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: isLast
                            ? AppColors.textMuted.withAlpha(120)
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _OnboardingPage(
                    svgAsset: "assets/svg/To do list-bro.svg",
                    title: "Track\nProgress",
                    subtitle:
                        "Gain insights into your daily productivity. Watch your streak grow as you complete tasks.",
                  ),
                  _OnboardingPage(
                    svgAsset: "assets/svg/To do list-pana.svg",
                    title: "Master\nYour Day",
                    subtitle:
                        "Turn chaos into clarity. Prioritize what matters most with just a few taps.",
                  ),
                  _OnboardingProfilePage(
                    svgAsset: "assets/svg/To do list-rafiki.svg",
                    title: "Filter\nwith Speed",
                    subtitle:
                        "Stop scrolling, start doing. Use smart tags to find any task in seconds.",
                    nameCtrl: _nameCtrl,
                    photoPath: _photoPath,
                    onPickPhoto: _pickPhoto,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _Dots(index: _index),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A15B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _next,
                  child: Text(
                    isLast ? "Get Started" : "Next  →",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const SizedBox(height: 22),

          // SVG hero (use your SVG, not built from scratch)
          _SvgHeroCard(asset: svgAsset),

          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 40,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingProfilePage extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String subtitle;

  final TextEditingController nameCtrl;
  final String? photoPath;
  final VoidCallback onPickPhoto;

  const _OnboardingProfilePage({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.nameCtrl,
    required this.photoPath,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = nameCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 22),
            _SvgHeroCard(asset: svgAsset),

            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 40,
                height: 1.05,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Name + photo block
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _PhotoPreview(photoPath: photoPath),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          onChanged: (_) {},
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            hintText: "Your name",
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3A15B6),
                                width: 1.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onPickPhoto,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text(
                        "Upload profile photo",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (!hasName) ...[
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Name is required to continue",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SvgHeroCard extends StatelessWidget {
  final String asset;
  const _SvgHeroCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SvgPicture.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String? photoPath;
  const _PhotoPreview({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final has = photoPath != null && photoPath!.isNotEmpty;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: has
            ? Image.file(File(photoPath!), fit: BoxFit.cover)
            : const Icon(Icons.person, color: AppColors.textMuted),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  const _Dots({required this.index});

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active ? 28 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3A15B6) : AppColors.border,
        borderRadius: BorderRadius.circular(99),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [dot(index == 0), dot(index == 1), dot(index == 2)],
    );
  }
}
