import 'provider_model.dart';

class GlobalSearchResult {
  final String type; // 'provider' or 'service'
  final ServiceProvider provider;
  final Service? service; // Only present if type is 'service'

  GlobalSearchResult({
    required this.type,
    required this.provider,
    this.service,
  });

  factory GlobalSearchResult.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResult(
      type: json['type'] ?? 'provider',
      provider: ServiceProvider.fromBackendJson(json['provider'] ?? {}),
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }
}
