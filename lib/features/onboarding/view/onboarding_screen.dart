import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    if (!mounted) return;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Responsive scale (gentle)
            final scale = (w / 390).clamp(0.90, 1.10);

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18 * scale,
                    vertical: 8 * scale,
                  ),
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
                            fontSize: 14 * scale,
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
                        scale: scale,
                        screenH: h,
                      ),
                      _OnboardingPage(
                        svgAsset: "assets/svg/To do list-pana.svg",
                        title: "Master\nYour Day",
                        subtitle:
                            "Turn chaos into clarity. Prioritize what matters most with just a few taps.",
                        scale: scale,
                        screenH: h,
                      ),
                      _OnboardingProfilePage(
                        svgAsset: "assets/svg/To do list-rafiki.svg",
                        title: "Filter\nwith Speed",
                        subtitle:
                            "Stop scrolling, start doing. Use smart tags to find any task in seconds.",
                        nameCtrl: _nameCtrl,
                        photoPath: _photoPath,
                        onPickPhoto: _pickPhoto,
                        onNameChanged: () => setState(() {}),
                        scale: scale,
                        screenH: h,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10 * scale),
                _Dots(index: _index, scale: scale),
                SizedBox(height: 16 * scale),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    18 * scale,
                    0,
                    18 * scale,
                    18 * scale,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: (54 * scale).clamp(48.0, 60.0),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String subtitle;
  final double scale;
  final double screenH;

  const _OnboardingPage({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.scale,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    final heroH = (screenH * 0.42).clamp(220.0, 380.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      child: Column(
        children: [
          SizedBox(height: 22 * scale),
          _SvgHeroCard(asset: svgAsset, height: heroH, scale: scale),
          SizedBox(height: 22 * scale),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: (40 * scale).clamp(30.0, 44.0),
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14 * scale),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: (16 * scale).clamp(13.0, 18.0),
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
  final VoidCallback onNameChanged;

  final double scale;
  final double screenH;

  const _OnboardingProfilePage({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.nameCtrl,
    required this.photoPath,
    required this.onPickPhoto,
    required this.onNameChanged,
    required this.scale,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    final heroH = (screenH * 0.34).clamp(200.0, 320.0);
    final hasName = nameCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 22 * scale),
            _SvgHeroCard(asset: svgAsset, height: heroH, scale: scale),
            SizedBox(height: 22 * scale),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: (40 * scale).clamp(30.0, 44.0),
                height: 1.05,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14 * scale),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: (16 * scale).clamp(13.0, 18.0),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18 * scale),

            Container(
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _PhotoPreview(photoPath: photoPath, scale: scale),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          onChanged: (_) => onNameChanged(),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12 * scale,
                              vertical: 12 * scale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: (44 * scale).clamp(40.0, 52.0),
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
                    SizedBox(height: 10 * scale),
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
  final double height;
  final double scale;

  const _SvgHeroCard({
    required this.asset,
    required this.height,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
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
  final double scale;
  const _PhotoPreview({this.photoPath, required this.scale});

  @override
  Widget build(BuildContext context) {
    final has = photoPath != null && photoPath!.isNotEmpty;
    final size = (54 * scale).clamp(46.0, 62.0);

    return Container(
      width: size,
      height: size,
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
  final double scale;
  const _Dots({required this.index, required this.scale});

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active
          ? (28 * scale).clamp(22.0, 32.0)
          : (8 * scale).clamp(6.0, 10.0),
      height: (8 * scale).clamp(6.0, 10.0),
      margin: EdgeInsets.symmetric(horizontal: 6 * scale),
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
