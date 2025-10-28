import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/service_provider.dart';
import '../../data/repositories/services_repository.dart';

// Estados de busca de serviços
enum ServicesStatus {
  initial,
  loading,
  success,
  error,
}

// Estado dos serviços
class ServicesState {
  final ServicesStatus status;
  final List<ServiceProvider> services;
  final String? errorMessage;
  final String? currentServiceType;

  const ServicesState({
    required this.status,
    required this.services,
    this.errorMessage,
    this.currentServiceType,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceProvider>? services,
    String? errorMessage,
    String? currentServiceType,
  }) {
    return ServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage,
      currentServiceType: currentServiceType ?? this.currentServiceType,
    );
  }
}

// Provider do repositório
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository();
});

// Notifier para gerenciar serviços
class ServicesNotifier extends StateNotifier<ServicesState> {
  final ServicesRepository _repository;

  ServicesNotifier(this._repository) 
      : super(const ServicesState(
          status: ServicesStatus.initial,
          services: [],
        ));

  /// Buscar serviços por tipo
  Future<void> searchServicesByType(
    String serviceType, {
    Position? userLocation,
    double radiusKm = 50.0, // Aumentar raio para debug
  }) async {
    state = state.copyWith(
      status: ServicesStatus.loading,
      currentServiceType: serviceType,
    );

    try {
      final services = await _repository.searchServicesByType(
        serviceType,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );

      state = state.copyWith(
        status: ServicesStatus.success,
        services: services,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: 'Erro ao buscar serviços: $e',
      );
    }
  }

  /// Buscar todos os serviços próximos
  Future<void> searchAllServicesNearby({
    Position? userLocation,
    double radiusKm = 10.0,
  }) async {
    state = state.copyWith(
      status: ServicesStatus.loading,
      currentServiceType: 'all',
    );

    try {
      final services = await _repository.searchAllServicesNearby(
        userLocation: userLocation,
        radiusKm: radiusKm,
      );

      state = state.copyWith(
        status: ServicesStatus.success,
        services: services,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: 'Erro ao buscar serviços: $e',
      );
    }
  }

  /// Filtrar serviços por rating mínimo
  void filterByRating(double minRating) {
    final filteredServices = state.services
        .where((service) => service.rating >= minRating)
        .toList();

    state = state.copyWith(services: filteredServices);
  }

  /// Filtrar serviços por distância máxima
  void filterByDistance(double maxDistanceKm) {
    final filteredServices = state.services
        .where((service) => service.distanceKm <= maxDistanceKm)
        .toList();

    state = state.copyWith(services: filteredServices);
  }

  /// Filtrar serviços apenas abertos
  void filterOnlyOpen() {
    final filteredServices = state.services
        .where((service) => service.isOpen)
        .toList();

    state = state.copyWith(services: filteredServices);
  }

  /// Ordenar serviços
  void sortServices(String sortBy) {
    final services = List<ServiceProvider>.from(state.services);

    switch (sortBy) {
      case 'distance':
        services.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 'rating':
        services.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        services.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'reviews':
        services.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    state = state.copyWith(services: services);
  }

  /// Limpar serviços
  void clearServices() {
    state = state.copyWith(
      status: ServicesStatus.initial,
      services: [],
      errorMessage: null,
      currentServiceType: null,
    );
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider dos serviços
final servicesNotifierProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  final repository = ref.read(servicesRepositoryProvider);
  return ServicesNotifier(repository);
});

// Provider para obter detalhes de um serviço específico
final serviceDetailsProvider = FutureProvider.family<ServiceProvider?, String>((ref, serviceId) async {
  final repository = ref.read(servicesRepositoryProvider);
  return await repository.getServiceDetails(serviceId);
});