//
//  LionmoboDataClickEvent.m
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import "LionmoboDataClickEvent.h"
#import "../PageTracking/LionmoboDataPageTracker.h"
#import "../PageTracking/LionmoboDataPageEvent.h"
#import <sys/utsname.h>

@implementation LionmoboDataClickEvent

+ (instancetype)eventWithElement:(UIView *)element pageName:(NSString *)pageName {
    LionmoboDataClickEvent *event = [[LionmoboDataClickEvent alloc] init];
    
    // 生成唯一事件ID
    event.eventId = [[NSUUID UUID] UUIDString];
    event.pageName = pageName ?: @"Unknown";
    event.timestamp = [[NSDate date] timeIntervalSince1970];
    event.pagePath = [[LionmoboDataPageTracker sharedTracker].pagePath componentsJoinedByString:@" > "];
    
    LionmoboDataPageEvent *lastEvent = nil;
    NSString *lastKey = [LionmoboDataPageTracker sharedTracker].activePageEvents.allKeys.lastObject;
    if (lastKey) {
        lastEvent = [LionmoboDataPageTracker sharedTracker].activePageEvents[lastKey];
    }
    event.pageTitle = lastEvent.pageTitle?:@"";
    // 提取元素信息
    [event extractElementInfo:element];

    return event;
}

- (void)extractElementInfo:(UIView *)element {
    // 元素类型
    self.elementType = NSStringFromClass([element class]);
    
    // 元素位置
    CGPoint position = element.center;
    self.elementPosition = [NSString stringWithFormat:@"{%.1f, %.1f}", position.x, position.y];
    self.elementPositionX = [NSString stringWithFormat:@"%.1f", position.x];
    self.elementPositionY = [NSString stringWithFormat:@"%.1f", position.y]; ;
    // 先提取元素内容
    self.elementContent = [self extractContentFromElement:element];
    
    // 再基于所有信息生成元素ID
    self.elementId = [self generateElementId:element];
}

- (NSString *)generateElementId:(UIView *)element {
    // 优先级1: accessibilityIdentifier
    if (element.accessibilityIdentifier && element.accessibilityIdentifier.length > 0) {
        return element.accessibilityIdentifier;
    }
    
    // 优先级2: tag（如果不为0）
    if (element.tag != 0) {
        return [NSString stringWithFormat:@"tag_%ld", (long)element.tag];
    }
    
    // 优先级3: 基于元素特征生成稳定的哈希ID
    return [self generateHashIdForElement:element];
}

- (NSString *)generateHashIdForElement:(UIView *)element {
    NSMutableString *identifier = [NSMutableString string];
    
    // 元素类型
    [identifier appendString:NSStringFromClass([element class])];
    
    // 元素内容（使用已经提取的内容）
    if (self.elementContent && self.elementContent.length > 0) {
        // 清理内容，只保留字母数字
        NSString *cleanContent = [[self.elementContent componentsSeparatedByCharactersInSet:
                                 [[NSCharacterSet alphanumericCharacterSet] invertedSet]] 
                                 componentsJoinedByString:@""];
        if (cleanContent.length > 0) {
            [identifier appendFormat:@"_%@", cleanContent];
        }
    }
    
    // 元素在父视图中的索引
    UIView *superview = element.superview;
    if (superview) {
        NSInteger index = [superview.subviews indexOfObject:element];
        if (index != NSNotFound) {
            [identifier appendFormat:@"_idx%ld", (long)index];
        }
    }
    
    // 元素frame（相对稳定的位置信息）
    CGRect frame = element.frame;
    [identifier appendFormat:@"_f%.0f%.0f%.0f%.0f", 
                 frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
    
    // 生成哈希值
    NSUInteger hash = [identifier hash];
    return [NSString stringWithFormat:@"auto_%lx", (unsigned long)hash];
}

- (NSString *)extractContentFromElement:(UIView *)element {
    // UIButton
    if ([element isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)element;
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title && title.length > 0) {
            return title;
        }
    }
    
    // UILabel
    if ([element isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)element;
        if (label.text && label.text.length > 0) {
            return label.text;
        }
    }
    
    // UITextField
    if ([element isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)element;
        if (textField.placeholder && textField.placeholder.length > 0) {
            return [NSString stringWithFormat:@"[TextField] %@", textField.placeholder];
        }
    }
    
    // UIImageView
    if ([element isKindOfClass:[UIImageView class]]) {
        return @"[Image]";
    }
    
    // UITableViewCell
    if ([element isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)element;
        if (cell.textLabel.text && cell.textLabel.text.length > 0) {
            return cell.textLabel.text;
        }
    }
    
    // 使用 accessibility label 作为备选
    if (element.accessibilityLabel && element.accessibilityLabel.length > 0) {
        return element.accessibilityLabel;
    }
    
    return nil;
}


- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"event_id"] = self.eventId;
    dict[@"page_name"] = self.pageName;
    dict[@"element_type"] = self.elementType;
    dict[@"element_position"] = self.elementPosition;
    dict[@"timestamp"] = @(self.timestamp);
    
    // 可选属性
    if (self.elementId) {
        dict[@"element_id"] = self.elementId;
    }
    if (self.elementContent) {
        dict[@"element_content"] = self.elementContent;
    }
    
    return [dict copy];
}

@end 
