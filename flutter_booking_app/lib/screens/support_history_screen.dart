// lib/screens/support_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';

class SupportHistoryScreen extends StatefulWidget {
  const SupportHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SupportHistoryScreen> createState() => _SupportHistoryScreenState();
}

class _SupportHistoryScreenState extends State<SupportHistoryScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final resp = await apiClient.dio.get('/contact/my-messages');
      setState(() {
        _messages = resp.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load history. Please pull to refresh.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isClient = auth.userType == 'client';
    final themeColor = isClient ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Support History',
            style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: _buildBody(themeColor, isClient),
    );
  }

  Widget _buildBody(Color color, bool isClient) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: color));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontFamily: 'Inter', color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchHistory,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Retry'),
          ),
        ]),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.mail_outline_rounded, color: color, size: 38),
          ),
          const SizedBox(height: 20),
          const Text('No Tickets Yet',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text("Any support requests you send will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: color,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, index) {
          final msg = _messages[index];
          return _SupportCard(msg: msg, themeColor: color);
        },
      ),
    );
  }
}

class _SupportCard extends StatefulWidget {
  final dynamic msg;
  final Color themeColor;
  const _SupportCard({required this.msg, required this.themeColor});

  @override
  State<_SupportCard> createState() => _SupportCardState();
}

class _SupportCardState extends State<_SupportCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isResolved = widget.msg['status'] == 'RESOLVED';
    final DateTime dt = DateTime.parse(widget.msg['createdAt']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(widget.msg['subject'] ?? 'No Subject',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ),
                    _StatusBadge(isResolved: isResolved),
                  ],
                ),
                const SizedBox(height: 6),
                Text("${dt.day}/${dt.month}/${dt.year}",
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 12),
                Text(widget.msg['message'] ?? '',
                    maxLines: _expanded ? 100 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted, height: 1.5)),
                if (_expanded && widget.msg['reply'] != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.auto_awesome, color: widget.themeColor, size: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text('ADMIN RESPONSE',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(widget.msg['reply'],
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: widget.themeColor.withAlpha(200), height: 1.5)),
                  ),
                ],
                if (!_expanded) 
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(isResolved ? "View Reply" : "Tap to expand",
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: widget.themeColor)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isResolved;
  const _StatusBadge({required this.isResolved});

  @override
  Widget build(BuildContext context) {
    final color = isResolved ? const Color(0xFF10B981) : const Color(0xFFF7B919);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isResolved ? 'RESOLVED' : 'PENDING',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
