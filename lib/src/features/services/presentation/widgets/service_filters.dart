import 'package:flutter/material.dart';

class ServiceFilters extends StatelessWidget {
  final double radiusKm;
  final double minRating;
  final bool onlyOpen;
  final String sortBy;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<bool> onOnlyOpenChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onApplyFilters;

  const ServiceFilters({
    super.key,
    required this.radiusKm,
    required this.minRating,
    required this.onlyOpen,
    required this.sortBy,
    required this.onRadiusChanged,
    required this.onRatingChanged,
    required this.onOnlyOpenChanged,
    required this.onSortChanged,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Raio de busca
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raio de busca: ${radiusKm.toStringAsFixed(0)} km',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: radiusKm,
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: onRadiusChanged,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Rating mínimo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avaliação mínima: ${minRating.toStringAsFixed(1)} ⭐',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: minRating,
                min: 0,
                max: 5,
                divisions: 50,
                onChanged: onRatingChanged,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Apenas estabelecimentos abertos
          Row(
            children: [
              Checkbox(
                value: onlyOpen,
                onChanged: (value) => onOnlyOpenChanged(value ?? false),
              ),
              const Text('Apenas estabelecimentos abertos'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Ordenação
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ordenar por:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip('distance', 'Distância'),
                  _buildSortChip('rating', 'Avaliação'),
                  _buildSortChip('name', 'Nome'),
                  _buildSortChip('reviews', 'Nº Reviews'),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botão aplicar filtros
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApplyFilters,
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: sortBy == value,
      onSelected: (selected) {
        if (selected) {
          onSortChanged(value);
        }
      },
    );
  }
}