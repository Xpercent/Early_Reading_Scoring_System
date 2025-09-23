## MyGO!!!!! 早读计分系统（Early_Reading_Scoring_System）

一个基于 Qt 6 QML/Quick 的简洁计分看板，用于班级/小组早读加分展示与统计。

### 功能概览
- **成员加/减分**：点击成员头像进行加分；再次点击可撤销当日分数。
- **统计视图**：主界面与柱状图统计视图一键切换。
- **全屏/自适应**：根据 `resources/config.json` 中的分辨率自动计算缩放或全屏显示。
- **动态文案与开屏动画**：支持名言轮播、开屏动画、字体资源加载。

### 运行环境
- Qt 6.8+（项目使用 `qt_standard_project_setup(REQUIRES 6.8)`）
- 组件：Qt Quick（QML）
- CMake 3.16+
- Windows（已提供 `icon.rc` 与发布脚本/目录），其他桌面平台亦可用 Qt 支持自行构建

### 目录结构（节选）
- `main.cpp`：应用入口，注册 `GlobalFunc` 到 QML，加载 `page/Main.qml`
- `globalfunc.h/.cpp`：数据与工具函数（读取/写入 JSON、团队/分数逻辑、字体注册等）
- `page/`：QML 界面（`Main.qml`、`TeamItem.qml`、`BarChart.qml` 等）
- `resources/`：图片、字体与配置（`config.json`、`team.json` 等）
- `CMakeLists.txt`：构建配置（含资源复制目标 `copy_resources`）

### 快速开始
#### Qt Creator
1. 打开项目根目录的 `CMakeLists.txt`。
2. 选择 Qt 6 kit（如 MinGW 64-bit 或 MSVC），配置并编译。
3. 运行目标：`appEarly_Reading_Scoring_System`。

构建后，CMake 自定义目标会把 `resources/` 与 `page/` 复制到构建目录，确保运行时能加载到外部 QML 与资源。

### 编译与打包
- 运行时需包含 `resources/` 与 `page/`；CMake 已在构建阶段自动复制到构建目录。
- 安装cqtdeployer以打包

```
cqtdeployer -bin appEarly_Reading_Scoring_System.exe -qmake E:\Code\tools\Qt\6.9.2\mingw_64\bin\qmake.exe -qmlDir E:\Code\tools\Qt\6.9.2\mingw_64\qml -qmlOut ku -libOut ku -pluginOut ku
```
