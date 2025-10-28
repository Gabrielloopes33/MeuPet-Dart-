import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/main/presentation/pages/main_layout.dart';
import '../../features/services/presentation/pages/services_map_screen.dart';
import '../../features/services/presentation/pages/service_details_screen.dart';

// Provider do GoRouter simples sem redirect automático
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/veterinary',
        name: 'veterinary',
        builder: (context, state) => const ServicesMapScreen(
          serviceType: 'veterinary',
          title: 'Veterinários',
        ),
      ),
      GoRoute(
        path: '/pet-shop',
        name: 'pet-shop',
        builder: (context, state) => const ServicesMapScreen(
          serviceType: 'pet_shop',
          title: 'Pet Shops',
        ),
      ),
      GoRoute(
        path: '/grooming',
        name: 'grooming',
        builder: (context, state) => const ServicesMapScreen(
          serviceType: 'grooming',
          title: 'Banho e Tosa',
        ),
      ),
      GoRoute(
        path: '/pet-hotel',
        name: 'pet-hotel',
        builder: (context, state) => const ServicesMapScreen(
          serviceType: 'pet_hotel',
          title: 'Pet Hotels',
        ),
      ),
      GoRoute(
        path: '/service-details',
        name: 'service-details',
        builder: (context, state) {
          final serviceId = state.pathParameters['id'] ?? state.extra as String;
          return ServiceDetailsScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
    ],
  );
});