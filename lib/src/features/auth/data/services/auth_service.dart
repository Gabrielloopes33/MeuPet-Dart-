import '../../../../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // Login do usuário
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return {
        'success': true,
        'data': response.data,
        'user': User.fromJson(response.data['user']),
        'token': response.data['token'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Registro do usuário
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return {
        'success': true,
        'data': response.data,
        'user': User.fromJson(response.data['user']),
        'token': response.data['token'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Logout do usuário
  Future<Map<String, dynamic>> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Buscar perfil do usuário
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      return {'success': true, 'user': User.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Atualizar perfil do usuário
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiClient.put(
        '/auth/profile',
        data: {'name': name, 'email': email},
      );

      return {'success': true, 'user': User.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Esqueci a senha
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
