import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/location_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/location_permission_widget.dart';
import '../widgets/custom_map_widget.dart';
import '../../data/models/service_provider.dart';

class ServicesMapScreen extends ConsumerStatefulWidget {
  final String serviceType;
  final String title;

  const ServicesMapScreen({
    super.key,
    required this.serviceType,
    required this.title,
  });

  @override
  ConsumerState<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends ConsumerState<ServicesMapScreen> {
  final List<MapMarker> _mapMarkers = [];
  ServiceProvider? _selectedService;
  bool _isBottomSheetExpanded = false;
  double _mapZoom = 14.0; // Zoom mais próximo para ver melhor os serviços
  // Coordenadas de São Paulo (onde estão os serviços mock)
  double _centerLat = -23.5505;
  double _centerLng = -46.6333;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
      // Backup: teste após 3 segundos se não carregar
      Future.delayed(const Duration(seconds: 3), () {
        final servicesState = ref.read(servicesNotifierProvider);
        if (servicesState.services.isEmpty) {
          print('⚠️ Forcing test data after 3 seconds timeout');
          _loadServices(); // Tentar novamente
        }
      });
    });
  }

  Future<void> _loadServices() async {
    // Carregar localização primeiro
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();

    final locationState = ref.read(locationNotifierProvider);

    // Carregar serviços baseado na localização com raio maior
    await ref
        .read(servicesNotifierProvider.notifier)
        .searchServicesByType(
          widget.serviceType,
          userLocation: locationState.position,
          radiusKm: 100.0, // Raio bem grande para garantir que encontre
        );

    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    final servicesState = ref.read(servicesNotifierProvider);
    final locationState = ref.read(locationNotifierProvider);
    final markers = <MapMarker>[];

    // Centralizar no usuário se GPS disponível, senão em São Paulo (onde estão os serviços)
    if (locationState.position != null) {
      // Se temos GPS, adicionar marker do usuário mas manter centro em São Paulo para demo
      markers.add(
        MapMarker(
          id: 'user_location',
          latitude: locationState.position!.latitude,
          longitude: locationState.position!.longitude,
          color: Colors.blue,
          icon: Icons.my_location,
          title: 'Sua localização',
        ),
      );
    }

    // Para demo, sempre centralizar em São Paulo onde estão os serviços
    // (em produção você buscaria serviços próximos à localização real do usuário)

    // Adicionar markers dos serviços com coordenadas GPS reais
    for (final service in servicesState.services) {
      markers.add(
        MapMarker(
          id: service.id,
          latitude: service.latitude,
          longitude: service.longitude,
          color: _getMarkerColor(widget.serviceType),
          icon: _getMarkerIcon(widget.serviceType),
          title: service.name,
          data: service,
        ),
      );
    }

    setState(() {
      _mapMarkers.clear();
      _mapMarkers.addAll(markers);
    });
  }

  Color _getMarkerColor(String serviceType) {
    switch (serviceType) {
      case 'veterinary':
        return Colors.red;
      case 'pet_shop':
        return Colors.green;
      case 'grooming':
        return Colors.orange;
      case 'pet_hotel':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMarkerIcon(String serviceType) {
    switch (serviceType) {
      case 'veterinary':
        return Icons.local_hospital;
      case 'pet_shop':
        return Icons.store;
      case 'grooming':
        return Icons.content_cut;
      case 'pet_hotel':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }

  void _selectService(ServiceProvider service) {
    setState(() {
      _selectedService = service;
      _centerLat = service.latitude;
      _centerLng = service.longitude;
      _mapZoom = 15.0; // Zoom mais próximo quando seleciona um serviço
    });
  }

  // Método temporariamente desabilitado até configurar Google Maps API
  // void _onMapCreated(GoogleMapController controller) {
  //   _mapController = controller;
  //
  //   // Posicionar câmera na localização do usuário ou padrão
  //   final locationState = ref.read(locationNotifierProvider);
  //   final position = locationState.position;
  //
  //   if (position != null) {
  //     controller.animateCamera(
  //       CameraUpdate.newLatLngZoom(
  //         LatLng(position.latitude, position.longitude),
  //         13.0,
  //       ),
  //     );
  //   } else {
  //     // Posição padrão (São Paulo)
  //     controller.animateCamera(
  //       CameraUpdate.newLatLngZoom(
  //         const LatLng(-23.5505, -46.6333),
  //         13.0,
  //       ),
  //     );
  //   }
  // }

  String _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'veterinary':
        return '🏥';
      case 'pet-shop':
        return '🛍️';
      case 'grooming':
        return '✂️';
      case 'pet-hotel':
        return '🏨';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesNotifierProvider);

    return LocationPermissionWidget(
      child: Scaffold(
        body: Stack(
          children: [
            // Mapa simulado (temporário até configurar API key)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  // Simulação de mapa
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[200]!, Colors.grey[400]!],
                      ),
                    ),
                  ),
                  // Mapa customizado
                  Positioned.fill(
                    child: CustomMapWidget(
                      centerLatitude: _centerLat,
                      centerLongitude: _centerLng,
                      zoom: _mapZoom,
                      markers: _mapMarkers,
                      onMarkerTap: (marker) {
                        if (marker.data != null &&
                            marker.data is ServiceProvider) {
                          _selectService(marker.data as ServiceProvider);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Botão de voltar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),

            // Botão de centralizar na localização
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 56,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _centerOnUserLocation,
                  icon: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            // Status de localização
            Positioned(
              top: MediaQuery.of(context).padding.top + 140,
              right: 16,
              child: const LocationStatusWidget(),
            ),

            // Cartão inferior com lista de serviços
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: _buildBottomCard(servicesState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(ServicesState servicesState) {
    final hasSelectedService = _selectedService != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: hasSelectedService
          ? (_isBottomSheetExpanded
                ? MediaQuery.of(context).size.height * 0.6
                : 200)
          : 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle do cartão
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (hasSelectedService)
            _buildSelectedServiceCard()
          else
            _buildServicesList(servicesState),
        ],
      ),
    );
  }

  Widget _buildSelectedServiceCard() {
    final service = _selectedService!;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do serviço selecionado
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: service.photos.isNotEmpty
                      ? Image.network(
                          service.photos.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.business),
                              ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.business),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('${service.distanceKm.toStringAsFixed(1)} km'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: service.isOpen ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.isOpen ? 'Aberto' : 'Fechado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isBottomSheetExpanded = !_isBottomSheetExpanded;
                    });
                  },
                  icon: Icon(
                    _isBottomSheetExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                  ),
                ),
              ],
            ),

            if (_isBottomSheetExpanded) ...[
              const SizedBox(height: 16),
              // Informações expandidas
              Text(
                service.address,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (service.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  service.description!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const Spacer(),
            ],

            const SizedBox(height: 16),
            // Botões de ação
            Row(
              children: [
                if (service.phone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(service.phone!),
                      icon: const Icon(Icons.phone),
                      label: const Text('Ligar'),
                    ),
                  ),

                if (service.phone != null) const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openDirections(service.latitude, service.longitude),
                    icon: const Icon(Icons.directions),
                    label: const Text('Rotas'),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewDetails(service),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Detalhes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(ServicesState servicesState) {
    return Expanded(
      child: Column(
        children: [
          // Header da lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_getServiceIcon(widget.serviceType)} ${widget.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${servicesState.services.length} encontrados',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Lista de serviços
          Expanded(
            child: servicesState.status == ServicesStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: servicesState.services.length,
                    itemBuilder: (context, index) {
                      final service = servicesState.services[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: service.photos.isNotEmpty
                                ? Image.network(
                                    service.photos.first,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.business,
                                                size: 20,
                                              ),
                                            ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.business, size: 20),
                                  ),
                          ),
                          title: Text(
                            service.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(service.rating.toStringAsFixed(1)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${service.distanceKm.toStringAsFixed(1)} km',
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: service.isOpen
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  service.isOpen ? 'Aberto' : 'Fechado',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectService(service),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _centerOnUserLocation() {
    // Simulação até Google Maps API ser configurada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Centralizar localização - Configure Google Maps API'),
      ),
    );
  }

  void _makePhoneCall(String phone) {
    // TODO: Implementar ligação
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ligando para $phone')));
  }

  void _openDirections(double lat, double lng) {
    // TODO: Abrir app de mapas para direções
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Abrindo direções...')));
  }

  void _viewDetails(ServiceProvider service) {
    Navigator.pushNamed(context, '/service-details', arguments: service.id);
  }
}

// Widget de status da localização (reutilizado)
class LocationStatusWidget extends ConsumerWidget {
  const LocationStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    switch (locationState.status) {
      case LocationStatus.initial:
        return const Chip(
          avatar: Icon(Icons.location_searching, size: 16),
          label: Text('Localização inicial'),
          backgroundColor: Colors.grey,
        );

      case LocationStatus.loading:
        return const Chip(
          avatar: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text('Buscando...'),
          backgroundColor: Colors.blue,
        );

      case LocationStatus.success:
        return const Chip(
          avatar: Icon(Icons.location_on, size: 16, color: Colors.white),
          label: Text('GPS ativo'),
          backgroundColor: Colors.green,
        );

      case LocationStatus.denied:
        return const Chip(
          avatar: Icon(Icons.location_off, size: 16, color: Colors.white),
          label: Text('GPS negado'),
          backgroundColor: Colors.red,
        );

      case LocationStatus.error:
        return const Chip(
          avatar: Icon(Icons.error, size: 16, color: Colors.white),
          label: Text('Erro GPS'),
          backgroundColor: Colors.orange,
        );
    }
  }
}
