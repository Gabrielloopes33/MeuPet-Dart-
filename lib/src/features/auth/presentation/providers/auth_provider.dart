import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../../../core/api/api_service.dart';

// Estados de autenticação
enum AuthStatus { initial, loading, authenticated, unauthenticated }

// Estado da autenticação
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Provider para ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider para AuthRepository (usando mock temporariamente)
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  const secureStorage = FlutterSecureStorage();
  return MockAuthRepository(secureStorage);
});

// AuthNotifier (usando Riverpod/Provider) que gerencia o estado
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryInterface _authRepository;

  AuthNotifier(this._authRepository)
    : super(const AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  // Verificar se usuário já está logado
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // Login
  Future<void> login(String phone, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.login(phone, password);
      if (user != null) {
        // O Notifier chamará o AuthRepository, e, em caso de sucesso no login, salvará o
        // token JWT usando flutter_secure_storage
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Credenciais inválidas',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // Register
  Future<void> register(String name, String phone, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.register(name, phone, password);
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Erro ao criar conta',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _authRepository.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    } catch (e) {
      // Mesmo em caso de erro, limpar o estado local
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    }
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider do AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
