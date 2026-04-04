// lib/models/provider_model.dart
import 'dart:io';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────────────────────
// SERVICE PROVIDER
// ─────────────────────────────────────────────────────────────
class ServiceProvider {
  final String             id;
  final String             name;
  final String             category;
  final String             imageUrl;        // remote URL (future backend)
  final double             rating;
  final int                reviewCount;
  final String             location;        // human-readable address text
  final LatLng?            locationLatLng;  // precise coordinates for map
  final double             distance;
  final String             phone;
  final String             email;
  final String             bio;
  final List<String>       services;
  final List<WorkingHours> workingHours;
  final bool               isVerified;
  final double             averagePrice;

  // ── Provider-uploaded media ──────────────────────────────────
  /// Logo / profile photo picked from device.
  final File?      logoFile;

  /// Portfolio / gallery photos uploaded by the provider.
  final List<File> portfolioPhotos;

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
    this.logoFile,
    List<File>? portfolioPhotos,
  }) : portfolioPhotos = portfolioPhotos ?? const [];

  /// Avatar image to display.
  /// Priority: real picked file → local asset fallback.
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

  bool get hasPortfolio => portfolioPhotos.isNotEmpty;
  bool get hasLogo      => logoFile != null;

  ServiceProvider copyWith({
    String?     name,
    String?     category,
    String?     bio,
    String?     location,
    LatLng?     locationLatLng,
    File?       logoFile,
    List<File>? portfolioPhotos,
    double?     rating,
    int?        reviewCount,
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
      logoFile:        logoFile        ?? this.logoFile,
      portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
    );
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id:           json['id'],
      name:         json['name'],
      category:     json['category'],
      imageUrl:     json['imageUrl'],
      rating:       (json['rating'] as num).toDouble(),
      reviewCount:  json['reviewCount'],
      location:     json['location'],
      distance:     (json['distance'] as num).toDouble(),
      phone:        json['phone'],
      email:        json['email'],
      bio:          json['bio'],
      services:     List<String>.from(json['services']),
      workingHours: (json['workingHours'] as List)
          .map((e) => WorkingHours.fromJson(e))
          .toList(),
      isVerified:   json['isVerified'],
      averagePrice: (json['averagePrice'] as num).toDouble(),
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
  final String id;
  final String name;
  final String description;
  final double price;
  final int    durationMinutes;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id:              json['id'],
      name:            json['name'],
      description:     json['description'],
      price:           (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'],
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
  final double   rating;
  final String   comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id:        json['id'],
      userId:    json['userId'],
      userName:  json['userName'],
      rating:    (json['rating'] as num).toDouble(),
      comment:   json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
// NOTE: TimeSlot lives in booking_model.dart — do NOT redeclare it here.