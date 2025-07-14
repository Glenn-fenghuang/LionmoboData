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

## 📦 分发包内容

```
LionmoboData-SDK-Distribution/
├── LionmoboData.xcframework          # 编译好的 SDK Framework
├── LionmoboDemo/                     # 示例项目
├── README.md                         # 项目概述（本文件）
├── INSTALLATION.md                   # 安装指南
├── LionmoboData_SDK_使用文档.md      # 详细使用文档
└── Podfile                          # CocoaPods 配置示例
```

## 🚀 快速开始

### 1. 安装 SDK

详细安装步骤请查看：[INSTALLATION.md](./INSTALLATION.md)

**简要步骤：**
1. 将 `LionmoboData.xcframework` 拖入您的 Xcode 项目
2. 确保 Framework 设置为 **Embed & Sign**

### 2. 初始化配置

```objc
#import <LionmoboData/LionmoboData.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"您的应用ID（大数据平台分配）";
    config.serverURL = @"您的服务器地址";
    config.apiKey = @"您的API密钥（登录大数据平台，个人资料中获取）";
    config.apiSecret = @"您的apiSecret密钥（登录大数据平台，个人资料中获取）";
    config.debugMode = YES; // 开发阶段建议开启

    [LionmoboData startWithConfig:config];
    return YES;
}
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

## 📚 文档指南

- **[INSTALLATION.md](./INSTALLATION.md)** - 快速安装指南
- **[LionmoboData_SDK_使用文档.md](./LionmoboData_SDK_使用文档.md)** - 完整使用文档
  - 详细的安装和集成步骤
  - 完整的 API 参考
  - 最佳实践指南
  - 常见问题解答

## 📱 示例项目

项目包含了一个完整的示例应用 `LionmoboDemo`，展示了 SDK 的各种功能使用方法。

**运行示例项目：**
1. 打开 `LionmoboDemo/LionmoboDemo.xcodeproj`
2. 将 `LionmoboData.xcframework` 添加到项目中
3. 确保 Framework 正确链接
4. 运行项目

## 🔧 主要功能

### 📊 数据追踪
- **页面追踪**: 自动记录用户页面访问行为
- **点击追踪**: 捕获用户点击事件
- **自定义事件**: 灵活的业务事件上报

### 🚀 性能监控
- **启动监控**: 冷启动/热启动性能分析
- **崩溃报告**: 自动收集崩溃信息并上报

### 🔔 实时通知
- **SDK 状态**: 初始化成功/失败通知
- **数据上报**: 事件上报状态监控

## 📞 技术支持

如有问题，请联系技术支持团队：

- 📧 技术支持邮箱：glenn-fenghuang@lionmobo.com
- 📱 集成问题咨询：请参考使用文档中的 FAQ 章节

## 📄 许可证

本 SDK 为商业产品，版权归 Lionmobo 所有。使用前请确保您已获得相应的授权。

---

**SDK 版本**: 1.0.0  
**发布时间**: 2025年7月14日  
**支持平台**: iOS 9.0+ 
