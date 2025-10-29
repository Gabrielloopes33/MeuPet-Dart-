import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/location_provider.dart';

class LocationPermissionWidget extends ConsumerWidget {
  final Widget child;
  final bool autoRequest;

  const LocationPermissionWidget({
    super.key,
    required this.child,
    this.autoRequest = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);

    // Auto request permission when widget is built
    if (autoRequest && locationState.status == LocationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        locationNotifier.getCurrentLocation();
      });
    }

    return Stack(
      children: [
        child,
        if (locationState.status == LocationStatus.denied)
          _buildPermissionDeniedOverlay(context, locationNotifier),
        if (locationState.status == LocationStatus.loading)
          _buildLoadingOverlay(context),
        if (locationState.status == LocationStatus.error &&
            locationState.errorMessage != null)
          _buildErrorSnackBar(context, locationState.errorMessage!),
      ],
    );
  }

  Widget _buildPermissionDeniedOverlay(
    BuildContext context,
    LocationNotifier locationNotifier,
  ) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Permissão de Localização',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Para encontrar serviços próximos a você, precisamos acessar sua localização.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Continuar sem localização (usar localização padrão)
                          locationNotifier.clearError();
                        },
                        child: const Text('Pular'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final hasPermission = await locationNotifier
                              .requestLocationPermission();
                          if (hasPermission) {
                            locationNotifier.getCurrentLocation();
                          } else {
                            // Se foi permanentemente negada, abrir configurações
                            final status = await Permission.location.status;
                            if (status.isPermanentlyDenied) {
                              _showOpenSettingsDialog(context);
                            }
                          }
                        },
                        child: const Text('Permitir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Obtendo sua localização...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: Colors.white,
            onPressed: () {
              final locationNotifier = ProviderScope.containerOf(
                context,
              ).read(locationNotifierProvider.notifier);
              locationNotifier.getCurrentLocation();
            },
          ),
        ),
      );
    });
    return const SizedBox.shrink();
  }

  void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Necessária'),
        content: const Text(
          'A permissão de localização foi permanentemente negada. '
          'Para usar este recurso, você precisa ativar a permissão nas configurações do aplicativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar status da localização
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
          label: Text('Buscando localização...'),
          backgroundColor: Colors.blue,
        );

      case LocationStatus.success:
        return const Chip(
          avatar: Icon(Icons.location_on, size: 16, color: Colors.white),
          label: Text('Localização ativa'),
          backgroundColor: Colors.green,
        );

      case LocationStatus.denied:
        return const Chip(
          avatar: Icon(Icons.location_off, size: 16, color: Colors.white),
          label: Text('Permissão negada'),
          backgroundColor: Colors.red,
        );

      case LocationStatus.error:
        return const Chip(
          avatar: Icon(Icons.error, size: 16, color: Colors.white),
          label: Text('Erro na localização'),
          backgroundColor: Colors.orange,
        );
    }
  }
}
