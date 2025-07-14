# LionmoboData iOS SDK 安装指南

## 📦 SDK 内容

这个分发包包含：

- `LionmoboData.xcframework` - 编译好的 iOS SDK
- `LionmoboDemo/` - 示例项目
- `README.md` - 项目概述
- `LionmoboData_SDK_使用文档.md` - 详细使用文档
- `INSTALLATION.md` - 本安装指南

## 🚀 快速集成

### 方式一：直接添加 XCFramework（推荐）

1. 将 `LionmoboData.xcframework` 拖入您的 Xcode 项目
2. 在 **General** → **Frameworks, Libraries, and Embedded Content** 中确保 Framework 设置为 **Embed & Sign**
3. 在需要使用的地方导入 SDK：

```objc
#import <LionmoboData/LionmoboData.h>
```

## ⚙️ 基础配置

在 `AppDelegate.m` 中初始化 SDK：

```objc
#import <LionmoboData/LionmoboData.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"您的应用ID";
    config.serverURL = @"您的服务器地址";
    config.apiKey = @"您的API密钥";
    config.apiSecret = @"您的API密钥";
    config.debugMode = YES;
    
    [LionmoboData startWithConfig:config];
    return YES;
}
```

**SDK 版本**: 1.0.0
