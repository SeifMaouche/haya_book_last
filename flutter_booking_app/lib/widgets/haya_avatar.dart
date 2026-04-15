import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../config/theme.dart';

class HayaAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;
  final bool isProvider;
  final double borderRadius;
  final String? name;

  const HayaAvatar({
    Key? key,
    this.avatarUrl,
    this.name,
    this.size = 50,
    this.onTap,
    this.isProvider = false,
    this.borderRadius = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Treat null, empty, or "default" as the instant gradient state
    final bool isDefault = avatarUrl == null || avatarUrl!.isEmpty || avatarUrl == 'default';

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDefault ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: isDefault
            ? _buildInstantGradient()
            : CachedNetworkImage(
                imageUrl: AppConfig.getMediaUrl(avatarUrl!),
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInstantGradient(),
                errorWidget: (context, url, error) => _buildInstantGradient(),
              ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInstantGradient() {
    final initials = _getInitials();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProvider 
            ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)] // Purple/Violet for Providers
            : [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // Blue for Clients
        ),
      ),
      child: Center(
        child: initials != null 
          ? Text(
              initials,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: -0.5,
              ),
            )
          : Icon(
              Icons.person_rounded,
              color: Colors.white.withOpacity(0.9),
              size: size * 0.6,
            ),
      ),
    );
  }

  String? _getInitials() {
    if (name == null || name!.isEmpty) return null;
    final parts = name!.trim().split(' ');
    if (parts.isEmpty) return null;
    
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
