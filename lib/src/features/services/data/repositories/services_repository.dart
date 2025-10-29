import 'package:geolocator/geolocator.dart';
import '../models/service_provider.dart';

/// Repository mock para serviços baseado em localização GPS
/// Integra com dados simulados de empresas próximas
class ServicesRepository {
  // Dados mock de serviços por tipo
  static final Map<String, List<Map<String, dynamic>>> _mockServices = {
    'veterinary': [
      {
        'id': 'vet_1',
        'name': 'Clínica Veterinária São Francisco',
        'address': 'Rua das Flores, 123 - Centro',
        'latitude': -23.5505,
        'longitude': -46.6333,
        'phone': '(11) 3333-4444',
        'website': 'https://vetsfclinica.com.br',
        'rating': 4.5,
        'reviewCount': 127,
        'photos': [
          'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Vet+1',
        ],
        'description':
            'Clínica veterinária especializada em cães e gatos com atendimento 24h.',
        'serviceType': 'veterinary',
        'priceLevel': 3.0,
        'isOpen': true,
      },
      {
        'id': 'vet_2',
        'name': 'Hospital Veterinário PetCare',
        'address': 'Av. Paulista, 1500 - Bela Vista',
        'latitude': -23.5630,
        'longitude': -46.6565,
        'phone': '(11) 2222-3333',
        'rating': 4.8,
        'reviewCount': 89,
        'photos': [
          'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Vet+2',
        ],
        'description': 'Hospital veterinário com cirurgia e internação.',
        'serviceType': 'veterinary',
        'priceLevel': 4.0,
        'isOpen': false,
      },
    ],
    'pet_shop': [
      {
        'id': 'shop_1',
        'name': 'Pet Shop Amigo Fiel',
        'address': 'Rua Augusta, 800 - Consolação',
        'latitude': -23.5620,
        'longitude': -46.6520,
        'phone': '(11) 4444-5555',
        'rating': 4.2,
        'reviewCount': 203,
        'photos': [
          'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Shop+1',
        ],
        'description': 'Pet shop completo com ração, brinquedos e acessórios.',
        'serviceType': 'pet_shop',
        'priceLevel': 2.0,
        'isOpen': true,
      },
      {
        'id': 'shop_2',
        'name': 'Mega Pet Shopping',
        'address': 'Rua Oscar Freire, 200 - Jardins',
        'latitude': -23.5650,
        'longitude': -46.6580,
        'phone': '(11) 5555-6666',
        'rating': 4.6,
        'reviewCount': 156,
        'photos': [
          'https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Shop+2',
        ],
        'description': 'A maior pet shop da região com produtos importados.',
        'serviceType': 'pet_shop',
        'priceLevel': 3.0,
        'isOpen': true,
      },
    ],
    'grooming': [
      {
        'id': 'groom_1',
        'name': 'Banho & Tosa Elegante',
        'address': 'Rua da Consolação, 500 - Centro',
        'latitude': -23.5580,
        'longitude': -46.6450,
        'phone': '(11) 6666-7777',
        'rating': 4.7,
        'reviewCount': 94,
        'photos': [
          'https://via.placeholder.com/300x200/E91E63/FFFFFF?text=Groom+1',
        ],
        'description': 'Banho e tosa profissional com produtos premium.',
        'serviceType': 'grooming',
        'priceLevel': 2.0,
        'isOpen': true,
      },
      {
        'id': 'groom_2',
        'name': 'Pet Spa Luxury',
        'address': 'Alameda Santos, 300 - Jardins',
        'latitude': -23.5610,
        'longitude': -46.6540,
        'phone': '(11) 7777-8888',
        'rating': 4.9,
        'reviewCount': 67,
        'photos': [
          'https://via.placeholder.com/300x200/00BCD4/FFFFFF?text=Spa+1',
        ],
        'description': 'Spa completo para pets com massagem e aromaterapia.',
        'serviceType': 'grooming',
        'priceLevel': 4.0,
        'isOpen': true,
      },
    ],
    'pet_hotel': [
      {
        'id': 'hotel_1',
        'name': 'Hotel Pet Paradise',
        'address': 'Rua Brigadeiro Luís Antônio, 1200 - Bela Vista',
        'latitude': -23.5600,
        'longitude': -46.6480,
        'phone': '(11) 8888-9999',
        'rating': 4.4,
        'reviewCount': 78,
        'photos': [
          'https://via.placeholder.com/300x200/8BC34A/FFFFFF?text=Hotel+1',
        ],
        'description': 'Hotel para pets com playground e monitoramento 24h.',
        'serviceType': 'hotel',
        'priceLevel': 3.0,
        'isOpen': true,
      },
      {
        'id': 'hotel_2',
        'name': 'Pet Resort Premium',
        'address': 'Av. Faria Lima, 2000 - Itaim Bibi',
        'latitude': -23.5700,
        'longitude': -46.6800,
        'phone': '(11) 9999-0000',
        'rating': 4.8,
        'reviewCount': 45,
        'photos': [
          'https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Resort+1',
        ],
        'description': 'Resort de luxo para pets com piscina e day care.',
        'serviceType': 'hotel',
        'priceLevel': 4.0,
        'isOpen': true,
      },
    ],
  };

  /// Buscar serviços por tipo próximos à localização atual
  Future<List<ServiceProvider>> searchServicesByType(
    String serviceType, {
    Position? userLocation,
    double radiusKm = 100.0, // Raio bem grande
  }) async {
    try {
      // Se não tiver localização, usar localização padrão (São Paulo)
      final location =
          userLocation ??
          Position(
            latitude: -23.5505,
            longitude: -46.6333,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );

      // Simular delay de rede
      await Future.delayed(const Duration(milliseconds: 500));

      // Buscar serviços do tipo especificado
      final services = _mockServices[serviceType] ?? [];

      List<ServiceProvider> providers = [];

      for (final service in services) {
        // Calcular distância
        final distance =
            Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              service['latitude'].toDouble(),
              service['longitude'].toDouble(),
            ) /
            1000; // Converter para km

        // Sempre incluir (raio bem grande)
        providers.add(
          ServiceProvider(
            id: service['id'],
            name: service['name'],
            address: service['address'],
            latitude: service['latitude'].toDouble(),
            longitude: service['longitude'].toDouble(),
            phone: service['phone'],
            website: service['website'],
            rating: service['rating'].toDouble(),
            reviewCount: service['reviewCount'],
            photos: List<String>.from(service['photos']),
            description: service['description'],
            serviceType: service['serviceType'],
            priceLevel: service['priceLevel']?.toDouble(),
            isOpen: service['isOpen'],
            distanceKm: distance,
          ),
        );
      }

      // Ordenar por distância
      providers.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return providers;
    } catch (e) {
      print('Erro ao buscar serviços: $e');
      return [];
    }
  }

  /// Buscar todos os serviços próximos (todos os tipos)
  Future<List<ServiceProvider>> searchAllServicesNearby({
    Position? userLocation,
    double radiusKm = 10.0,
  }) async {
    final allServices = <ServiceProvider>[];

    for (final serviceType in _mockServices.keys) {
      final services = await searchServicesByType(
        serviceType,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );
      allServices.addAll(services);
    }

    // Ordenar por distância
    allServices.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return allServices;
  }

  /// Buscar detalhes de um serviço específico
  Future<ServiceProvider?> getServiceDetails(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    for (final services in _mockServices.values) {
      for (final service in services) {
        if (service['id'] == serviceId) {
          return ServiceProvider(
            id: service['id'],
            name: service['name'],
            address: service['address'],
            latitude: service['latitude'],
            longitude: service['longitude'],
            phone: service['phone'],
            website: service['website'],
            rating: service['rating'].toDouble(),
            reviewCount: service['reviewCount'],
            photos: List<String>.from(service['photos']),
            description: service['description'],
            serviceType: service['serviceType'],
            priceLevel: service['priceLevel']?.toDouble(),
            isOpen: service['isOpen'],
            distanceKm: 0.0, // Será calculado quando necessário
          );
        }
      }
    }

    return null;
  }
}
