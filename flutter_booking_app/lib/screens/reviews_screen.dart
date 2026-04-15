import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

import '../services/provider_service.dart';

// ── Data model ─────────────────────────────────────────────────────
class Review {
  final String id;
  final String authorName;
  final String initials;
  final Color avatarColor;
  final int stars;
  final String body;
  final String timeAgo;
  int likes;
  bool likedByMe;

  Review({
    required this.id,
    required this.authorName,
    required this.initials,
    required this.avatarColor,
    required this.stars,
    required this.body,
    required this.timeAgo,
    this.likes = 0,
    this.likedByMe = false,
  });
}

// ── ReviewsNotifier ────────────────────────────────────────────────
class ReviewsNotifier extends ChangeNotifier {
  final String providerId;
  final ProviderService _service = ProviderService();

  bool isLoading = true;
  String _sort = 'Recent';
  List<Review> _reviews = [];

  String get sort => _sort;

  ReviewsNotifier(this.providerId) {
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getProviderReviews(providerId);
      final palette = [
        AppColors.primary,
        const Color(0xFF3B82F6),
        const Color(0xFFF97316),
        const Color(0xFF8B5CF6),
        const Color(0xFF10B981),
      ];

      _reviews = data.asMap().entries.map((entry) {
        final i = entry.key;
        final json = entry.value;
        final client = json['client'] ?? {};
        final fName = client['firstName']?.toString() ?? '';
        final lName = client['lastName']?.toString() ?? '';
        final nameStr = '$fName $lName'.trim();
        final display = nameStr.isEmpty ? 'Anonymous' : nameStr;

        final initials = display
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

        final date = DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());

        return Review(
          id: json['id']?.toString() ?? i.toString(),
          authorName: display,
          initials: initials.isEmpty ? 'U' : initials,
          avatarColor: palette[i % palette.length],
          stars: (json['rating'] as num?)?.toInt() ?? 0,
          body: json['comment']?.toString() ?? '',
          timeAgo: _timeAgo(date),
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch reviews: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }

  List<Review> get reviews {
    final list = List<Review>.from(_reviews);
    if (_sort == 'Highest') {
      list.sort((a, b) => b.stars.compareTo(a.stars));
    } else if (_sort == 'Most Liked') {
      list.sort((a, b) => b.likes.compareTo(a.likes));
    }
    return list;
  }

  double get avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.stars).reduce((a, b) => a + b) / _reviews.length;
  }

  int get total => _reviews.length;

  double barFrac(int stars) {
    if (_reviews.isEmpty) return 0;
    return _reviews.where((r) => r.stars == stars).length / _reviews.length;
  }

  void setSort(String s) {
    _sort = s;
    notifyListeners();
  }

  void toggleLike(String id) {
    final i = _reviews.indexWhere((r) => r.id == id);
    if (i < 0) return;
    if (_reviews[i].likedByMe) {
      _reviews[i].likes--;
      _reviews[i].likedByMe = false;
    } else {
      _reviews[i].likes++;
      _reviews[i].likedByMe = true;
    }
    notifyListeners();
  }

  Future<bool> addReview(String name, int stars, String body) async {
    try {
      await _service.submitReview(
        providerProfileId: providerId,
        rating: stars.toDouble(),
        comment: body,
      );
      await _fetchReviews();
      return true;
    } catch (e) {
      return false;
    }
  }
}


// ── Screen ─────────────────────────────────────────────────────────
class ReviewsScreen extends StatelessWidget {
  final String providerName;
  final String providerId;

  const ReviewsScreen({
    Key? key,
    required this.providerName,
    required this.providerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsNotifier(providerId),
      child: _Body(providerName: providerName),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final String providerName;
  const _Body({required this.providerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reviews',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDark),
            onPressed: () {},
          )
        ],
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE5E7EB))),
      ),
      body: Consumer<ReviewsNotifier>(
        builder: (ctx, rn, _) => Stack(
          children: [
            // ── Scrollable content ───────────────────────────
            rn.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    children: [
                      _SummaryCard(rn: rn),
                      const SizedBox(height: 22),
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('User Testimonials',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                          _SortButton(rn: rn),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (rn.reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No reviews yet. Be the first!',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textMuted)),
                          ),
                        )
                      else
                        ...rn.reviews.map((r) => _ReviewCard(
                              r: r,
                              onLike: () => rn.toggleLike(r.id),
                              onReport: () => ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Review reported. Thank you!',
                                      style: TextStyle(fontFamily: 'Inter')),
                                  backgroundColor: AppColors.textMuted,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            )),
                    ],
                  ),

            // ── Write a Review sticky CTA ────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -3))
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWriteReview(ctx, rn),
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 18),
                    label: const Text('Write a Review',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Write a Review bottom sheet ─────────────────────────────────
  void _openWriteReview(BuildContext ctx, ReviewsNotifier rn) {
    final auth = Provider.of<AuthProvider>(ctx, listen: false);
    final nameCtrl = TextEditingController(text: auth.userName ?? '');
    final bodyCtrl = TextEditingController();
    int pickedStars = 5;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(sheet).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Write a Review',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Share your experience with others',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted)),
                const SizedBox(height: 22),

                // ── Star picker ────────────────────────────
                const Text('Your Rating',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setSheet(() => pickedStars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          i < pickedStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // ── Name field ─────────────────────────────
                const Text('Your Name',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                _field(nameCtrl, 'Full name', 1),
                const SizedBox(height: 16),

                // ── Body field ─────────────────────────────
                const Text('Your Review',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                _field(bodyCtrl,
                    'What did you like or dislike?', 4),
                const SizedBox(height: 24),

                // ── Submit ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final body = bodyCtrl.text.trim();
                      if (name.isEmpty || body.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: const Text('Please fill in all fields'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                        return;
                      }

                      // Show loading state
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: const Text('Submitting review...'),
                        backgroundColor: AppColors.textMuted,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));

                      final success = await rn.addReview(name, pickedStars, body);

                      if (success && ctx.mounted) {
                        Navigator.pop(sheet); // close bottom sheet
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: const Row(children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Review submitted! Thank you.',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600)),
                          ]),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                      } else if (!success && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: const Text('Failed to submit review. Try checking if you have completed bookings with this provider.'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99)),
                      elevation: 0,
                    ),
                    child: const Text('Submit Review',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, int lines) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textLight),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

// ── Rating Summary Card ────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final ReviewsNotifier rn;
  const _SummaryCard({required this.rn});

  @override
  Widget build(BuildContext context) {
    final avg = rn.avgRating;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big rating number
          Text(avg.toStringAsFixed(1),
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  height: 1.0)),
          const SizedBox(height: 8),
          // Stars
          Row(
            children: List.generate(5, (i) {
              final full = avg >= (i + 1);
              final half = !full && avg >= (i + 0.5);
              return Icon(
                full
                    ? Icons.star_rounded
                    : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFF59E0B),
                size: 26,
              );
            }),
          ),
          const SizedBox(height: 6),
          Text('${rn.total} Total Reviews',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textMuted)),
          const SizedBox(height: 20),

          // Rating bars 5→1
          ...List.generate(5, (i) {
            final stars = 5 - i;
            final frac = rn.barFrac(stars);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                    child: Text('$stars',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Stack(
                        children: [
                          Container(
                              height: 10,
                              color: const Color(0xFFDFF3F1)),
                          FractionallySizedBox(
                            widthFactor: frac.clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 34,
                    child: Text('${(frac * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Sort button ────────────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final ReviewsNotifier rn;
  const _SortButton({required this.rn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 16),
              const Text('Sort By',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...['Recent', 'Highest', 'Most Liked'].map((opt) {
                final sel = rn.sort == opt;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: sel
                              ? AppColors.primary
                              : AppColors.textDark)),
                  trailing: sel
                      ? const Icon(Icons.check,
                      color: AppColors.primary)
                      : null,
                  onTap: () {
                    rn.setSort(opt);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
      child: Row(
        children: [
          Text(rn.sort,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}

// ── Single Review Card ─────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review r;
  final VoidCallback onLike;
  final VoidCallback onReport;
  const _ReviewCard(
      {required this.r, required this.onLike, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              // Avatar circle with initials
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: r.avatarColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(r.initials,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: r.avatarColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.authorName,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    Text(r.timeAgo,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < r.stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Body ────────────────────────────────────────
          Text(r.body,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.55)),
          const SizedBox(height: 14),

          // ── Divider ─────────────────────────────────────
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),

          // ── Like + Report ────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      r.likedByMe
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      size: 18,
                      color: r.likedByMe
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text('${r.likes}',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: r.likedByMe
                                ? AppColors.primary
                                : AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onReport,
                child: const Row(
                  children: [
                    Icon(Icons.outlined_flag,
                        size: 16, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text('Report',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textLight)),
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