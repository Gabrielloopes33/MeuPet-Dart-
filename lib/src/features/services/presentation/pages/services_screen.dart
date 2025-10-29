import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/service_card.dart';
import '../widgets/service_filters.dart';
import '../widgets/location_permission_widget.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  final String serviceType;
  final String title;

  const ServicesScreen({
    super.key,
    required this.serviceType,
    required this.title,
  });

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  bool _showFilters = false;
  double _radiusKm = 10.0;
  double _minRating = 0.0;
  bool _onlyOpen = false;
  String _sortBy = 'distance';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  Future<void> _loadServices() async {
    // Obter localização atual
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    
    final locationState = ref.read(locationNotifierProvider);
    
    // Buscar serviços do tipo especificado
    await ref.read(servicesNotifierProvider.notifier).searchServicesByType(
      widget.serviceType,
      userLocation: locationState.position,
      radiusKm: _radiusKm,
    );
  }

  void _applyFilters() {
    final notifier = ref.read(servicesNotifierProvider.notifier);
    
    // Aplicar filtros
    if (_minRating > 0) {
      notifier.filterByRating(_minRating);
    }
    
    if (_onlyOpen) {
      notifier.filterOnlyOpen();
    }
    
    notifier.filterByDistance(_radiusKm);
    notifier.sortServices(_sortBy);
    
    setState(() {
      _showFilters = false;
    });
  }

  String _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'veterinary':
        return '🏥';
      case 'pet_shop':
        return '🏪';
      case 'grooming':
        return '✂️';
      case 'hotel':
        return '🏨';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    return LocationPermissionWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_getServiceIcon(widget.serviceType)} ${widget.title}'),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const LocationStatusWidget(),
                  const Spacer(),
                  Text(
                    '${servicesState.services.length} serviços',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadServices,
            ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de localização
          if (locationState.status == LocationStatus.loading)
            const LinearProgressIndicator(),
          
          // Filtros (expansível)
          if (_showFilters)
            ServiceFilters(
              radiusKm: _radiusKm,
              minRating: _minRating,
              onlyOpen: _onlyOpen,
              sortBy: _sortBy,
              onRadiusChanged: (value) => setState(() => _radiusKm = value),
              onRatingChanged: (value) => setState(() => _minRating = value),
              onOnlyOpenChanged: (value) => setState(() => _onlyOpen = value),
              onSortChanged: (value) => setState(() => _sortBy = value),
              onApplyFilters: _applyFilters,
            ),

          // Lista de serviços
          Expanded(
            child: _buildServicesList(servicesState, locationState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadServices,
        tooltip: 'Atualizar localização',
        child: const Icon(Icons.my_location),
      ),
    ),
  );
  }

  Widget _buildServicesList(ServicesState servicesState, LocationState locationState) {
    if (servicesState.status == ServicesStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando serviços próximos...'),
          ],
        ),
      );
    }

    if (servicesState.status == ServicesStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              servicesState.errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (locationState.status == LocationStatus.denied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              locationState.errorMessage ?? 'Permissão de localização negada',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
                if (mounted) _loadServices();
              },
              child: const Text('Permitir localização'),
            ),
          ],
        ),
      );
    }

    if (servicesState.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum serviço encontrado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente aumentar o raio de busca ou verificar os filtros.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _radiusKm = 20.0;
                  _minRating = 0.0;
                  _onlyOpen = false;
                });
                _loadServices();
              },
              child: const Text('Expandir busca'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: servicesState.services.length,
        itemBuilder: (context, index) {
          final service = servicesState.services[index];
          return ServiceCard(
            service: service,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/service-details',
                arguments: service.id,
              );
            },
          );
        },
      ),
    );
  }
}