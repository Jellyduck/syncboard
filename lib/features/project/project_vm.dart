import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/project_model.dart';
import '../../repositories/project_repository.dart';

class ProjectViewModel extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository _repository;
  final String _categoryId;

  ProjectViewModel(this._repository, this._categoryId)
    : super(const AsyncValue.loading()) {
    loadProjects();
  }

  // 加载数据 (查)
  Future<void> loadProjects() async {
    try {
      final data = await _repository.fetchProjects(_categoryId);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 增加数据
  Future<void> addProject(
    String title,
    String desc,
    DateTime start,
    DateTime end,
  ) async {
    try {
      await _repository.createProject(
        categoryId: _categoryId,
        title: title,
        description: desc,
        startAt: start,
        endAt: end,
      );
      // 成功后重新拉取整个列表
      await loadProjects();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 删除数据
  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      // 成功后重新拉取整个列表
      await loadProjects();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
