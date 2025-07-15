//
//  ViewController.h
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *demoSections;
@property (nonatomic, strong) UILabel *sdkStatusLabel;
@property (nonatomic, strong) UIButton *customButton;
@property (nonatomic, strong) UITableView *tableView;

@end

