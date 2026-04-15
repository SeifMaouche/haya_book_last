// lib/models/provider_model.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'provider_models.dart'; // Add this import

// ─────────────────────────────────────────────────────────────
// SERVICE PROVIDER
// ─────────────────────────────────────────────────────────────
class ServiceProvider {
  final String             id;
  final String             name;
  final String             category;
  final String             imageUrl;        // remote URL
  final double             rating;
  final int                reviewCount;
  final String             location;        // human-readable address text
  final LatLng?            locationLatLng;  // precise coordinates for map
  final double             distance;
  final String             phone;
  final String             email;
  final String             bio;
  final List<Service>      services;
  final List<DaySchedule>  workingHours;
  final bool               isVerified;
  final double             averagePrice;
  final String             userId; // Needed for messaging (User.id)
  final List<Review>       reviews;

  // ── Provider-uploaded media ──────────────────────────────────
  /// Logo / profile photo picked from device.
  final File?      logoFile;

  /// Portfolio / gallery photos uploaded by the provider (local files).
  final List<File> portfolioPhotos;

  /// Remote portfolio images from the backend (with IDs for deletion).
  final List<PortfolioImage> portfolio;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    this.locationLatLng,
    required this.distance,
    required this.phone,
    required this.email,
    required this.bio,
    required this.services,
    required this.workingHours,
    required this.isVerified,
    required this.averagePrice,
    required this.userId,
    this.reviews = const [],
    this.logoFile,
    List<File>? portfolioPhotos,
    List<PortfolioImage>? portfolio,
  }) : portfolioPhotos = portfolioPhotos ?? const [],
       portfolio       = portfolio       ?? const [];

  /// Avatar image to display.
  String get localImage {
    switch (category) {
      case 'Salon':
      case 'Beauty & Salon':
      case 'Beauty & Grooming':
        return 'assets/images/salon.png';
      case 'Tutor':
      case 'Tutoring':
        return 'assets/images/tutop.png';
      default:
        return 'assets/images/doc.png';
    }
  }

  bool get hasPortfolio => portfolioPhotos.isNotEmpty || portfolio.isNotEmpty;
  bool get hasLogo      => logoFile != null || imageUrl.isNotEmpty;

  ServiceProvider copyWith({
    String?     name,
    String?     category,
    String?     bio,
    String?     location,
    LatLng?     locationLatLng,
    File?       logoFile,
    List<File>? portfolioPhotos,
    List<PortfolioImage>? portfolio,
    double?     rating,
    int?        reviewCount,
    String?     userId,
  }) {
    return ServiceProvider(
      id:              id,
      name:            name            ?? this.name,
      category:        category        ?? this.category,
      imageUrl:        imageUrl,
      rating:          rating          ?? this.rating,
      reviewCount:     reviewCount     ?? this.reviewCount,
      location:        location        ?? this.location,
      locationLatLng:  locationLatLng  ?? this.locationLatLng,
      distance:        distance,
      phone:           phone,
      email:           email,
      bio:             bio             ?? this.bio,
      services:        services,
      workingHours:    workingHours,
      isVerified:      isVerified,
      averagePrice:    averagePrice,
      userId:          userId          ?? this.userId,
      logoFile:        logoFile        ?? this.logoFile,
      portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
      portfolio:       portfolio       ?? this.portfolio,
    );
  }

  factory ServiceProvider.fromBackendJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return ServiceProvider(
      id:           json['id']?.toString() ?? '',
      name:         json['businessName']?.toString() ?? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim(),
      category:     json['category']?.toString() ?? 'General',
      imageUrl:     user['profileImage']?.toString() ?? '',
      rating:       (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:  (json['reviewCount'] as num?)?.toInt() ?? 0,
      location:     json['address']?.toString() ?? 'No address',
      distance:     0.0,
      phone:        user['phone']?.toString() ?? '',
      email:        user['email']?.toString() ?? '',
      bio:          json['description']?.toString() ?? user['bio']?.toString() ?? '',
      services:     (json['services'] as List?)?.map((s) => Service.fromJson(s)).toList() ?? [],
      workingHours: _parseAvailability(json['workingHours'] ?? json['availability']),
      isVerified:   json['verificationStatus'] == 'VERIFIED' || 
                    json['verificationStatus'] == 'APPROVED' ||
                    json['verificationStatus'] == 'PENDING', // ✅ Allow dashboard access while pending
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      userId:       json['userId']?.toString() ?? '',
      portfolio:    (json['portfolio'] as List?)?.map((p) => PortfolioImage.fromJson(p)).toList() ?? [],
      reviews:      (json['reviewsReceived'] as List? ?? json['reviews'] as List?)?.map((r) => Review.fromJson(r)).toList() ?? [],
    );
  }

  static List<DaySchedule> _parseAvailability(dynamic availability) {
    if (availability == null) return [];
    try {
      dynamic result = availability;
      if (availability is String) {
        result = jsonDecode(availability);
      }
      
      if (result is List) {
        return result.map((item) => DaySchedule.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('--- [ProviderModel] availability parse error: $e ---');
      }
      return [];
    }
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
     return ServiceProvider(
      id:           json['id'] ?? '',
      name:         json['name'] ?? '',
      category:     json['category'] ?? '',
      imageUrl:     json['imageUrl'] ?? '',
      rating:       (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:  json['reviewCount'] ?? 0,
      location:     json['location'] ?? '',
      distance:     (json['distance'] as num?)?.toDouble() ?? 0.0,
      phone:        json['phone'] ?? '',
      email:        json['email'] ?? '',
      bio:          json['bio'] ?? '',
      services:     json['services'] != null ? List<Service>.from((json['services'] as List).map((x) => Service.fromJson(x))) : [],
      workingHours: _parseAvailability(json['workingHours'] ?? json['availability']),
      isVerified:   json['isVerified'] ?? false,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      userId:       json['userId'] ?? '',
      portfolio:    json['portfolio'] != null 
          ? (json['portfolio'] as List).map((e) => PortfolioImage.fromJson(e)).toList()
          : [],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PORTFOLIO IMAGE
// ─────────────────────────────────────────────────────────────
class PortfolioImage {
  final String id;
  final String url;

  PortfolioImage({required this.id, required this.url});

  factory PortfolioImage.fromJson(Map<String, dynamic> json) {
    return PortfolioImage(
      id:  json['id'].toString(),
      url: json['imageUrl'] ?? json['url'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WORKING HOURS
// ─────────────────────────────────────────────────────────────
class WorkingHours {
  final String day;
  final String startTime;
  final String endTime;
  final bool   isOpen;

  WorkingHours({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isOpen,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      day:       json['day'],
      startTime: json['startTime'],
      endTime:   json['endTime'],
      isOpen:    json['isOpen'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────
class Service {
  final String  id;
  final String  name;
  final String  description;
  final double  price;
  final int     durationMinutes;
  final bool    isDraft;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.isDraft = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id:              json['id']?.toString() ?? '',
      name:            json['name']?.toString() ?? 'Unknown Service',
      description:     json['description']?.toString() ?? '',
      price:           (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      isDraft:         json['isDraft'] == true || json['isDraft'] == 'true',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REVIEW
// ─────────────────────────────────────────────────────────────
class Review {
  final String   id;
  final String   userId;
  final String   userName;
  final String   userImage;
  final double   rating;
  final String   comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final client = json['client'] ?? {};
    return Review(
      id:        json['id']?.toString() ?? '',
      userId:    json['clientId']?.toString() ?? '',
      userName:  "${client['firstName'] ?? ''} ${client['lastName'] ?? ''}".trim().isEmpty 
                   ? 'Anonymous' 
                   : "${client['firstName'] ?? ''} ${client['lastName'] ?? ''}".trim(),
      userImage: client['profileImage'] ?? '',
      rating:    (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment:   json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}