//
//  ViewController.m
//  DragView
//
//  Created by tanjiajun on 2019/5/28.
//  Copyright © 2019 tanjiajun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 60)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)btnClick{
    CustomChannelViewController *channelVC = [[CustomChannelViewController alloc]init];
    [self presentViewController:channelVC animated:NO completion:nil];
}


@end
