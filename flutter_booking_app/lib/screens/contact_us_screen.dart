import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';
import 'support_history_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final subject = _subjectCtrl.text.trim();
    final message = _msgCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please fill in Subject and Message'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _sending = true);
    try {
      // ✅ FIX C-contact: Real API call — previously was a fake Future.delayed
      await apiClient.dio.post('/contact', data: {
        'subject': subject,
        'message': message,
      });
      if (!mounted) return;
      _subjectCtrl.clear();
      _msgCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text("Message sent! We'll reply within 24h.",
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to send message. Please try again.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth       = Provider.of<AuthProvider>(context, listen: false);
    final isClient   = auth.userType == 'client';
    final themeColor = isClient ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.primary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Contact Us',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: themeColor, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportHistoryScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
        child: Column(
          children: [
            // ── App logo ──────────────────────────────────────
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  color: isClient ? AppColors.primary : AppColors.secondary,
                  child: Center(
                    child: Icon(
                        isClient ? Icons.calendar_today_outlined : Icons.business_center_outlined,
                        color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Headline ──────────────────────────────────────
            Text(
              isClient 
                ? 'How can we help with\nyour booking?' 
                : 'How can we help with\nyour business?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              isClient
                ? 'Our support team is here to assist you with scheduling, clinics, salons, or tutoring sessions.'
                : 'Need help with your services, profile, or payments? Our provider support team is ready to help.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5),
            ),
            const SizedBox(height: 28),

            // ── Live Chat button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Connecting to live chat...'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline,
                    color: Colors.white, size: 20),
                label: const Text('Start Live Chat',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── OR EMAIL US divider ───────────────────────────
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('OR EMAIL US',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withOpacity(0.75),
                          letterSpacing: 0.8)),
                ),
                const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
              ],
            ),
            const SizedBox(height: 22),

            // ── Subject ───────────────────────────────────────
            _label('SUBJECT'),
            const SizedBox(height: 8),
            _field(_subjectCtrl, "What's this about?", 1),
            const SizedBox(height: 16),

            // ── Message ───────────────────────────────────────
            _label('MESSAGE'),
            const SizedBox(height: 8),
            _field(_msgCtrl, 'How can we assist you today?', 5),
            const SizedBox(height: 24),

            // ── Send Email ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                  AppColors.primary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                  elevation: 0,
                ),
                child: _sending
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                    : const Text('Send Email',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),

            // ── Follow us ─────────────────────────────────────
            Text('FOLLOW US',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withOpacity(0.75),
                    letterSpacing: 0.8)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _social(Icons.language_outlined),
                const SizedBox(width: 18),
                _social(Icons.share_outlined),
                const SizedBox(width: 18),
                _social(Icons.mail_outline_rounded),
                const SizedBox(width: 18),
                _social(Icons.rss_feed_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.8)),
  );

  Widget _field(
      TextEditingController ctrl, String hint, int maxLines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textLight),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _social(IconData icon) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.cardBorder),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Icon(icon, color: AppColors.primary, size: 20),
  );
}