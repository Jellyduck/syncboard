import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';

import '../../common_ui/auth_input_field.dart';
import '../../common_ui/auth_primary_button.dart';
import '../../providers/app_providers.dart';
import '../../route/app_routes.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    // 从相册选择头像
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    // 获取注册VM和个人资料VM，用于注册登录和上传头像
    final vm = ref.read(authVmProvider.notifier);
    final profileVm = ref.read(profileVmProvider.notifier);

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      showToast('请输入用户名', position: ToastPosition.bottom);
      return;
    }

    if (password.isEmpty) {
      showToast('请输入密码', position: ToastPosition.bottom);
      return;
    }

    if (confirmPassword.isEmpty) {
      showToast('请再次输入密码', position: ToastPosition.bottom);
      return;
    }

    if (password != confirmPassword) {
      showToast('两次输入的密码不一致', position: ToastPosition.bottom);
      return;
    }

    // 仅支持邮箱注册
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showToast('请输入邮箱', position: ToastPosition.bottom);
      return;
    }
    try {
      // 注册并自动登录
      await vm.handleRegister(
        email: email,
        password: password,
        username: username,
      );
    } catch (_) {
      final authState = ref.read(authVmProvider);
      if (authState.hasError) {
        final error = authState.asError?.error;
        final message = error.toString();

        if (message.contains('User already registered')) {
          showToast('该账号已被注册', position: ToastPosition.bottom);
        } else {
          showToast('注册或登录失败：$message', position: ToastPosition.bottom);
        }
      }
      return;
    }

    // 登录成功后，如有头像则上传头像
    if (_avatarFile != null) {
      try {
        await profileVm.updateAvatar(_avatarFile!);
      } catch (e) {
        showToast('上传头像失败', position: ToastPosition.bottom);
        return;
      }
    }

    // 注册并登录成功后跳转到分类页面
    Navigator.of(context).pushReplacementNamed(AppRoutes.category);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authVmProvider);

    final title = '创建 SyncBoard 账号';
    const subtitle = '使用邮箱注册新账号';
    const userHint = '用户名（必填）';
    const accountHint = 'email@domain.com';
    const passwordHint = '密码';
    const confirmPasswordHint = '确认密码';
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
                SizedBox(height: 80.h),

                // 标题
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // 副标题
                Center(
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 32.h),

                // 头像选择（本地图片，圆形预览）
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32.r,
                          backgroundColor: Colors.grey.shade200,
                          // 如果选择了头像则显示头像，否则显示默认图标（person）
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : null,
                          child: _avatarFile == null
                              ? Icon(
                                  Icons.person,
                                  size: 32.sp,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '点击选择头像',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // 用户名
                AuthInputField(
                  controller: _usernameController,
                  hintText: userHint,
                ),

                SizedBox(height: 16.h),

                // 账号（邮箱）
                AuthInputField(
                  controller: _emailController,
                  hintText: accountHint,
                  keyboardType: keyboardType,
                ),

                SizedBox(height: 16.h),

                // 密码
                AuthInputField(
                  controller: _passwordController,
                  hintText: passwordHint,
                  obscureText: true,
                ),

                SizedBox(height: 16.h),

                // 确认密码
                AuthInputField(
                  controller: _confirmPasswordController,
                  hintText: confirmPasswordHint,
                  obscureText: true,
                ),

                SizedBox(height: 24.h),

                // 注册按钮
                AuthPrimaryButton(
                  label: '注册',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),

                SizedBox(height: 24.h),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '已有账号？去登录',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
