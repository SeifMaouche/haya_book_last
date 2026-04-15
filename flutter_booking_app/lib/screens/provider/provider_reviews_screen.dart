// lib/screens/provider/provider_reviews_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../widgets/glass_kit.dart';
import '../../widgets/haya_avatar.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryMid  = Color(0xFF7C3AED);
const _kTextDark    = Color(0xFF1E1B4B);
const _kTextMuted   = Color(0xFF6B7280);

class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0xFFEDE9FE), Color(0xFFF8F7FF)],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 10, left: 16, right: 16),
                child: Row(
                  children: [
                    ScaleTap(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: _kPrimaryMid.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: _kTextDark, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Client Reviews', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 22,
                      fontWeight: FontWeight.w800, color: _kTextDark,
                      letterSpacing: -0.5,
                    )),
                  ],
                ),
              ),
            ),
            
            Consumer<ProviderStateProvider>(
              builder: (context, ps, _) {
                final profile = ps.profile;
                final reviews = profile?.reviews ?? [];
                
                if (reviews.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border_rounded, size: 64, color: _kPrimary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          const Text('No reviews yet.', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 16,
                            fontWeight: FontWeight.w600, color: _kTextMuted,
                          )),
                        ],
                      ),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final r = reviews[i];
                        return FadeSlide(
                          delay: Duration(milliseconds: 100 + (i * 50)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black.withOpacity(0.04)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10, offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      HayaAvatar(
                                        avatarUrl: r.userImage,
                                        size: 40,
                                        isProvider: false,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.userName, style: const TextStyle(
                                              fontFamily: 'Inter', fontSize: 14,
                                              fontWeight: FontWeight.w700, color: _kTextDark,
                                            )),
                                            Row(
                                              children: List.generate(5, (index) {
                                                return Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: index < r.rating.round() ? const Color(0xFFFACC15) : Colors.grey.shade300,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (r.comment.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      r.comment,
                                      style: const TextStyle(
                                        fontFamily: 'Inter', fontSize: 13,
                                        color: _kTextMuted, height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: reviews.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
