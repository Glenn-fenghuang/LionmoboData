# LionmoboData iOS SDK

一个功能强大的 iOS 数据分析 SDK，专门用于收集应用内用户行为数据。

## 📋 概述

LionmoboData SDK 提供了完整的数据追踪解决方案，包括：

- 🎯 **用户行为追踪**: 自动追踪页面访问、点击事件
- 🚀 **应用启动监控**: 监控冷启动/热启动性能  
- 💥 **崩溃报告**: 自动收集和上报应用崩溃信息
- 📊 **自定义事件**: 支持自定义业务事件上报
- 📝 **日志系统**: 完善的分级日志输出
- 🔔 **通知系统**: 实时的 SDK 状态通知

## 🛠 系统要求

- iOS 9.0 及以上版本
- Xcode 11.0 及以上版本
- 支持 Objective-C 和 Swift 项目

## 📦 项目结构

```
LionmoboData/
├── LionmoboData/                    # SDK 源码
│   ├── Core/                        # 核心模块
│   ├── PageTracking/               # 页面追踪
│   ├── CrashManager/               # 崩溃管理
│   ├── Logging/                    # 日志系统
│   ├── Notification/               # 通知管理
│   └── Utils/                      # 工具类
├── LionmoboDemo/                   # 示例项目
├── build.sh                       # 构建脚本
├── Podfile                         # CocoaPods 配置
└── LionmoboData_SDK_使用文档.md    # 详细使用文档
```

## 🚀 快速开始

### 1. 导入 SDK

```objc
#import <LionmoboData/LionmoboData.h>
```

### 2. 初始化配置

```objc
LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
config.appID = @"你的应用ID（大数据平台分配）";
config.serverURL = @"你的服务器地址";
config.apiKey = @"你的API密钥（登录大数据平台，个人资料中获取）";
config.apiSecret = @"你的apiSecret密钥（登录大数据平台，个人资料中获取）";
config.debugMode = YES; // 开发阶段建议开启

[LionmoboData startWithConfig:config];
```

### 3. 基本使用

```objc
// 设置用户ID
[LionmoboData setUserID:@"user123"];

// 上报自定义事件
[LionmoboData customEventName:@"button_click" detail:@{
    @"button_name": @"购买按钮",
    @"page": @"商品详情页"
}];
```

## 📚 详细文档

完整的使用文档请查看：[LionmoboData_SDK_使用文档.md](./LionmoboData_SDK_使用文档.md)

文档包含：
- 详细的安装和集成步骤
- 完整的 API 参考
- 最佳实践指南
- 常见问题解答

## 🏗 构建 SDK

使用提供的构建脚本生成 XCFramework：

```bash
chmod +x build.sh
./build.sh
```

## 📱 示例项目

项目包含了一个完整的示例应用 `LionmoboDemo`，展示了 SDK 的各种功能使用方法。

要运行示例项目：

1. 打开 `LionmoboData.xcworkspace`
2. 选择 `LionmoboDemo` target
3. 运行项目

## 🔧 依赖

- **AFNetworking**: 网络请求处理
- **Masonry**: Auto Layout 库（仅示例项目使用）

## 📄 许可证

本项目为私有项目，版权归 Lionmobo 所有。

## 📞 技术支持

如有问题，请联系技术支持团队。

---

**SDK 版本**: 1.0.0  
**最后更新**: 2025年7月14日 