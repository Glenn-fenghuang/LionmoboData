# LionmoboData iOS SDK

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Glenn-fenghuang/LionmoboData)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![iOS Deployment Target](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)](https://developer.apple.com/ios/)

LionmoboData iOS SDK 是一个企业级数据分析和统计框架，为 iOS 应用提供全面的用户行为分析、性能监控和崩溃报告功能。

## ✨ 核心特性

### 📊 数据收集与分析
- **页面访问统计** - 自动追踪用户页面浏览路径和停留时间
- **用户行为分析** - 精确记录点击事件、手势操作和交互行为
- **自定义事件追踪** - 支持业务自定义埋点和事件上报

### 🔍 性能监控
- **应用启动监控** - 监控冷启动、热启动性能指标
- **实时性能分析** - 内存使用、CPU 占用等关键指标监控
- **网络请求监控** - API 调用性能和成功率统计

### 🛡️ 稳定性保障
- **崩溃日志收集** - 自动捕获和上报应用崩溃信息
- **异常监控** - 实时监控应用异常状态
- **设备信息收集** - 系统版本、设备型号等环境信息

### 🔧 开发者工具
- **分级日志系统** - 完善的调试和生产环境日志输出
- **实时通知机制** - SDK 状态变化的即时反馈
- **数据上报控制** - 灵活的数据上报策略配置

## 📋 系统要求

| 平台 | 最低版本 | 开发工具 |
|------|----------|----------|
| iOS | 9.0+ | Xcode 11.0+ |
| 架构 | arm64, x86_64 | - |
| 语言支持 | Objective-C, Swift | - |

## 🛠 安装集成

### CocoaPods 集成

在 `Podfile` 中添加：

```ruby
platform :ios, '9.0'
use_frameworks!

target 'YourApp' do
  pod 'LionmoboData', :git => 'https://github.com/Glenn-fenghuang/LionmoboData.git', :tag => '1.0.0'
end
```

执行安装：
```bash
pod install
```

### 手动集成

1. 下载 `LionmoboData.xcframework`
2. 拖拽到 Xcode 项目中
3. 在 **Target Settings** → **General** → **Frameworks, Libraries, and Embedded Content** 中设置为 **Embed & Sign**

## 🚀 快速开始

### 1. 初始化配置

在 `AppDelegate.m` 中添加初始化代码：

```objc
#import <LionmoboData/LionmoboData.h>

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 创建配置对象
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"your_app_id";
    config.serverURL = @"https://your-server.com/api";
    config.apiKey = @"your_api_key";
    config.debugMode = YES; // 开发环境建议开启
    
    // 功能开关
    config.pageTrackingEnabled = YES;
    config.clickTrackingEnabled = YES;
    config.crashReportingEnabled = YES;
    
    // 启动 SDK
    [LionmoboData startWithConfig:config];
    
    return YES;
}
```

### 2. 基础使用

```objc
// 自定义事件追踪
[[LionmoboData sharedInstance] trackEvent:@"button_click" 
                               properties:@{@"button_name": @"purchase"}];

// 页面访问统计
[[LionmoboData sharedInstance] trackPageView:@"ProductDetailPage" 
                                   properties:@{@"product_id": @"12345"}];
```

## 📚 API 文档

详细的 API 文档和使用示例，请参考：

- [完整使用文档](./LionmoboData_SDK_使用文档.md) - 包含所有功能的详细说明
- [示例项目](./LionmoboDemo/) - 完整的集成示例和最佳实践

## 🔧 配置选项

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `appID` | NSString | - | 应用唯一标识符（必填） |
| `serverURL` | NSString | - | 数据上报服务器地址（必填） |
| `apiKey` | NSString | - | API 密钥（必填） |
| `debugMode` | BOOL | NO | 调试模式开关 |
| `pageTrackingEnabled` | BOOL | YES | 页面访问追踪 |
| `clickTrackingEnabled` | BOOL | YES | 点击事件追踪 |
| `crashReportingEnabled` | BOOL | YES | 崩溃报告收集 |

## 📱 示例项目

本 SDK 提供了完整的示例项目，展示了所有功能的集成方式：

```bash
# 运行示例项目
cd LionmoboDemo
open LionmoboDemo.xcodeproj
```

示例项目包含：
- SDK 初始化和配置
- 页面访问统计实现
- 自定义事件埋点
- 崩溃报告测试
- 性能监控演示

## 🤝 技术支持

如果您在使用过程中遇到任何问题，请通过以下方式联系我们：

- **技术文档**: [查看完整文档](./LionmoboData_SDK_使用文档.md)
- **问题反馈**: [GitHub Issues](https://github.com/Glenn-fenghuang/LionmoboData/issues)
- **邮件支持**: glenn-fenghuang@lionmobo.com

## 📄 许可证

本项目基于 [MIT 许可证](LICENSE) 开源。

---

**© 2025 Lionmobo. All rights reserved.** 