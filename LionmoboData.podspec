Pod::Spec.new do |spec|
  spec.name         = "LionmoboData"
  spec.version      = "1.0.0"
  spec.summary      = "LionmoboData iOS SDK - 数据统计分析框架"
  spec.description  = <<-DESC
                      LionmoboData是一个功能强大的iOS数据统计分析SDK，提供：
                      * 页面访问跟踪
                      * 用户行为点击统计
                      * 应用启动监控
                      * 崩溃日志收集
                      * 设备信息收集
                      * 自定义事件统计
                      DESC
  
  spec.homepage     = "https://github.com/Glenn-fenghuang/LionmoboData"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Lionmobo" => "glenn-fenghuang@lionmobo.com" }
  
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/Glenn-fenghuang/LionmoboData.git", :tag => "#{spec.version}" }
  
  spec.vendored_frameworks = "LionmoboData.xcframework"
  spec.requires_arc = true
  
  spec.frameworks = "Foundation", "UIKit", "CoreFoundation"
end 