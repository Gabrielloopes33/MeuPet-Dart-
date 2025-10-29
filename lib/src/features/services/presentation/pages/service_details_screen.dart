import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/services_provider.dart';
import '../../data/models/service_provider.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailsProvider(serviceId));

    return Scaffold(
      body: serviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
        data: (service) => service != null
            ? _buildServiceDetails(context, service)
            : const Center(child: Text('Serviço não encontrado')),
      ),
    );
  }

  Widget _buildServiceDetails(BuildContext context, ServiceProvider service) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar com imagem
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    service.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      service.photos.isNotEmpty
                          ? Image.network(
                              service.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    child: const Icon(
                                      Icons.business,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: const Icon(
                                Icons.business,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Conteúdo principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status e rating
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: service.isOpen ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              service.isOpen ? 'Aberto agora' : 'Fechado',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                service.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ' (${service.reviewCount} avaliações)',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Informações básicas
                      _buildInfoSection(context, 'Informações', [
                        _buildInfoItem(
                          Icons.location_on,
                          'Endereço',
                          service.address,
                        ),
                        if (service.phone != null)
                          _buildInfoItem(
                            Icons.phone,
                            'Telefone',
                            service.phone!,
                          ),
                        if (service.website != null)
                          _buildInfoItem(
                            Icons.language,
                            'Website',
                            service.website!,
                          ),
                        _buildInfoItem(
                          Icons.directions_walk,
                          'Distância',
                          '${service.distanceKm.toStringAsFixed(1)} km',
                        ),
                      ]),

                      if (service.description != null) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(context, 'Sobre', [
                          Text(
                            service.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ]),
                      ],

                      if (service.priceLevel != null) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(context, 'Nível de preço', [
                          Row(
                            children: List.generate(4, (index) {
                              return Icon(
                                Icons.attach_money,
                                color: index < service.priceLevel!.toInt()
                                    ? Colors.green
                                    : Colors.grey[300],
                              );
                            }),
                          ),
                        ]),
                      ],

                      // Galeria de fotos (se houver mais)
                      if (service.photos.length > 1) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(context, 'Fotos', [
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: service.photos.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      service.photos[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image),
                                              ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                      ],

                      // Espaço para o bottom bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom bar fixo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
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

                  if (service.website != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openWebsite(service.website!),
                        icon: const Icon(Icons.language),
                        label: const Text('Site'),
                      ),
                    ),

                  if (service.website != null) const SizedBox(width: 8),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openDirections(service.latitude, service.longitude),
                      icon: const Icon(Icons.directions),
                      label: const Text('Como chegar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String website) async {
    final uri = Uri.parse(website);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
