import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api_service.dart';
import '../models/user_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';

  AuthRepository(this._apiService, this._secureStorage);

  // Login com métodos login(phone, password), register(...), getProfile()
  @override
  Future<User?> login(String phone, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      final token = response.data['token'];
      final userData = response.data['user'];

      // Salvar token
      await _secureStorage.write(key: _tokenKey, value: token);

      // Converter e retornar usuário
      return User.fromJson(userData);
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  @override
  Future<User?> register(String name, String phone, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {'name': name, 'phone': phone, 'password': password},
      );

      final token = response.data['token'];
      final userData = response.data['user'];

      // Salvar token
      await _secureStorage.write(key: _tokenKey, value: token);

      // Converter e retornar usuário
      return User.fromJson(userData);
    } catch (e) {
      print('Erro no registro: $e');
      return null;
    }
  }

  @override
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get('/auth/profile');
      return User.fromJson(response.data);
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _apiService.post('/auth/logout');
      await _secureStorage.delete(key: _tokenKey);
      return true;
    } catch (e) {
      print('Erro no logout: $e');
      return false;
    }
  }

  // Verificar se está logado
  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  // Buscar token salvo
  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
}
