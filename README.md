# MeuPet - Pet Care Management App

Um aplicativo Flutter completo para gerenciamento e cuidados de pets, com funcionalidades de localização de serviços, agendamento de consultas e acompanhamento da saúde dos animais.

## Visão Geral

O MeuPet é uma solução mobile desenvolvida em Flutter que conecta tutores de pets a prestadores de serviços especializados, oferecendo uma experiência integrada para o cuidado animal com recursos de GPS, mapas customizados e sistema de agendamento.

## Funcionalidades Principais

### Autenticação e Onboarding
- Sistema de login/registro com validação
- Tela de onboarding para novos usuários
- Armazenamento seguro de credenciais
- Gerenciamento de estado de autenticação

### Localização de Serviços com GPS
- **Veterinários**: Localização de clínicas veterinárias próximas
- **Pet Shops**: Busca de lojas especializadas em produtos pet
- **Banho & Tosa**: Serviços de higiene e estética animal
- **Pet Hotels**: Hospedagem para animais de estimação

### Mapa Customizado (Sem Google Maps API)
- Implementação de mapa próprio usando Web Mercator projection
- Visualização estilo OpenStreetMap com ruas e quarteirões
- Posicionamento GPS preciso com coordenadas reais
- Zoom e pan interativos com gestos touch
- Markers coloridos por tipo de serviço
- Sistema de filtragem por distância e avaliação

### Sistema de GPS e Permissões
- Solicitação automática de permissões de localização
- Indicador visual de status GPS
- Redirecionamento para configurações do sistema
- Funcionalidade offline com localização padrão

### Gerenciamento de Pets
- Cadastro e edição de informações dos pets
- Upload de fotos dos animais
- Histórico de saúde e vacinas
- Acompanhamento de consultas

### Agenda e Agendamentos
- Calendário integrado para visualização de compromissos
- Agendamento de consultas veterinárias
- Lembretes e notificações
- Sincronização com prestadores de serviços

### Perfil do Usuário
- Informações pessoais editáveis
- Preferências de notificação
- Histórico de serviços utilizados
- Sistema de logout seguro

## Arquitetura e Tecnologias

### Estrutura do Projeto
```
lib/
├── main.dart
└── src/
    ├── core/                    # Configurações centrais
    │   ├── api/                # Cliente HTTP e interceptors
    │   ├── design_system/      # Temas e componentes visuais
    │   ├── providers/          # Providers globais (localização)
    │   ├── router/             # Configuração de rotas
    │   └── theme/              # Sistema de temas
    └── features/               # Módulos funcionais
        ├── agenda/             # Sistema de agendamento
        ├── appointments/       # Gerenciamento de consultas
        ├── auth/              # Autenticação e onboarding
        ├── main/              # Layout principal e navegação
        ├── pets/              # Gerenciamento de pets
        ├── profile/           # Perfil do usuário
        └── services/          # Localização de serviços
            ├── data/          # Repositories e models
            ├── domain/        # Entidades de negócio
            └── presentation/  # UI e providers
```

### Stack Tecnológico

**Framework e Linguagem**
- Flutter 3.9.2+
- Dart SDK ^3.9.2

**Gerenciamento de Estado**
- Riverpod 2.4.0 - State management moderno e performático

**Navegação**
- GoRouter 12.1.1 - Roteamento declarativo oficial do Flutter

**Localização e Mapas**
- Geolocator 12.0.0 - Obtenção de coordenadas GPS
- Permission Handler 11.3.1 - Gerenciamento de permissões
- Mapa customizado próprio (sem APIs externas)

**Interface e UX**
- Google Fonts 6.1.0 - Tipografia personalizada
- Table Calendar 3.1.2 - Componente de calendário
- Image Picker 1.1.2 - Upload de imagens
- Cupertino Icons 1.0.8 - Ícones iOS

**Rede e Persistência**
- Dio 5.4.0 - Cliente HTTP para APIs
- Flutter Secure Storage 9.0.0 - Armazenamento seguro de tokens

**Utilitários**
- Intl 0.19.0 - Formatação de datas e números
- URL Launcher 6.3.0 - Abertura de URLs externas
- JSON Annotation 4.8.1 - Serialização de dados

**Desenvolvimento**
- JSON Serializable 6.7.1 - Geração de código para modelos
- Build Runner 2.4.7 - Automação de build
- Flutter Lints 5.0.0 - Análise estática de código

## Configuração e Instalação

### Pré-requisitos
- Flutter SDK 3.9.2 ou superior
- Dart SDK ^3.9.2
- Android Studio / VS Code com extensões Flutter
- Dispositivo físico ou emulador para testes GPS

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/meupet-app.git
cd meupet-app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure permissões de localização**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa da localização para encontrar serviços próximos</string>
```

4. **Execute a aplicação**
```bash
flutter run
```

### Build para Produção

**Android APK:**
```bash
flutter build apk --release
```

**iOS (requer macOS e Xcode):**
```bash
flutter build ios --release
```

## Funcionalidades Técnicas Detalhadas

### Sistema de Mapas Customizado

O aplicativo implementa uma solução própria de mapas que **não requer APIs externas**, utilizando:

- **Projeção Web Mercator**: Padrão internacional para conversão de coordenadas
- **Renderização com Canvas**: Desenho de ruas, quarteirões e pontos de interesse
- **Cálculos GPS precisos**: Posicionamento baseado em latitude/longitude reais
- **Visual estilo OpenStreetMap**: Interface familiar e intuitiva

**Vantagens:**
- Zero custo de APIs externas
- Controle total sobre funcionalidades
- Performance otimizada para mobile
- Customização completa da interface

### Gerenciamento de Estado com Riverpod

Utiliza providers especializados para cada módulo:

```dart
// Exemplo de provider de serviços
final servicesNotifierProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  final repository = ref.read(servicesRepositoryProvider);
  return ServicesNotifier(repository);
});
```

### Sistema de Localização Inteligente

- **Detecção automática**: Verifica disponibilidade do GPS
- **Fallback gracioso**: Usa localização padrão se GPS indisponível
- **Cache de posição**: Evita solicitações desnecessárias
- **Filtros por distância**: Busca serviços em raios configuráveis

## Estrutura de Dados

### Modelo de Serviço
```dart
class ServiceProvider {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final double rating;
  final int reviewCount;
  final List<String> photos;
  final String serviceType;
  final bool isOpen;
  final double distanceKm;
}
```

### Modelo de Pet
```dart
class Pet {
  final String id;
  final String name;
  final String type;
  final String? age;
  final String? image;
  // Outros campos de saúde e histórico
}
```

## Roadmap e Próximas Funcionalidades

### Em Desenvolvimento
- [ ] **Módulo Pets Completo**: CRUD de animais com fotos e histórico médico
- [ ] **Sistema de Agendamento**: Integração com calendários de prestadores
- [ ] **Perfil Avançado**: Configurações e preferências personalizadas
- [ ] **Notificações Push**: Lembretes e atualizações em tempo real

### Futuras Implementações
- [ ] **Chat com Veterinários**: Comunicação direta via app
- [ ] **Telemedicina**: Consultas virtuais integradas
- [ ] **Marketplace**: Compra de produtos pet
- [ ] **Rede Social Pet**: Comunidade de tutores
- [ ] **Tracking de Saúde**: Gráficos e análises veterinárias

## Contribuição

### Como Contribuir

1. **Fork** do repositório
2. **Create branch** para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. **Push** para a branch (`git push origin feature/nova-funcionalidade`)
5. **Pull Request** detalhado

### Padrões de Código

- Siga as convenções do **Flutter Style Guide**
- Use **linting** com flutter_lints
- **Documente** funções públicas
- **Teste** funcionalidades críticas
- Mantenha **responsividade** em diferentes telas

### Issues e Bugs

Para reportar problemas:
1. Verifique se já não existe issue similar
2. Use template de bug report
3. Inclua screenshots e logs quando necessário
4. Especifique versão do Flutter e sistema operacional

## Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Suporte e Contato

- **Documentação**: [Wiki do projeto](../../wiki)
- **Issues**: [GitHub Issues](../../issues)
- **Discussões**: [GitHub Discussions](../../discussions)

---

**Desenvolvido com ❤️ para a comunidade pet**
