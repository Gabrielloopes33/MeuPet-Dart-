import 'package:flutter/material.dart';
import 'services_screen.dart';

/// Tela específica para serviços veterinários
class VeterinaryServicesScreen extends StatelessWidget {
  const VeterinaryServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesScreen(
      serviceType: 'veterinary',
      title: 'Serviços Veterinários',
    );
  }
}

/// Tela específica para pet shops
class PetShopServicesScreen extends StatelessWidget {
  const PetShopServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesScreen(
      serviceType: 'pet_shop',
      title: 'Pet Shops',
    );
  }
}

/// Tela específica para banho e tosa
class GroomingServicesScreen extends StatelessWidget {
  const GroomingServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesScreen(
      serviceType: 'grooming',
      title: 'Banho & Tosa',
    );
  }
}

/// Tela específica para hotéis pet
class PetHotelServicesScreen extends StatelessWidget {
  const PetHotelServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesScreen(
      serviceType: 'hotel',
      title: 'Hotéis Pet',
    );
  }
}