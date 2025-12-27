import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  // 登录
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Email登录失败: ${e.message}');
    } catch (e) {
      throw Exception('发生未知错误: $e');
    }
  }

  // 注册
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 使用 'data' 字段存储username
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } on AuthException catch (e) {
      throw Exception('邮箱注册失败: ${e.message}');
    } catch (e) {
      throw Exception('发生未知错误: $e');
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('登出失败: $e');
    }
  }
}
