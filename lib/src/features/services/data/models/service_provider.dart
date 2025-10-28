import 'package:json_annotation/json_annotation.dart';

part 'service_provider.g.dart';

@JsonSerializable()
class ServiceProvider {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final double rating;
  final int reviewCount;
  final List<String> photos;
  final String? description;
  final Map<String, dynamic>? openingHours;
  final String serviceType; // 'veterinary', 'pet_shop', 'grooming', 'hotel'
  final double? priceLevel; // 1-4 scale
  final bool isOpen;
  final double distanceKm;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    required this.rating,
    required this.reviewCount,
    required this.photos,
    this.description,
    this.openingHours,
    required this.serviceType,
    this.priceLevel,
    required this.isOpen,
    required this.distanceKm,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) => 
      _$ServiceProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderToJson(this);

  ServiceProvider copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? website,
    double? rating,
    int? reviewCount,
    List<String>? photos,
    String? description,
    Map<String, dynamic>? openingHours,
    String? serviceType,
    double? priceLevel,
    bool? isOpen,
    double? distanceKm,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      photos: photos ?? this.photos,
      description: description ?? this.description,
      openingHours: openingHours ?? this.openingHours,
      serviceType: serviceType ?? this.serviceType,
      priceLevel: priceLevel ?? this.priceLevel,
      isOpen: isOpen ?? this.isOpen,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  String toString() {
    return 'ServiceProvider{id: $id, name: $name, serviceType: $serviceType, rating: $rating, distanceKm: $distanceKm}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceProvider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}