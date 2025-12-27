import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_model.dart';

class MemberRepository {
  final SupabaseClient _supabase;

  MemberRepository(this._supabase);

  // 获取项目成员列表及头像
  Future<List<ProjectMemberModel>> fetchProjectMembers(String projectId) async {
    final data = await _supabase
        .from('project_members')
        .select(
          'id, project_id, user_id, role, joined_at, profiles!inner(avatar_url, username)',
        )
        .eq('project_id', projectId)
        .order('joined_at', ascending: true);

    return (data as List)
        .map((item) => ProjectMemberModel.fromJson(item))
        .toList();
  }

  // 搜索用户
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final keyword = query.trim();
    if (keyword.isEmpty) {
      return [];
    }

    final result = await _supabase
        .from('profiles')
        .select('id, username, avatar_url')
        .ilike('username', '%$keyword%')
        .limit(10);
    return result;
  }

  // 添加成员
  Future<void> addMember({
    required String projectId,
    required String userId,
  }) async {
    // 先检查该用户是否已经是成员
    final existing = await _supabase
        .from('project_members')
        .select('id')
        .eq('project_id', projectId)
        .eq('user_id', userId);

    if (existing.isNotEmpty) {
      throw Exception('该用户已经是项目成员');
    }

    await _supabase.from('project_members').insert({
      'project_id': projectId,
      'user_id': userId,
      'role': 'member', // 默认角色
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  // 移除成员
  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    await _supabase.from('project_members').delete().match({
      'project_id': projectId,
      'user_id': userId,
    });
  }
}
