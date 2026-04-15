// lib/screens/provider/security_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kPrimary    = Color(0xFF6D28D9);
const _kBg         = Color(0xFFF8FAFC);
const _kTextDark   = Color(0xFF111827);
const _kTextMuted  = Color(0xFF6B7280);

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100, right: -100,
            child: _Blob(size: 300, color: _kPrimary.withOpacity(0.08)),
          ),
          
          Column(
            children: [
              _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SecurityCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your login credentials',
                      onTap: () {
                        // Implement password change flow
                      },
                    ),
                    const SizedBox(height: 16),
                    _SecurityCard(
                      icon: Icons.phonelink_lock_rounded,
                      title: 'Two-Factor Authentication',
                      subtitle: 'Add an extra layer of security',
                      trailing: Switch(
                        value: false,
                        onChanged: (v) {},
                        activeColor: _kPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SecurityCard(
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometric Login',
                      subtitle: 'Use FaceID or Fingerprint',
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: _kPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'ACTIVE SESSIONS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kTextMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SessionItem(
                      device: 'iPhone 15 Pro',
                      location: 'Paris, France • Current',
                      isCurrent: true,
                    ),
                    const SizedBox(height: 12),
                    _SessionItem(
                      device: 'MacBook Pro 16"',
                      location: 'Algiers, Algeria • 2 days ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, top + 12, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _kTextDark),
              ),
              const Expanded(
                child: Text('Security',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SecurityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _kPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kTextDark,
                      )),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _kTextMuted,
                      )),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.chevron_right_rounded, color: _kTextMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final String device;
  final String location;
  final bool isCurrent;

  const _SessionItem({
    required this.device,
    required this.location,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.devices_rounded, color: isCurrent ? _kPrimary : _kTextMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device, style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kTextDark,
                )),
                Text(location, style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _kTextMuted,
                )),
              ],
            ),
          ),
          if (!isCurrent)
            const Text('LOGOUT', style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.red,
              letterSpacing: 0.5,
            )),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    );
  }
}
