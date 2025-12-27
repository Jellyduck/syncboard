import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AvatarRepository {
  final SupabaseClient _supabase;

  AvatarRepository(this._supabase);

  // 上传头像到bucket，返回头像的URL
  Future<String> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last; // 获取文件扩展名
      final filePath = '$userId/avatar.$fileExt';

      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true), // 覆盖已有同名文件
          );

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('上传头像失败: $e');
    }
  }

  // 更新数据库字段
  Future<void> updateUserAvatarUrl(String userId, String url) async {
    try {
      await _supabase
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', userId);
    } catch (e) {
      throw Exception('更新头像URL失败: $e');
    }
  }
}
