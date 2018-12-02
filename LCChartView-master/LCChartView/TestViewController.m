//
//  TestViewController.m
//  LCChartView
//
//  Created by qt on 2018/12/2.
//  Copyright © 2018 Rochang. All rights reserved.
//

#import "TestViewController.h"
#import "LCChartViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 100, 50)];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"xiayige" forState:UIControlStateNormal];
}

- (void)next:(id)sender {
    [self.navigationController pushViewController:[LCChartViewController new] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
