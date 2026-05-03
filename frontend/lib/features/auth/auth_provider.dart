import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      final token = res.data['access_token'] as String;
      await ApiClient.setToken(token);
      state = AuthState(isLoggedIn: true, token: token, isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Не удалось войти',
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Не удалось войти');
      return false;
    }
  }

  Future<bool> register(String nickname, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.dio.post(
        '/auth/register',
        data: {
          'nickname': nickname.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Не удалось зарегистрироваться',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось зарегистрироваться',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    state = const AuthState();
  }
}
