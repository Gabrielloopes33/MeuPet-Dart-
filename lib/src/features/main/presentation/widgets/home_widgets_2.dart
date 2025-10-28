import 'package:flutter/material.dart';

// WeatherCard: O card de clima (chame a API do Open-Meteo)
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clima para passeios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ensolarado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('25°C - Belo Horizonte'),
                        const SizedBox(height: 4),
                        Text(
                          '✅ Perfeito para passear!',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
}

// SuggestionsList: A lista de recomendações (use ListView.builder horizontal)
class SuggestionsList extends StatelessWidget {
  const SuggestionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {
        'title': 'Vacina em dia?',
        'subtitle': 'Verifique o cartão de vacinação',
        'icon': Icons.vaccines,
        'color': Colors.blue,
      },
      {
        'title': 'Hora do banho',
        'subtitle': 'Agende um banho e tosa',
        'icon': Icons.shower,
        'color': Colors.green,
      },
      {
        'title': 'Ração especial',
        'subtitle': 'Confira nossas ofertas',
        'icon': Icons.food_bank,
        'color': Colors.orange,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recomendações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                suggestion['icon'] as IconData,
                                color: suggestion['color'] as Color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  suggestion['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion['subtitle'] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// MyPetsList: A lista horizontal de pets (use ListView.builder horizontal)
class MyPetsList extends StatelessWidget {
  const MyPetsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo - TODO: buscar da API
    final pets = [
      {
        'name': 'Rex',
        'type': 'Cachorro',
        'image': null,
      },
      {
        'name': 'Mimi',
        'type': 'Gato',
        'image': null,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meus Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de pets
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: pets.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum pet cadastrado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pets.length + 1, // +1 para o botão de adicionar
                    itemBuilder: (context, index) {
                      if (index == pets.length) {
                        // Botão de adicionar pet
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Adicionar pet
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Adicionar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final pet = pets[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              child: pet['image'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        pet['image'] as String,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      pet['type'] == 'Cachorro' ? Icons.pets : Icons.pets,
                                      size: 30,
                                      color: Colors.grey[600],
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pet['name'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}