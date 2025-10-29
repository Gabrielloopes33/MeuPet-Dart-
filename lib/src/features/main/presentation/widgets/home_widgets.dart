import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// HomeHeader: "Olá, Gabriel" e botões
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.user?.name ?? 'Usuário';
    final firstName = userName.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $firstName! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Como seu pet está hoje?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Notificações
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () {
              // TODO: Menu
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }
}

// SearchBar: A barra de busca
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar serviços, pets...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// BannersCarousel: O carrossel de promoções (use PageView ou carousel_slider)
class BannersCarousel extends StatelessWidget {
  const BannersCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = [
      {
        'title': '🐕 Consulta Veterinária',
        'subtitle': 'Cuide da saúde do seu pet',
        'color': Colors.blue,
      },
      {
        'title': '🐱 Pet Shop',
        'subtitle': 'Produtos para seu amigo',
        'color': Colors.green,
      },
      {
        'title': '✂️ Banho e Tosa',
        'subtitle': 'Seu pet sempre limpinho',
        'color': Colors.orange,
      },
    ];

    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: banner['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner['subtitle'] as String,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ServicesGrid: A grade de serviços (use GridView)
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'Veterinário',
        'icon': Icons.local_hospital,
        'color': Colors.red,
        'route': '/veterinary',
      },
      {
        'name': 'Pet Shop',
        'icon': Icons.store,
        'color': Colors.blue,
        'route': '/pet-shop',
      },
      {
        'name': 'Banho & Tosa',
        'icon': Icons.shower,
        'color': Colors.green,
        'route': '/grooming',
      },
      {
        'name': 'Hotel Pet',
        'icon': Icons.hotel,
        'color': Colors.orange,
        'route': '/pet-hotel',
      },
      {
        'name': 'Adestramento',
        'icon': Icons.school,
        'color': Colors.purple,
        'route': null, // Em desenvolvimento
      },
      {
        'name': 'Emergência',
        'icon': Icons.emergency,
        'color': Colors.red[800]!,
        'route': null, // Em desenvolvimento
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serviços',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  final route = service['route'] as String?;
                  if (route != null) {
                    context.go(route);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${service['name']} - Em desenvolvimento',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        service['icon'] as IconData,
                        size: 32,
                        color: service['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
