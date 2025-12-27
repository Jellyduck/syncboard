import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

import '../../common_ui/auth_input_field.dart';
import '../../common_ui/auth_primary_button.dart';
import '../../providers/app_providers.dart';
import '../../route/app_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // 邮箱和密码的控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final vm = ref.read(authVmProvider.notifier);
    final password = _passwordController.text;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showToast('请输入邮箱', position: ToastPosition.bottom);
      return;
    }
    if (password.isEmpty) {
      showToast('请输入密码', position: ToastPosition.bottom);
      return;
    }
    await vm.signInWithEmail(email, password);

    final authState = ref.read(authVmProvider);
    if (authState.hasError) {
      final error = authState.asError?.error;
      final message = error.toString();
      showToast('登录失败：$message', position: ToastPosition.bottom);
      return;
    }

    // 登录成功后跳转到分类页面
    Navigator.of(context).pushReplacementNamed(AppRoutes.category);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authVmProvider);
    const subtitle = '输入邮箱以登录SyncBoard';
    const hintText = 'email@domain.com';
    const keyboardType = TextInputType.emailAddress;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100.h),

                // 标题
                Center(
                  child: Text(
                    'SyncBoard',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // 副标题（输入邮箱登录）
                Center(
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 32.h),

                // 账号输入框
                AuthInputField(
                  controller: _emailController,
                  hintText: hintText,
                  keyboardType: keyboardType,
                ),

                SizedBox(height: 16.h),

                // 密码输入框
                AuthInputField(
                  controller: _passwordController,
                  hintText: '密码',
                  obscureText: true,
                ),

                SizedBox(height: 24.h),

                // 登录按钮
                AuthPrimaryButton(
                  label: '登录',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),

                SizedBox(height: 24.h),

                // 注册按钮 UI
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                    child: Text(
                      '还没有账号？注册',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // 服务条款和隐私政策，这里只做样式展示
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                      children: [
                        const TextSpan(text: '登录即表示您已同意'),
                        TextSpan(
                          text: '服务条款',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '隐私政策',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
