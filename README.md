# <font style="color:rgb(31, 31, 31);">SyncBoard </font>
**<font style="color:rgb(31, 31, 31);">SyncBoard</font>**<font style="color:rgb(31, 31, 31);"> 是一款基于 Flutter 和 Supabase 开发的跨平台项目协作管理应用。它集成了实时协作、看板式任务管理和即时通讯功能，旨在打破团队沟通壁垒，提供无缝的协作体验。</font>

<font style="color:rgb(31, 31, 31);">🚀</font><font style="color:rgb(31, 31, 31);"> </font>**<font style="color:rgb(31, 31, 31);">核心亮点</font>**<font style="color:rgb(31, 31, 31);">: 实时同步、MVVM 架构、Riverpod 2.0 自动生成代码、流畅的 UI 交互。</font>

---

## <font style="color:rgb(31, 31, 31);">✨</font><font style="color:rgb(31, 31, 31);"> 主要功能</font>
### <font style="color:rgb(31, 31, 31);"></font><font style="color:rgb(31, 31, 31);">用户认证系统</font>
+ <font style="color:rgb(31, 31, 31);">用户注册/登录 (Supabase Auth)</font>
+ <font style="color:rgb(31, 31, 31);">用户头像管理 (Image Picker + Storage)</font>
+ <font style="color:rgb(31, 31, 31);">会话状态持久化</font>

### <font style="color:rgb(31, 31, 31);"></font><font style="color:rgb(31, 31, 31);">项目管理</font>
+ <font style="color:rgb(31, 31, 31);">创建、编辑、删除项目</font>
+ <font style="color:rgb(31, 31, 31);">项目分类标签管理</font>
+ <font style="color:rgb(31, 31, 31);">基于角色的权限控制 (Owner/Member)</font>

### <font style="color:rgb(31, 31, 31);"></font><font style="color:rgb(31, 31, 31);">任务管理</font>
+ <font style="color:rgb(31, 31, 31);">任务 CRUD 与状态流转 (待办/进行中/已完成)</font>
+ <font style="color:rgb(31, 31, 31);">任务列表实时更新</font>

### <font style="color:rgb(31, 31, 31);"></font><font style="color:rgb(31, 31, 31);">实时团队聊天</font>
+ <font style="color:rgb(31, 31, 31);">消息同步</font>
+ <font style="color:rgb(31, 31, 31);">支持发送图片与文本</font>
+ <font style="color:rgb(31, 31, 31);">历史消息分页加载</font>
+ <font style="color:rgb(31, 31, 31);">消息气泡与自动滚动定位</font>

### <font style="color:rgb(31, 31, 31);"></font><font style="color:rgb(31, 31, 31);">成员协作</font>
+ <font style="color:rgb(31, 31, 31);">成员邀请与移除</font>
+ <font style="color:rgb(31, 31, 31);">成员头像堆叠展示</font>

---

## <font style="color:rgb(31, 31, 31);">📱</font><font style="color:rgb(31, 31, 31);"> 界面预览 (Screenshots)</font>
### 登录页
<img src="https://cdn.nlark.com/yuque/0/2025/png/38552424/1766815338219-4f1f19e4-9122-44e2-90d0-d628b2c4ef9b.png" width="250" alt="登录页截图">

### 项目列表
<img src="https://cdn.nlark.com/yuque/0/2025/png/38552424/1766815256652-798f2e28-56cb-4e31-b87a-73b99af2683c.png" width="250" alt="项目列表截图">

### 任务详情+实时聊天
<img src="https://cdn.nlark.com/yuque/0/2025/png/38552424/1766815319392-96ef7866-59a7-4a1e-bc8e-44e2ac575c35.png" width="250" alt="任务详情和聊天截图">

---

## <font style="color:rgb(31, 31, 31);">🛠</font><font style="color:rgb(31, 31, 31);"> 技术栈 (Tech Stack)</font>
| **<font style="color:rgb(31, 31, 31);">类别</font>** | **<font style="color:rgb(31, 31, 31);">技术方案</font>** | **<font style="color:rgb(31, 31, 31);">说明</font>** |
| --- | --- | --- |
| **<font style="color:rgb(31, 31, 31);">UI Framework</font>** | <font style="color:rgb(31, 31, 31);">Flutter</font> | <font style="color:rgb(31, 31, 31);">跨平台移动应用开发</font> |
| **<font style="color:rgb(31, 31, 31);">State Mgt</font>** | <font style="color:rgb(31, 31, 31);">Riverpod + Generator</font> | <font style="color:rgb(31, 31, 31);">响应式状态管理与依赖注入</font> |
| **<font style="color:rgb(31, 31, 31);">Backend</font>** | <font style="color:rgb(31, 31, 31);">Supabase</font> | <font style="color:rgb(31, 31, 31);">PostgreSQL, Auth, Realtime, Storage</font> |
| **<font style="color:rgb(31, 31, 31);">Local Storage</font>** | <font style="color:rgb(31, 31, 31);">SharedPreferences</font> | <font style="color:rgb(31, 31, 31);">本地配置缓存</font> |
| **<font style="color:rgb(31, 31, 31);">Plugins</font>** | <font style="color:rgb(31, 31, 31);">image_picker, intl</font> | <font style="color:rgb(31, 31, 31);">图片选择与国际化支持</font> |


---

## <font style="color:rgb(31, 31, 31);">🏗</font><font style="color:rgb(31, 31, 31);"> 软件架构 (Architecture)</font>
<font style="color:rgb(31, 31, 31);">本项目采用 </font>**<font style="color:rgb(31, 31, 31);">Feature-first</font>**<font style="color:rgb(31, 31, 31);"> 的目录结构与 </font>**<font style="color:rgb(31, 31, 31);">MVVM + Repository</font>**<font style="color:rgb(31, 31, 31);"> 分层架构。</font>

### <font style="color:rgb(31, 31, 31);">目录结构</font>
```plain
lib/
├── features/                 # 按业务功能划分
│   ├── auth/                 # 认证模块
│   ├── project/              # 项目管理
│   ├── task/                 # 任务管理
│   └── chat/                 # 聊天模块 (含 Realtime 实现)
├── repositories/             # 数据仓库层 (Supabase API 封装)
├── models/                   # 数据模型 (Freezed / JsonSerializable)
├── common_ui/                # 公共 UI 组件
└── route/                    # 路由配置
```

---

## <font style="color:rgb(31, 31, 31);">🚀</font><font style="color:rgb(31, 31, 31);"> 快速开始 (Getting Started)</font>
⚠️ main.dart文件中连接数据库的部分需要自己填写

```dart
await Supabase.initialize(
  url: '',
  anonKey: '',
); // 请填写自己的数据库url和key
```

### <font style="color:rgb(31, 31, 31);">1. 环境准备</font>
<font style="color:rgb(31, 31, 31);">确保您的环境已安装：</font>

 Flutter 3.32.8 + Dart 3.8.1  

### <font style="color:rgb(31, 31, 31);">2. 克隆项目</font>
```bash
git clone https://github.com/Jellyduck/syncboard.git
cd syncboard
```

### <font style="color:rgb(31, 31, 31);">3. 安装依赖</font>
```bash
flutter pub get
```

### <font style="color:rgb(31, 31, 31);">4. 配置 Supabase</font>
1. <font style="color:rgb(31, 31, 31);">在 </font>[<font style="color:rgb(11, 87, 208);">Supabase</font>](https://supabase.com/)<font style="color:rgb(31, 31, 31);"> 创建一个新项目。</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2025/png/38552424/1766813484029-b73eb12f-31bd-445b-8420-03877bfd393e.png)

2. <font style="color:rgb(31, 31, 31);">按照上图创建表结构（projects, tasks, chat_messages 等）。</font>
3. <font style="color:rgb(31, 31, 31);">创建相关视图。</font>
4. <font style="color:rgb(31, 31, 31);">修改表的policy。</font>
5. <font style="color:rgb(31, 31, 31);">在main.dart中填入您的 Key：</font>

<font style="color:rgb(68, 71, 70);">Dart</font>

```plain
await Supabase.initialize(
  url: '',
  anonKey: '',
); // 请填写自己的数据库url和key
```

### <font style="color:rgb(31, 31, 31);">5. 代码生成</font>
<font style="color:rgb(31, 31, 31);">本项目使用 riverpod_generator，运行以下命令生成 .g.dart 文件：</font>

```bash
dart run build_runner build --delete-conflicting-outputs
# 或者在开发时使用监听模式：
dart run build_runner watch
```

### <font style="color:rgb(31, 31, 31);">6. 运行应用</font>
```bash
flutter run
```

---

