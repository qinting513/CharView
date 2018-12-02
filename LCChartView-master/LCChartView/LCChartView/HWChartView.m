//
//  LCChartView.m
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "HWChartView.h"
#import "UIView+LCLayout.h"
#import "LCMethod.h"

static NSTimeInterval duration = 1.0;
static CGFloat yTextCenterMargin = 0;
/** 显示数据的区域高度 */
static CGFloat dataChartHeight = 0;
 //字符y占的高度
static CGFloat axisLabelHieght = 0;

@interface HWChartView ()<UIScrollViewDelegate, CAAnimationDelegate>
// UI
@property (strong, nonatomic) NSMutableArray <UILabel *>*yAxisLabels;
@property (strong, nonatomic) NSMutableArray <UILabel *>*xAxisLabels;
@property (strong, nonatomic) NSMutableArray <UIView *>*allSubView;
@property (strong, nonatomic) UIScrollView *scrollView;

/** 原先X轴点距离 */
@property (assign, nonatomic) CGFloat orginXAxisMargin;
//坐标轴原点
@property (assign, nonatomic) CGPoint originPoint;
/** y分割线 */
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*ySeparatorLayers;
/** 折线图 填充的layer*/
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*lineShapeLayers;

@end

@implementation HWChartView

#pragma mark - API
+ (instancetype)chartViewWithType:(LCChartViewType)type {
    HWChartView *axisView = [[HWChartView alloc] init];
    axisView.chartViewType = type;
    return axisView;
}

- (instancetype)initWithFrame:(CGRect)frame chartViewType:(LCChartViewType)type {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        self.chartViewType = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

/** 开始描绘LCChartView */
- (void)showChartViewWithXValues:(NSArray <NSString *>*)xValues yValues:(NSArray <NSString *>*)yValues{
    _xValues = xValues;
    _yValues = yValues;
    _yAxisMaxValue = [[yValues valueForKeyPath:@"@max.floatValue"] floatValue];
    [self showChartView];
}

#pragma mark - private method
- (void)initData {
    _xAxisColor      = [UIColor darkGrayColor];
    _yAxisColor      = [UIColor darkGrayColor];
    _normalColor     = [UIColor orangeColor];
    _chartViewType = LCChartViewTypeBar;
    _axisFontSize = 10;
    _yAxisToLeft = 30;
    _topMargin = 35;
    _xTextToAxis = 5.0;
    _orginXAxisMargin = 15;
    _yTextToAxis = 2.0;
    //平均有4等分
    _yAxisCount = 4;
    _showAnimation = YES;
    self.layer.masksToBounds = YES;
}

- (void)showChartView {
    if (self.xValues.count == 0) {
        NSLog(@"请设置展示的点数据");
        return;
    };
    
    [self resetDataSource];
    [self drawYAxis];
    [self drawXAxis];
    [self drawYSeparators];
    if (self.chartViewType == LCChartViewTypeLine) {
        [self drawLineChartViewPots];
        [self drawLineChartViewLines];
    } else {
        [self drawBarChartViewBars];
    }
    [self drawDisplayLabels];
    [self addAnimation:self.showAnimation];
}

#pragma mark - 重置数据
- (void)resetDataSource {
    //移除折现上的按钮点
    if (self.yValueButtons.count) {
        [self.yValueButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    // 移除所有的Label,CAShapeLayer
    if (self.allSubView) {
        [self.allSubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.allSubView removeAllObjects];
    }
    // 移除y轴分割线
    if (self.ySeparatorLayers.count) {
        [self.ySeparatorLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.ySeparatorLayers removeAllObjects];
    }
    // 移除 折线
    if (self.lineShapeLayers.count) {
        [self.lineShapeLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.lineShapeLayers removeAllObjects];
    }
    //x轴label
    if (self.xAxisLabels.count) {
        [self.xAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.xAxisLabels removeAllObjects];
    }
    //y轴label
    if (self.yAxisLabels.count) {
        [self.yAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.yAxisLabels removeAllObjects];
    }
}

#pragma mark - 描绘Y轴
- (void)drawYAxis {
    //字符y占的高度
    axisLabelHieght = [LCMethod sizeWithText:@"y" fontSize:_axisFontSize].height;
    // 数据展示的高度
    dataChartHeight = self.LC_height - _topMargin - _xTextToAxis - axisLabelHieght;
    // ylabel之间的间隙
    yTextCenterMargin = dataChartHeight / _yAxisCount;
    _originPoint = CGPointMake(_yAxisToLeft, self.LC_height - axisLabelHieght - _xTextToAxis);
    
    // 添加Y轴Label
    for (int i = 1; i < _yAxisCount+1; i++) {
        CGFloat avgValue = _yAxisMaxValue / _yAxisCount;
        NSString *title = [NSString stringWithFormat:@"%.2f", avgValue * i];
        UILabel *label = [self labelWithTextColor:[UIColor darkGrayColor] backColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight lineNumber:1 tiltle:title fontSize:_axisFontSize];
      
        label.LC_x = 0;
        label.LC_height = axisLabelHieght;
        label.LC_width = _yAxisToLeft - _yTextToAxis;
        label.LC_centerY = _topMargin + (_yAxisCount - i) * yTextCenterMargin;
        [self addSubview:label];
        [self.yAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.yAxisLabels];
    
    // 添加scrollview
    [self insertSubview:self.scrollView atIndex:0];
    self.scrollView.frame = CGRectMake(_yAxisToLeft, 0, self.LC_width - _yAxisToLeft, self.LC_height);
}

#pragma mark - 描绘X轴
- (void)drawXAxis {
    // 添加X轴Label 最多显示7个
    CGFloat labelWidth = (self.scrollView.LC_width - self.orginXAxisMargin * 2) / 7.0;
    for (int i = 0; i < self.xValues.count; i++) {
        NSString *title = self.xValues[i];
        
        UILabel *label = [self labelWithTextColor:[UIColor darkGrayColor] backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:title fontSize:_axisFontSize];

        CGSize labelSize = [LCMethod sizeWithText:title fontSize:_axisFontSize];
        label.LC_x = self.orginXAxisMargin + labelWidth * i;
        label.LC_y = self.LC_height - labelSize.height;
        label.LC_size = CGSizeMake(labelWidth, labelSize.height);
        [self.scrollView addSubview:label];
        [self.xAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.xAxisLabels];
    
    // 画x轴
    UIView *xLine = [[UIView alloc] init];
    xLine.backgroundColor = [UIColor darkGrayColor];
    xLine.frame = CGRectMake(_yAxisToLeft, _originPoint.y, self.scrollView.LC_width , 0.5);
    [self addSubview:xLine];
    
    // scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(self.orginXAxisMargin * 2 + labelWidth * self.xValues.count, 0);
}

#pragma mark - Y轴分割线
- (void)drawYSeparators {
    // 添加Y轴分割线
    for (int i = 0; i < self.yAxisLabels.count; i++) {
        UILabel *yLabel = self.yAxisLabels[i];
        UIBezierPath *ySeparatorPath = [UIBezierPath bezierPath];
        [ySeparatorPath moveToPoint:CGPointMake(_yAxisToLeft, yLabel.LC_centerY)];
        [ySeparatorPath addLineToPoint:CGPointMake(self.scrollView.LC_width + _yAxisToLeft, yLabel.LC_centerY)];
        CAShapeLayer *yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:0.5 fillColor:[UIColor clearColor] strokeColor:[UIColor darkGrayColor]];
        yshapeLayer.lineDashPattern = @[@(3), @(3)];
        [self.layer addSublayer:yshapeLayer];
        [self.ySeparatorLayers addObject:yshapeLayer];
    }
}

#pragma mark - 显示数据label
- (void)drawDisplayLabels {

    // 多组数据显示label太混乱
    if (_chartViewType == LCChartViewTypeLine && self.xValues.count > 1) {
        return;
    }
//    NSInteger centerFlag = self.dataSource.count / 2;
//    for (int i = 0 ; i < self.dataSource.count; i++) {
//        NSString *xValue = self.xValues[i];
//        NSMutableArray *plotLabels = [NSMutableArray array];
//        for (int j = 0; j < model.plots.count; j++) {
//            NSString *value = model.plots[j];
//            if (value.floatValue < 0) {
//                value = @"0";
//            }
//            UILabel *label = [self labelWithTextColor:self.plotsLabelColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:value fontSize:self.plotsLabelFontSize];
//            label.tag = j;
//            [label sizeToFit];
//            switch (self.chartViewType) {
//                case LCChartViewTypeLine:{
//                    label.LC_centerX = self.xAxisLabels[j].LC_centerX;
//                }
//                    break;
//                case LCChartViewTypeBar:{
//                    if (self.dataSource.count % 2 == 0) { // 双数组
//                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
//                    } else { // 单数组
//                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
//                    }
//                }
//                    break;
//
//                default:
//                    break;
//            }
//            label.LC_bottom = [self getValueHeightWith:value] - _displayPlotToLabel;
//            [self.scrollView addSubview:label];
//            [plotLabels addObject:label];
//            [self.allSubView addObjectsFromArray:plotLabels];
//            // 处理重叠label
//            [self handleOverlapViewWithViews:plotLabels];
//        }
//    }
}

#pragma mark - 描绘折线图点和线
/** 描述折线图数据点 */
- (void)drawLineChartViewPots {
        // 画点
        CGFloat btnWH = 1.0;
        UILabel *firstLabel = self.xAxisLabels.firstObject;
        UILabel *lastLabel = self.xAxisLabels.lastObject;
        CGFloat space = (lastLabel.LC_centerX - firstLabel.LC_centerX) / self.yValues.count;
    
        for (int j = 0; j < _yValues.count; j++) {
            // 添加数据点button
            UIButton *button = [[UIButton alloc] init];
            [button setBackgroundImage:[LCMethod imageFromColor:UIColor.redColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateNormal];
            [button setBackgroundImage:[LCMethod imageFromColor:UIColor.redColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateSelected];
            button.tag = j + 100;
            button.LC_size = CGSizeMake(btnWH, btnWH);
            if (self.xValues.count == self.yValues.count) {
                button.center = CGPointMake(self.xAxisLabels[j].LC_centerX, [self getValueHeightWith:self.yValues[j]]);
            }else{
                button.center = CGPointMake(firstLabel.LC_centerX+space*j, [self getValueHeightWith:self.yValues[j]]);
                if (j == self.yValues.count -1) {
                   button.center = CGPointMake(firstLabel.LC_centerX + space * j + 1.0, [self getValueHeightWith:self.yValues[j]]);
                }
            }
            button.layer.cornerRadius = btnWH / 2;
            button.layer.masksToBounds = YES;
            [self.scrollView addSubview:button];
            [self.yValueButtons addObject:button];
            // 处理重叠点
            [self handleOverlapViewWithViews:_yValueButtons];
        }
    
        [self.allSubView addObjectsFromArray:self.yValueButtons];
}

/** 根据数据点画线 */
- (void)drawLineChartViewLines {
    // 画线
    UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
    // 填充
    CAShapeLayer *lineShapeLayer = nil;
    
    [lineChartPath moveToPoint:CGPointMake(_originPoint.x, _originPoint.y)];
    for (int i = 0; i < self.yValueButtons.count; i++) {
        [lineChartPath addLineToPoint:self.yValueButtons[i].center];
    }
    [lineChartPath addLineToPoint:CGPointMake(self.yValueButtons.lastObject.LC_centerX, _originPoint.y)];
    lineShapeLayer = [LCMethod shapeLayerWithPath:lineChartPath lineWidth:1.0 fillColor:UIColor.orangeColor strokeColor:UIColor.redColor];
    [self.lineShapeLayers addObject:lineShapeLayer];
    [self.scrollView.layer addSublayer:lineShapeLayer];
}

#pragma mark - ChartViewBar柱状图
/** 根据显示点描绘柱状图 */
- (void)drawBarChartViewBars {
 
    CGFloat barW = 10.0;
    for (int i = 0; i < self.xAxisLabels.count; i++) {
        UILabel *xLabel = self.xAxisLabels[i];
        CGFloat barX = (xLabel.LC_width - barW) / 2.0 + xLabel.LC_x;
        CGFloat barY = [self getValueHeightWith:self.yValues[i]];
        CGFloat barH = self.LC_height - xLabel.LC_height - barY - barW/2.0 + 1.0;
    
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(barX, barY, barW, barH);
        [btn setImage:[self createImageWithColor:self.normalColor rect:btn.bounds] forState:UIControlStateNormal];
        [btn setImage:[self createImageWithColor:UIColor.redColor rect:btn.bounds] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + i;
        [self.scrollView addSubview:btn];
        
        //绘制顶部圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btn.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(btn.LC_width,btn.LC_width)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = btn.bounds;
        maskLayer.path = maskPath.CGPath;
        btn.layer.mask = maskLayer;
    
        [self.yValueButtons addObject:btn];
     }
    [self.allSubView addObjectsFromArray:self.yValueButtons];
}

-(UIImage*)createImageWithColor:(UIColor*)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)btnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
}


#pragma mark - private method
/** 处理label重叠显示的情况 */
- (void)handleOverlapViewWithViews:(NSArray <UIView *>*)views {
    // 如果Label的文字有重叠，那么隐藏
    UIView *firstView = views.firstObject;
    for (int i = 1; i < views.count; i++) {
        UIView *view = views[i];
        CGFloat maxX = CGRectGetMaxX(firstView.frame);
        if ((maxX + 3) > view.LC_x) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
            firstView = view;
        }
    }
}

- (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = fillColor.CGColor;
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

/** 数据点高度 */
- (CGFloat)getValueHeightWith:(NSString *)value {
    return dataChartHeight - value.floatValue / _yAxisMaxValue * dataChartHeight + _topMargin;
}

/** label */
- (UILabel *)labelWithTextColor:(UIColor *)textColor backColor:(UIColor *)backColor textAlignment:(NSTextAlignment)textAlignment lineNumber:(NSInteger)number tiltle:(NSString *)title fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = textColor;
    if (backColor) {
        label.backgroundColor = backColor;
    }
    label.textAlignment = textAlignment;
    label.numberOfLines = number;
    if (fontSize != 0) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    return label;
}

- (void)addAnimation:(NSArray <CAShapeLayer *>*)shapeLayers delegate:(id<CAAnimationDelegate>)delegate duration:(NSTimeInterval)duration {
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.delegate = delegate;
    stroke.duration = duration;
    stroke.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    stroke.fromValue = [NSNumber numberWithFloat:0.0f];
    stroke.toValue = [NSNumber numberWithFloat:1.0f];
    for (CAShapeLayer *shapeLayer in shapeLayers) {
        [shapeLayer addAnimation:stroke forKey:nil];
    }
}


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *layer in self.lineShapeLayers) {
        layer.hidden = NO;
    }
    [self addAnimation:self.lineShapeLayers delegate:nil duration:duration];
    
    [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:duration animations:^{
            obj.alpha = 1.0;
        }];
    }];
}

/** addAnimation */
- (void)addAnimation:(BOOL)animation {
    if (animation) {
        [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = 0.0;
        }];
        for (CAShapeLayer *layer in self.lineShapeLayers) {
            layer.hidden = YES;
        }
        [self addAnimation:self.ySeparatorLayers delegate:self duration:0.5];
    }
}

#pragma mark - getter
-(NSMutableArray<UIButton *> *)yValueButtons{
    if (!_yValueButtons) {
        _yValueButtons = [[NSMutableArray alloc] init];
    }
    return _yValueButtons;
}
- (NSMutableArray<UILabel *> *)yAxisLabels {
    if (!_yAxisLabels) {
        _yAxisLabels = [[NSMutableArray alloc] init];
    }
    return _yAxisLabels;
}

- (NSMutableArray<UILabel *> *)xAxisLabels {
    if (!_xAxisLabels) {
        _xAxisLabels = [[NSMutableArray alloc] init];
    }
    return _xAxisLabels;
}

- (NSMutableArray<CAShapeLayer *> *)ySeparatorLayers {
    if (!_ySeparatorLayers) {
        _ySeparatorLayers = [[NSMutableArray alloc] init];
    }
    return _ySeparatorLayers;
}

- (NSMutableArray<CAShapeLayer *> *)lineShapeLayers {
    if (!_lineShapeLayers) {
        _lineShapeLayers = [[NSMutableArray alloc] init];
    }
    return _lineShapeLayers;
}

- (NSMutableArray<UIView *> *)allSubView {
    if (!_allSubView) {
        _allSubView = [[NSMutableArray alloc] init];
    }
    return _allSubView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}


@end
