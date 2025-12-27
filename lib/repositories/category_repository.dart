import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient _supabase;

  CategoryRepository(this._supabase);

  // 获取列表
  Future<List<CategoryModel>> fetchCategories() async {
    final data = await _supabase
        .from('view_categories_with_count') // 查询视图，还会返回projects的数量
        .select()
        .order('created_at', ascending: true); // 按创建时间排序

    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // 创建分类到 list_categories 表
  Future<void> createCategory(String title, String iconName) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('list_categories').insert({
      'user_id': userId,
      'title': title,
      'icon_name': iconName,
    });
  }

  // 删除分类
  Future<void> deleteCategory(String id) async {
    await _supabase.from('list_categories').delete().eq('id', id);
  }
}
