import 'package:flutter/material.dart';
import '../widgets/home_widgets.dart' as widgets;
import '../widgets/home_widgets_2.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Criar a estrutura principal com 4 abas: Home, Pets, Agenda, Perfil, replicando o estilo de (tabs)/_layout.tsx
  static final List<Widget> _screens = [
    const HomeScreen(),
    const _PlaceholderScreen(title: 'Pets'),
    const _PlaceholderScreen(title: 'Agenda'),
    const _PlaceholderScreen(title: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Tela Home (index.tsx): Esta é a tela mais complexa. Divida-a em widgets menores
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HomeHeader: "Olá, Gabriel" e botões
              const widgets.HomeHeader(),

              // SearchBar: A barra de busca
              const widgets.SearchBar(),

              // BannersCarousel: O carrossel de promoções (use PageView ou carousel_slider)
              const widgets.BannersCarousel(),

              // ServicesGrid: A grade de serviços (use GridView)
              const widgets.ServicesGrid(),

              // WeatherCard: O card de clima (chame a API do Open-Meteo)
              const WeatherCard(),

              // SuggestionsList: A lista de recomendações (use ListViewBuilder horizontal)
              const SuggestionsList(),

              // MyPetsList: A lista horizontal de pets (use ListView.builder horizontal)
              const MyPetsList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screen for tabs that haven't been implemented yet
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tela $title em construção',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidade será implementada em breve.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
