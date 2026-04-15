// lib/screens/provider/help_support_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';

const _kPrimary    = Color(0xFF6D28D9);
const _kBg         = Color(0xFFF8FAFC);
const _kTextDark   = Color(0xFF111827);
const _kTextMuted  = Color(0xFF6B7280);

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Decorative Background
          Positioned(
            bottom: -60, left: -60,
            child: _Blob(size: 260, color: _kPrimary.withOpacity(0.06)),
          ),
          
          Column(
            children: [
              _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for help...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search_rounded, color: _kTextMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('QUICK HELP', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _kTextMuted, letterSpacing: 1.2,
                    )),
                    const SizedBox(height: 12),
                    _SupportOption(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Live Chat',
                      subtitle: 'Speak with our support team',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _SupportOption(
                      icon: Icons.email_outlined,
                      title: 'Email Support',
                      subtitle: 'support@hayabook.com',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _SupportOption(
                      icon: Icons.menu_book_rounded,
                      title: 'Provider Guidelines',
                      subtitle: 'How to manage your services',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 32),
                    
                    const Text('POPULAR TOPICS', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _kTextMuted, letterSpacing: 1.2,
                    )),
                    const SizedBox(height: 12),
                    _FAQItem(question: 'How do I withdraw my earnings?'),
                    _FAQItem(question: 'Can I set different prices for weekends?'),
                    _FAQItem(question: 'What happens if a client doesn\'t show up?'),
                    _FAQItem(question: 'How do I change my business category?'),
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
                child: Text('Help & Support',
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

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SupportOption({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
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
                Text(subtitle, style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _kTextMuted,
                )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _kTextMuted),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  const _FAQItem({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(question, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: _kTextDark,
          ))),
          const Icon(Icons.add_rounded, size: 18, color: _kTextMuted),
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
