import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Estados de localização
enum LocationStatus { initial, loading, success, denied, error }

// Estado da localização
class LocationState {
  final LocationStatus status;
  final Position? position;
  final String? errorMessage;

  const LocationState({required this.status, this.position, this.errorMessage});

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      errorMessage: errorMessage,
    );
  }
}

// Provider para gerenciar localização
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
    : super(const LocationState(status: LocationStatus.initial));

  /// Solicitar permissão de localização
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();

      if (permission.isGranted) {
        return true;
      } else if (permission.isDenied) {
        state = state.copyWith(
          status: LocationStatus.denied,
          errorMessage: 'Permissão de localização negada',
        );
        return false;
      } else if (permission.isPermanentlyDenied) {
        state = state.copyWith(
          status: LocationStatus.denied,
          errorMessage:
              'Permissão de localização permanentemente negada. Ative nas configurações.',
        );
        return false;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Erro ao solicitar permissão: $e',
      );
      return false;
    }
  }

  /// Obter localização atual
  Future<void> getCurrentLocation() async {
    state = state.copyWith(status: LocationStatus.loading);

    try {
      // Verificar se localização está ativa
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage:
              'Serviço de localização desativado. Ative nas configurações.',
        );
        return;
      }

      // Verificar permissão
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return; // Estado já atualizado em requestLocationPermission
      }

      // Obter posição atual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        status: LocationStatus.success,
        position: position,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Erro ao obter localização: $e',
      );
    }
  }

  /// Calcular distância entre dois pontos
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // em km
  }

  /// Verificar se usuário está próximo de uma localização
  bool isNearLocation(
    double targetLat,
    double targetLon, {
    double radiusKm = 1.0,
  }) {
    if (state.position == null) return false;

    final distance = calculateDistance(
      state.position!.latitude,
      state.position!.longitude,
      targetLat,
      targetLon,
    );

    return distance <= radiusKm;
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider da localização
final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
      return LocationNotifier();
    });
