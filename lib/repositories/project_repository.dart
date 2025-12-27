import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final SupabaseClient _supabase;
  ProjectRepository(this._supabase);

  Future<List<ProjectModel>> fetchProjects(String categoryId) async {
    final data = await _supabase
        .from('view_projects_with_details') // 查视图
        .select()
        .eq('category_id', categoryId) // 只查当前分类下的
        .order('created_at', ascending: false); // 按时间倒序

    return (data as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  // 获取单个项目详情
  Future<ProjectModel> fetchProjectById(String projectId) async {
    final data = await _supabase
        .from('view_projects_with_details')
        .select()
        .eq('id', projectId)
        .single();

    return ProjectModel.fromJson(data);
  }

  // 创建项目
  Future<void> createProject({
    required String categoryId,
    required String title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user found');

    await _supabase.from('projects').insert({
      'category_id': categoryId,
      'owner_id': user.id,
      'title': title,
      'description': description,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'status': 'ongoing', // 默认状态
    });
  }

  // 删除项目
  Future<void> deleteProject(String projectId) async {
    try {
      // 直接调用 delete，RLS 策略会在数据库层面拦截非 Owner 的操作
      await _supabase.from('projects').delete().eq('id', projectId);
    } catch (e) {
      // 如果 RLS 拦截，会抛出 PostgrestException
      print('删除project错误 $e');
    }
  }

  // 获取分享给我的项目列表
  Future<List<ProjectModel>> fetchSharedProjects() async {
    final response = await Supabase.instance.client
        .from('shared_projects_view') // 查视图
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => ProjectModel.fromJson(e)).toList();
  }
}
