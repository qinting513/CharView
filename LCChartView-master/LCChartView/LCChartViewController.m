//
//  LCChartViewController.m
//  LCChartView
//
//  Created by liangrongchang on 2017/1/13.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartViewController.h"
#import "HWChartView.h"
#import "UIView+LCLayout.h"

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

@interface LCChartViewController ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (strong, nonatomic) HWChartView *chartViewLine;
@property (strong, nonatomic) HWChartView *chartViewBar;

@end

@implementation LCChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"LCChartView";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavBar];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.chartViewLine];
    [self.contentView addSubview:self.chartViewBar];

    [self resetData];
    self.contentView.contentSize = CGSizeMake(0, self.chartViewBar.LC_bottom + 50);
}

#pragma mark - reponse
- (void)exchange {
    [self resetData];
}

- (void)resetData {
    
        NSArray *xArr = @[@"11/25",@"11/26", @"11/27" , @"11/28", @"11/29", @"11/30", @"12/2"];

//        NSArray *xArr = @[@"11/20",@"11/21", @"11/22", @"11/23", @"11/24", @"11/25",
//                          @"11/26", @"11/27" , @"11/28", @"11/29", @"11/30", @"12/2"];
        NSArray *yArr = @[@"11", @"0.5", @"3", @"4", @"2", @"6", @"7", @"8" , @"9", @"10", @"11", @"20"];
        [self.chartViewBar showChartViewWithXValues:xArr yValues:yArr];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (int i=0; i<90; i++) {
        [temp addObject:@(arc4random_uniform(30))];
    }
    [self.chartViewLine showChartViewWithXValues:xArr yValues:temp.copy];


}

#pragma mark - private mothed
- (void)setupNavBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新数据" style:UIBarButtonItemStylePlain target:self action:@selector(exchange)];
}

- (NSArray *)randomArrayWithCount:(NSInteger)dataCounts {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataCounts; i++) {
        NSString *number = [NSString stringWithFormat:@"%d",arc4random_uniform(1000)];
        [array addObject:number];
    }
    return array.copy;
}


#pragma mark - getter
- (HWChartView *)chartViewLine {
    if (!_chartViewLine) {
        _chartViewLine = [HWChartView chartViewWithType:LCChartViewTypeLine];
        _chartViewLine.frame = CGRectMake(20, 64, self.view.LC_width-40, 200);
    }
    return _chartViewLine;
}

- (HWChartView *)chartViewBar {
    if (!_chartViewBar) {
        _chartViewBar = [[HWChartView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.chartViewLine.frame) + 30, self.view.LC_width-40, 200) chartViewType:LCChartViewTypeBar];
    }
    return _chartViewBar;
}


- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.LC_width, self.view.LC_height - 49)];
    }
    return _contentView;
}

@end
