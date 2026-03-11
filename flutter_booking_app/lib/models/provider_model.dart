class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final double distance;
  final String phone;
  final String email;
  final String bio;
  final List<String> services;
  final List<WorkingHours> workingHours;
  final bool isVerified;
  final double averagePrice;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.distance,
    required this.phone,
    required this.email,
    required this.bio,
    required this.services,
    required this.workingHours,
    required this.isVerified,
    required this.averagePrice,
  });

  /// Returns the local asset image for this provider based on category.
  /// Use this everywhere instead of imageUrl for the 3 built-in providers.
  String get localImage {
    switch (category) {
      case 'Salon':
        return 'assets/images/salon.png';
      case 'Tutor':
        return 'assets/images/tutop.png';
      default: // Clinic
        return 'assets/images/doc.png';
    }
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      location: json['location'],
      distance: (json['distance'] as num).toDouble(),
      phone: json['phone'],
      email: json['email'],
      bio: json['bio'],
      services: List<String>.from(json['services']),
      workingHours: (json['workingHours'] as List)
          .map((e) => WorkingHours.fromJson(e))
          .toList(),
      isVerified: json['isVerified'],
      averagePrice: (json['averagePrice'] as num).toDouble(),
    );
  }
}

class WorkingHours {
  final String day;
  final String startTime;
  final String endTime;
  final bool isOpen;

  WorkingHours({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isOpen,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isOpen: json['isOpen'],
    );
  }
}

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'],
    );
  }
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
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
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}