import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';

class CategoryViewModel extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryRepository _repository;

  CategoryViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  // 加载数据
  Future<void> loadCategories() async {
    try {
      if (state.value == null) state = const AsyncValue.loading();

      final categories = await _repository.fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 添加分类
  Future<void> addCategory(String title, {String iconName = 'work'}) async {
    try {
      await _repository.createCategory(title, iconName);

      // 成功后，重新拉取最新列表
      await loadCategories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 删除分类
  Future<void> deleteCategory(String id) async {
    try {
      // 先删数据库里的数据，再刷新列表
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
