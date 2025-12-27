import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../repositories/auth_repository.dart';

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(const AsyncValue.data(null));

  // 登录
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signInWithEmail(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 注册 + 自动登录（供注册流程调用）
  Future<void> handleRegister({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );

      await _repository.signInWithEmail(email: email, password: password);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // 注销
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
