// lib/screens/provider/provider_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';

class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _weekLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  // Mock appointments for selected day
  final List<Map<String, dynamic>> _appointments = [
    {
      'title': 'Full Glam Transformation',
      'client': 'Aria Montgomery',
      'time': '08:30',
      'hour': 8,
      'duration': 1,
      'priority': false,
      'active': false,
    },
    {
      'title': 'Signature Hair Styling',
      'client': 'Sarah Jenkins',
      'time': '09:45',
      'hour': 9,
      'duration': 2,
      'priority': true,
      'active': true,
    },
    {
      'title': 'Bridal Trial Package',
      'client': 'David Chen',
      'time': '12:15',
      'hour': 11,
      'duration': 1,
      'priority': false,
      'active': false,
      'online': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTimeGrid(),
                  _buildBottomActions(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProviderBottomNavBar(
        currentIndex: 2,
        onTap: (i) => navigateProviderTab(context, i),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white.withOpacity(0.4),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HayaBook',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E1065))),
                        Text('PROVIDER SCHEDULE',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                                letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: AppColors.textDark, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Month + nav
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_months[_weekStart.month]} ${_weekStart.year}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E1065)),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _prevWeek,
                        child: const Icon(Icons.chevron_left_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _nextWeek,
                        child: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Week day selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final day = _weekDays[i];
                  final isSelected = day.day == _selectedDate.day &&
                      day.month == _selectedDate.month;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40, height: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekLabels[i],
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textLight,
                                letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${day.day}'.padLeft(2, '0'),
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    const hours = [8, 9, 10, 11, 12, 13, 14];
    const rowH = 80.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels
          Column(
            children: hours
                .map((h) => SizedBox(
              height: rowH,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${h.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight),
                ),
              ),
            ))
                .toList(),
          ),
          // Grid + appointments
          Expanded(
            child: Stack(
              children: [
                // Grid lines
                Column(
                  children: hours
                      .map((h) => Container(
                    height: rowH,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color:
                            AppColors.primary.withOpacity(0.08)),
                      ),
                    ),
                  ))
                      .toList(),
                ),

                // Appointments
                ..._appointments.map((appt) {
                  final topOffset =
                      (appt['hour'] - 8) * rowH + 6.0;
                  final height = appt['duration'] * rowH - 12.0;

                  return Positioned(
                    top: topOffset,
                    left: 4,
                    right: 0,
                    child: _AppointmentBlock(
                      title: appt['title'],
                      client: appt['client'],
                      time: appt['time'],
                      height: height,
                      isPriority: appt['priority'] ?? false,
                      isActive: appt['active'] ?? false,
                      isOnline: appt['online'] ?? false,
                    ),
                  );
                }).toList(),

                // Current time indicator (mock at 9:30 = 1.5 hours from 8)
                Positioned(
                  top: 1.5 * rowH - 1,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: Colors.red.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Block Time',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Appointment Block ──────────────────────────────────────────────
class _AppointmentBlock extends StatelessWidget {
  final String title;
  final String client;
  final String time;
  final double height;
  final bool isPriority;
  final bool isActive;
  final bool isOnline;

  const _AppointmentBlock({
    required this.title,
    required this.client,
    required this.time,
    required this.height,
    required this.isPriority,
    required this.isActive,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 4),
          top: BorderSide(
              color: AppColors.primary.withOpacity(0.15), width: 1),
          right: BorderSide(
              color: AppColors.primary.withOpacity(0.15), width: 1),
          bottom: BorderSide(
              color: AppColors.primary.withOpacity(0.15), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            decoration: isActive
                                ? TextDecoration.lineThrough
                                : null)),
                    const SizedBox(height: 2),
                    Text('$client • $time',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (isPriority)
                const Icon(Icons.emergency_rounded,
                    color: AppColors.primary, size: 14)
              else if (isOnline)
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFF16A34A), shape: BoxShape.circle),
                )
              else
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 14),
            ],
          ),
          if (isPriority)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 1.5)),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 10),
                    ),
                    const SizedBox(width: -4),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('+2',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text('PRIORITY',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}