import 'package:flutter/material.dart';
import '../config/theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({Key? key}) : super(key: key);

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchCtrl = TextEditingController();
  int? _openIndex = 0;

  final _faqs = [
    {
      'q': 'How to book an appointment?',
      'a': "To book an appointment, simply browse our list of service providers, select an available time slot that works for you, and click 'Confirm Booking'. You'll receive an instant confirmation via email and app notification.",
    },
    {
      'q': 'What is the cancellation policy?',
      'a': 'You can cancel your appointment up to 24 hours before the scheduled time for a full refund. Cancellations within 24 hours may incur a fee of up to 50% of the service cost.',
    },
    {
      'q': 'Can I reschedule my booking?',
      'a': 'Yes! Go to My Bookings, select the appointment, and tap "Reschedule" to choose a new date and time slot. Rescheduling is free up to 2 hours before the appointment.',
    },
    {
      'q': 'How do I contact a provider?',
      'a': "You can message a provider directly through in-app messaging. Open the provider's profile and tap the Message button, or go to your booking details and use the contact option.",
    },
  ];

  List<Map<String, String>> get _filtered {
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return List.from(_faqs);
    return _faqs
        .where((f) =>
    f['q']!.toLowerCase().contains(q) ||
        f['a']!.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
        title: const Text('Help & FAQ',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────
            const Text('How can we help?',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 18),

            // ── Search bar ────────────────────────────────────
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.search,
                        color: AppColors.primary, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textDark),
                      decoration: const InputDecoration(
                        hintText: 'Search for answers, topics...',
                        hintStyle: TextStyle(
                            color: AppColors.textLight, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Section label ─────────────────────────────────
            const Text('FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8)),
            const SizedBox(height: 12),

            // ── Accordion ─────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(filtered.length, (i) {
                  final isOpen = _openIndex == i;
                  final isLast = i == filtered.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(
                                () => _openIndex = isOpen ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 17),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(filtered[i]['q']!,
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: isOpen
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: AppColors.textDark)),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isOpen)
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFF8FFFE),
                          padding:
                          const EdgeInsets.fromLTRB(18, 2, 18, 18),
                          child: Text(filtered[i]['a']!,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                  height: 1.65)),
                        ),
                      if (!isLast)
                        const Divider(
                            height: 1, color: AppColors.cardBorder),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // ── Need more help card ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_outlined,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text('Need more help?',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is available 24/7 to assist you with any questions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/contact-us'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99)),
                        elevation: 0,
                      ),
                      child: const Text('Contact Us  →',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
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