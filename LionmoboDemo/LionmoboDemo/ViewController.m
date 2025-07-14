//
//  ViewController.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import <LionmoboData/LionmoboData.h>


@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"LionmoboData SDK演示";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 300, 200, 50);
    button.backgroundColor = UIColor.redColor;
    [button addTarget:self action:@selector(addaction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}


- (void) addaction
{
    SecondViewController *aa = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:aa animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
   
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
