import '../models/user_model.dart';

/// Interface comum para AuthRepository e MockAuthRepository
abstract class AuthRepositoryInterface {
  Future<User?> login(String phone, String password);
  Future<User?> register(String name, String phone, String password);
  Future<User?> getProfile();
  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}