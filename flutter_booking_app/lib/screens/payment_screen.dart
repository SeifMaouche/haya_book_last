import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';

// ── Payment Method Model ───────────────────────────────────────────
enum PaymentType { cib, edahabia, cash }

class SavedCard {
  final String id;
  final String holderName;
  final String lastFour;
  final String expiry;
  final PaymentType type;

  const SavedCard({
    required this.id,
    required this.holderName,
    required this.lastFour,
    required this.expiry,
    required this.type,
  });
}

// ── Payment Screen ─────────────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentType _selected = PaymentType.cash;
  String? _selectedCardId;
  bool _processing = false;

  // Mock saved cards — replace with real data from backend
  final List<SavedCard> _savedCards = const [
    SavedCard(
      id: '1',
      holderName: 'HASSAN BENALI',
      lastFour: '4291',
      expiry: '12/26',
      type: PaymentType.cib,
    ),
    SavedCard(
      id: '2',
      holderName: 'HASSAN BENALI',
      lastFour: '8831',
      expiry: '03/27',
      type: PaymentType.edahabia,
    ),
  ];

  Future<void> _confirmPayment() async {
    setState(() => _processing = true);
    // Simulate payment processing — replace with real API call
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _processing = false);
      Navigator.pushReplacementNamed(context, '/confirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final price = bp.selectedService?.price ?? 0;

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
                      width: 40, height: 40,
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
                        Text('Payment Methods',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark)),
                        Text('HAYABOOK ALGERIA',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40, height: 40,
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
                      child: const Icon(Icons.more_horiz_rounded,
                          size: 18, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Saved Cards ──────────────────────────────
                    if (_savedCards.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saved Cards',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark)),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/add-card'),
                            child: const Text('Manage',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _savedCards.length + 1,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 14),
                          itemBuilder: (_, i) {
                            if (i == _savedCards.length) {
                              // Add new card button
                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/add-card'),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.cardBorder,
                                        width: 1.5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded,
                                          color: AppColors.primary, size: 32),
                                      SizedBox(height: 8),
                                      Text('Add Card',
                                          style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final card = _savedCards[i];
                            final isChosen = _selectedCardId == card.id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedCardId = card.id;
                                _selected = card.type;
                              }),
                              child: _CreditCardWidget(
                                card: card,
                                isSelected: isChosen,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Select Payment Method ────────────────────
                    const Text('Select Payment Method',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const SizedBox(height: 14),

                    _PaymentMethodTile(
                      type: PaymentType.cib,
                      selected: _selected,
                      title: 'CIB / Interbank Card',
                      subtitle: 'Instant secure transaction',
                      icon: _CibIcon(),
                      onTap: () => setState(() {
                        _selected = PaymentType.cib;
                        _selectedCardId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodTile(
                      type: PaymentType.edahabia,
                      selected: _selected,
                      title: 'Edahabia (Algérie Poste)',
                      subtitle: 'Pay using your postal account',
                      icon: _EdahabiaIcon(),
                      onTap: () => setState(() {
                        _selected = PaymentType.edahabia;
                        _selectedCardId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodTile(
                      type: PaymentType.cash,
                      selected: _selected,
                      title: 'Cash on Arrival',
                      subtitle: 'Pay directly to the provider',
                      icon: _CashIcon(),
                      onTap: () => setState(() {
                        _selected = PaymentType.cash;
                        _selectedCardId = null;
                      }),
                    ),

                    const SizedBox(height: 28),

                    // ── Order Summary ────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _summaryRow('Service',
                              bp.selectedService?.name ?? 'Service'),
                          const SizedBox(height: 8),
                          _summaryRow('Provider',
                              bp.selectedProvider?.name ?? 'Provider'),
                          const SizedBox(height: 8),
                          _summaryRow('Date & Time',
                              bp.selectedDate != null && bp.selectedTimeSlot != null
                                  ? '${bp.selectedDate!.day}/${bp.selectedDate!.month}/${bp.selectedDate!.year} · ${bp.selectedTimeSlot}'
                                  : 'Not selected'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                                height: 1, color: AppColors.cardBorder),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark)),
                              Text('DZD ${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: AppColors.cardBorder, width: 1)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _processing ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99)),
                        elevation: 0,
                      ),
                      child: _processing
                          ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                          : Text(
                          _selected == PaymentType.cash
                              ? 'Confirm Booking'
                              : 'Continue to Payment',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 13,
                          color: AppColors.textLight),
                      const SizedBox(width: 4),
                      const Text('Your payment data is encrypted and stored securely.',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textMuted)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ),
      ],
    );
  }
}

// ── Credit Card Widget ─────────────────────────────────────────────
class _CreditCardWidget extends StatelessWidget {
  final SavedCard card;
  final bool isSelected;

  const _CreditCardWidget({required this.card, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final isCib = card.type == PaymentType.cib;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(isSelected ? 0.45 : 0.2),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 6)),
        ],
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.6), width: 2)
            : null,
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        isCib ? 'CIB CARD' : 'EDAHABIA',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                    ),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCib
                            ? Icons.contactless_rounded
                            : Icons.account_balance_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '•••• •••• •••• ${card.lastFour}',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.holderName,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(card.expiry,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Method Tile ────────────────────────────────────────────
class _PaymentMethodTile extends StatelessWidget {
  final PaymentType type;
  final PaymentType selected;
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.type,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon Widgets ───────────────────────────────────────────────────
class _CibIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text('CIB',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5)),
      ),
    );
  }
}

class _EdahabiaIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.payments_outlined,
          color: Color(0xFF16A34A), size: 26),
    );
  }
}