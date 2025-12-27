import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../repositories/avatar_repository.dart';

class AvatarViewModel extends StateNotifier<AsyncValue<String?>> {
  final AvatarRepository _repository;

  AvatarViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateAvatar(File file) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();

    try {
      // 上传头像并获取URL
      final url = await _repository.uploadAvatar(file, userId);
      // 更新数据库表中的头像URL
      await _repository.updateUserAvatarUrl(userId, url);

      // 成功设置状态为 Data
      state = AsyncValue.data(url);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
