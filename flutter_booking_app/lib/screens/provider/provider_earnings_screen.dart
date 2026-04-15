// lib/screens/provider/provider_earnings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../widgets/glass_kit.dart';
import '../../widgets/provider_bottom_nav_bar.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryMid  = Color(0xFF7C3AED);
const _kTextDark    = Color(0xFF1E1B4B);
const _kTextMuted   = Color(0xFF6B7280);

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
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
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 20, left: 16, right: 16),
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
                    const Text('Earnings Dashboard', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 22,
                      fontWeight: FontWeight.w800, color: _kTextDark,
                      letterSpacing: -0.5,
                    )),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Consumer<ProviderStateProvider>(
                builder: (context, ps, _) {
                  final earnings = ps.stats.earnings;
                  return FadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _kPrimaryDeepGradient.colors.first,
                          gradient: _kPrimaryDeepGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: _kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Earnings', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 14,
                              fontWeight: FontWeight.w600, color: Colors.white70,
                            )),
                            const SizedBox(height: 8),
                            Text('\$${earnings.toStringAsFixed(2)}', style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 42,
                              fontWeight: FontWeight.w900, color: Colors.white,
                              letterSpacing: -1,
                            )),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _InfoDetail(label: 'Pending', value: '\$0.00'),
                                _InfoDetail(label: 'Withdrawn', value: '\$0.00'),
                                _InfoDetail(label: 'This Month', value: '\$${earnings.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Withdraw Funds', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 18,
                        fontWeight: FontWeight.w800, color: _kTextDark,
                        letterSpacing: -0.5,
                      )),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.account_balance_outlined, size: 48, color: _kPrimaryMid),
                            const SizedBox(height: 16),
                            const Text('Connect your bank account or PayPal to withdraw available funds.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: _kTextMuted),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Payment gateway integration pending.'),
                                    backgroundColor: _kPrimary,
                                  ));
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: _kPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Add Payout Method', style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 14,
                                  fontWeight: FontWeight.w700, color: Colors.white,
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
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

class _InfoDetail extends StatelessWidget {
  final String label;
  final String value;
  const _InfoDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 11,
          fontWeight: FontWeight.w500, color: Colors.white70,
        )),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 15,
          fontWeight: FontWeight.w800, color: Colors.white,
        )),
      ],
    );
  }
}

const _kPrimaryDeepGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)],
);
