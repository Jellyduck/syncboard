import 'package:flutter/material.dart';
import 'package:sync_borad/features/auth/login_page.dart';
import 'package:sync_borad/features/auth/register_page.dart';
import 'package:sync_borad/features/category/category_page.dart';
import 'package:sync_borad/features/member/member_page.dart';
import 'package:sync_borad/features/project/project_page.dart';
import 'package:sync_borad/features/task/task_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String category = '/category';
  static const String project = '/project';
  static const String task = '/task';
  static const String members = '/members';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case category:
        return MaterialPageRoute(builder: (_) => const CategoryPage());
      case project:
        final args = settings.arguments as Map<String, dynamic>?;
        final categoryId = args?['categoryId'] as String? ?? '';
        final categoryTitle = args?['categoryTitle'] as String? ?? '';
        final isShared = args?['isShared'] as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ProjectPage(
            categoryId: categoryId,
            categoryTitle: categoryTitle,
            isShared: isShared,
          ),
        );
      case task:
        final args = settings.arguments;
        final projectId = args as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => TaskPage(projectId: projectId),
        );
      case members:
        final args = settings.arguments as Map<String, dynamic>?;
        final projectId = args?['projectId'] as String? ?? '';
        final currentUserId = args?['currentUserId'] as String? ?? '';
        final isOwner = args?['isOwner'] as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ManageMembersPage(
            projectId: projectId,
            currentUserId: currentUserId,
            isOwner: isOwner,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
