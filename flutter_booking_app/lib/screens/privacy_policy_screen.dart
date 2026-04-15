import 'package:flutter/material.dart';
import '../config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.textDark),
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text('HAYABOOK',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 1.5)),
                        Text('Privacy Policy',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Banner ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Icon(Icons.lock_rounded,
                                size: 90,
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LEGAL DOCUMENT',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.7),
                                      letterSpacing: 1.5)),
                              const SizedBox(height: 10),
                              const Text(
                                'Your privacy is\nour priority.',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Section 1: Data Collection ───────────────
                    _PolicySection(
                      icon: Icons.layers_outlined,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      title: 'Data Collection',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'At HayaBook, we collect information that you provide directly to us when you create an account, update your profile, or communicate with us.',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textMuted,
                                height: 1.6),
                          ),
                          const SizedBox(height: 14),
                          _bulletItem('Account details (Name, Email, Phone)'),
                          _bulletItem('Usage patterns and booking preferences'),
                          _bulletItem('Device information and IP addresses'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Section 2: Data Usage ────────────────────
                    _PolicySection(
                      icon: Icons.remove_red_eye_outlined,
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF16A34A),
                      title: 'Data Usage',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'We use the information we collect to provide, maintain, and improve our services, including to:',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textMuted,
                                height: 1.6),
                          ),
                          const SizedBox(height: 14),
                          _highlightBox(
                            label: 'PERSONALIZATION',
                            text:
                                'To tailor your booking experience based on your history.',
                          ),
                          const SizedBox(height: 10),
                          _highlightBox(
                            label: 'COMMUNICATION',
                            text:
                                'To send updates, security alerts, and administrative messages.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Section 3: User Rights ───────────────────
                    _PolicySection(
                      icon: Icons.group_outlined,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF59E0B),
                      title: 'User Rights',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You have control over your personal data. Under GDPR and CCPA guidelines, you have the right to:',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textMuted,
                                height: 1.6),
                          ),
                          const SizedBox(height: 14),
                          _rightsTile('Access your data'),
                          _rightsTile('Request data deletion'),
                          _rightsTile('Opt-out of tracking'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Section 4: Security ──────────────────────
                    const _PolicySection(
                      icon: Icons.shield_outlined,
                      iconBg: Color(0xFFF0F9FF),
                      iconColor: Color(0xFF0EA5E9),
                      title: 'Data Security',
                      child: Text(
                        'We implement industry-standard security measures including SSL encryption, secure servers, and regular security audits to protect your personal information from unauthorized access, alteration, or disclosure.',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Footer ───────────────────────────────────
                    const Center(
                      child: Column(
                        children: [
                          Text('Last updated: May 20, 2024',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textLight)),
                          SizedBox(height: 4),
                          Text('© 2024 HayaBook Inc. All rights reserved.',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 10),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _highlightBox({required String label, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.5)),
        ],
      ),
    );
  }

  Widget _rightsTile(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textDark)),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

// ── Policy Section Card ────────────────────────────────────────────
class _PolicySection extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget child;

  const _PolicySection({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
