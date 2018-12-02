//
//  LCChartView.h
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LCChartViewType) {
    LCChartViewTypeLine,
    LCChartViewTypeBar
};

@interface HWChartView : UIView

// 是否显示动画
@property (assign, nonatomic) BOOL showAnimation;
//图表类型
@property (assign, nonatomic) LCChartViewType chartViewType;
// x轴的值
@property (strong, nonatomic) NSArray <NSString *> *xValues;
//柱状或者折现 显示的颜色
@property (strong, nonatomic) UIColor *normalColor;
//选择时的高亮颜色
@property (strong, nonatomic) UIColor *highlightedColor;
// y轴的值
@property (strong, nonatomic) NSArray <NSString *>*yValues;
//折线图上转折点的按钮，通过这些点连接成折线图 或者 柱状btn
@property (strong, nonatomic) NSMutableArray <UIButton *>*yValueButtons;
// y轴最大值
@property (assign, nonatomic) CGFloat yAxisMaxValue;

// y轴label距离左边的距离
@property (assign, nonatomic) CGFloat yAxisToLeft;
//y轴个数 等分个数
@property (assign, nonatomic) NSInteger yAxisCount;
//x轴距离顶部距离
@property (assign, nonatomic) CGFloat topMargin;
//x轴label距离轴线的距离
@property (assign, nonatomic) CGFloat xTextToAxis;
//y轴label距离轴线的距离
@property (assign, nonatomic) CGFloat yTextToAxis;
// x,y轴字体大小
@property (assign, nonatomic) CGFloat axisFontSize;
//x轴轴线颜色
@property (strong, nonatomic) UIColor *xAxisColor;
//y轴颜色
@property (strong, nonatomic) UIColor *yAxisColor;


/** 初始化 */
+ (instancetype)chartViewWithType:(LCChartViewType)type;
- (instancetype)initWithFrame:(CGRect)frame chartViewType:(LCChartViewType)type;

/** 开始描绘LCChartView */
//xAxis x轴的值 yValues y轴的值
- (void)showChartViewWithXValues:(NSArray <NSString *>*)xValues yValues:(NSArray <NSString *>*)yValues;

@end
