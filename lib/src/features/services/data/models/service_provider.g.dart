// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProvider _$ServiceProviderFromJson(Map<String, dynamic> json) =>
    ServiceProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      openingHours: json['openingHours'] as Map<String, dynamic>?,
      serviceType: json['serviceType'] as String,
      priceLevel: (json['priceLevel'] as num?)?.toDouble(),
      isOpen: json['isOpen'] as bool,
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );

Map<String, dynamic> _$ServiceProviderToJson(ServiceProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'website': instance.website,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'photos': instance.photos,
      'description': instance.description,
      'openingHours': instance.openingHours,
      'serviceType': instance.serviceType,
      'priceLevel': instance.priceLevel,
      'isOpen': instance.isOpen,
      'distanceKm': instance.distanceKm,
    };
