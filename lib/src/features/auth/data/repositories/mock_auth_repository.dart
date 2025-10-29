import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'auth_repository_interface.dart';

/// Repository mock para testes sem backend
/// Remove quando o servidor real estiver funcionando
class MockAuthRepository implements AuthRepositoryInterface {
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';

  // Dados mock de usuários para simulação
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Gabriel',
      'phone': '(11) 99999-9999',
      'password': '123456',
    },
    {
      'id': '2',
      'name': 'Maria Silva',
      'phone': '(11) 88888-8888',
      'password': 'senha123',
    },
  ];

  MockAuthRepository(this._secureStorage);

  /// Login mock - verifica se usuário existe na lista
  @override
  Future<User?> login(String phone, String password) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Buscar usuário nos dados mock
      final userData = _mockUsers.firstWhere(
        (user) => user['phone'] == phone && user['password'] == password,
        orElse: () => {},
      );

      if (userData.isEmpty) {
        return null; // Credenciais inválidas
      }

      // Simular token JWT
      final mockToken =
          'mock_jwt_token_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}';

      // Salvar token
      await _secureStorage.write(key: _tokenKey, value: mockToken);

      // Retornar usuário
      return User(
        id: userData['id'],
        name: userData['name'],
        phone: userData['phone'],
        createdAt: DateTime.now().subtract(
          const Duration(days: 30),
        ), // Simular conta criada há 30 dias
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Erro no login mock: $e');
      return null;
    }
  }

  /// Registro mock - adiciona novo usuário à lista
  @override
  Future<User?> register(String name, String phone, String password) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Verificar se usuário já existe
      final existingUser = _mockUsers.where((user) => user['phone'] == phone);
      if (existingUser.isNotEmpty) {
        throw Exception('Usuário já existe com este telefone');
      }

      // Criar novo usuário
      final newUserId = (_mockUsers.length + 1).toString();
      final newUserData = {
        'id': newUserId,
        'name': name,
        'phone': phone,
        'password': password,
      };

      // Adicionar à lista mock
      _mockUsers.add(newUserData);

      // Simular token JWT
      final mockToken =
          'mock_jwt_token_${newUserId}_${DateTime.now().millisecondsSinceEpoch}';

      // Salvar token
      await _secureStorage.write(key: _tokenKey, value: mockToken);

      // Retornar usuário criado
      return User(
        id: newUserId,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Erro no registro mock: $e');
      return null;
    }
  }

  /// Buscar perfil do usuário logado
  @override
  Future<User?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return null;

      // Extrair ID do usuário do token mock
      if (token.startsWith('mock_jwt_token_')) {
        final parts = token.split('_');
        if (parts.length >= 4) {
          final userId = parts[3];

          // Buscar usuário pelos dados mock
          final userData = _mockUsers.firstWhere(
            (user) => user['id'] == userId,
            orElse: () => {},
          );

          if (userData.isNotEmpty) {
            return User(
              id: userData['id'],
              name: userData['name'],
              phone: userData['phone'],
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              updatedAt: DateTime.now(),
            );
          }
        }
      }

      return null;
    } catch (e) {
      print('Erro ao buscar perfil mock: $e');
      return null;
    }
  }

  /// Logout - apenas remove o token
  @override
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      await _secureStorage.delete(key: _tokenKey);
      return true;
    } catch (e) {
      print('Erro no logout mock: $e');
      return false;
    }
  }

  /// Verificar se está logado
  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.startsWith('mock_jwt_token_');
  }

  /// Buscar token salvo
  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
}
