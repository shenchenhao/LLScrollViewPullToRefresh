//
//  UIScrollView+LLScrollViewPullToRefresh.m
//
//
//  Created by 沈 晨豪 on 14-3-13.
//
//

#import "UIScrollView+LLScrollViewPullToRefresh.h"

#import <objc/runtime.h>


#pragma mark -
#pragma mark - CycleLineView

#define PULL_HEIGHT 65.0f

@interface CycleLineView ()

@property (nonatomic, strong) CAShapeLayer *track_layer;
@property (nonatomic, strong) UIBezierPath *track_path;
@property (nonatomic, strong) CAShapeLayer *progress_layer;
@property (nonatomic, strong) UIBezierPath *progress_path;
@property (nonatomic, strong) UIView       *background_view;


/*
 *void 加载图层
 *
 */
- (void)loadLayer;


/*
 *void 更新印痕的 图层
 *
 */
- (void)updateTrackLayer;

/*
 *void 更新进度条的 图层
 *
 */
- (void)updateProgressLayer;


@end

@implementation CycleLineView

- (void)setProgress:(CGFloat)a_progress
{
   
    _progress = a_progress;
    
    if (_progress > 1.0f) {
        _progress = 1.0f;
        return;
    }
    
    if(_progress < 0.0f)
    {
        _progress = 0.0f;
        return;
    }
    
    
    
    [self updateProgressLayer];
}

- (void)setTrack_color:(UIColor *)track_color
{
    _track_layer.strokeColor = track_color.CGColor;
}

- (void)setProgress_color:(UIColor *)progress_color
{
    _progress_layer.strokeColor = progress_color.CGColor;
}

/*
 *void 设置进度条的 宽度
 *
 *@param progress_width : 进度条的宽度
 *
 */
- (void)setProgress_width: (CGFloat) progress_width
{
    if(_progress_width == progress_width)
        return;
    
    _progress_width               = progress_width;
    
    self.track_layer.lineWidth    = progress_width;
    self.progress_layer.lineWidth = progress_width;
    
    [self updateTrackLayer];
    [self updateProgressLayer];
}

#pragma mark -
#pragma mark - init
#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self loadLayer];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.progress                 = 1.0f;
    
}

/*
 *void 加载图层
 *
 */
- (void)loadLayer
{
    self.backgroundColor                 = [UIColor clearColor];
    
    self.background_view                 = [[UIView alloc] initWithFrame:self.bounds];
    self.background_view.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.background_view];
    
    
    self.track_layer              = [[CAShapeLayer alloc] init];
    self.track_layer.frame        = self.bounds;
    self.track_layer.fillColor    = nil;
    self.track_layer.strokeColor  = [UIColor whiteColor].CGColor;
    
    [self.background_view.layer addSublayer:self.track_layer];
    
    
    
    self.progress_layer               = [[CAShapeLayer alloc] init];
    self.progress_layer.fillColor     = nil;
    //self.progress_layer.backgroundColor = [UIColor clearColor].CGColor;
    self.progress_layer.strokeColor   = [UIColor orangeColor].CGColor;
    self.progress_layer.lineCap       = kCALineCapRound;
    self.progress_layer.frame         = self.bounds;

    self.progress_layer.strokeEnd     = 1;
    self.progress_layer.shadowColor   = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.progress_layer.shadowOpacity = 0.7;
    self.progress_layer.shadowRadius  = 20;
    self.progress_layer.contentsScale = [UIScreen mainScreen].scale;
    
    [self.background_view.layer addSublayer:self.progress_layer];
    
    
    
    self.progress_width           = 1.0f;
    self.track_layer.lineWidth    = self.progress_width;
    self.progress_layer.lineWidth = self.progress_width;
    
}



/*
 *void 更新印痕的 图层
 *
 */
- (void)updateTrackLayer
{
    
    self.track_path       = [UIBezierPath bezierPathWithArcCenter:self.background_view.center
                                                           radius:(self.bounds.size.width - self.progress_width) /  2.0f
                                                       startAngle:- M_PI_2
                                                         endAngle:2 * M_PI - M_PI_2
                                                        clockwise:YES];
    self.track_layer.path  = self.track_path.CGPath;
}

/*
 *void 更新进度条的 图层
 *
 */
- (void)updateProgressLayer
{
    self.progress_path       = [UIBezierPath bezierPathWithArcCenter:self.background_view.center
                                                              radius:(self.bounds.size.width - self.progress_width) /  2.0f
                                                          startAngle:- M_PI_2
                                                            endAngle:(M_PI * 2) * self.progress - M_PI_2
                                                           clockwise:YES];
    


    self.progress_layer.path = self.progress_path.CGPath;
    
    
}

#pragma mark -
#pragma mark - public

/*
 *void 设置进度条
 *
 *@param progress : 进度条百分比
 *@param animated : 是否动画效果
 *
 */
- (void)setProgress: (CGFloat) progress animated: (BOOL) animated
{
    if(!animated)
    {   // NSLog(@"叽叽叽叽 %f",_progress);
        [self setProgress:progress];
        return;
    }
    
    _progress = progress;
    
    if (_progress > 1.0f) {
        _progress = 1.0f;
        return;
    }
    
    if(_progress <= 0.0f)
    {
        _progress = 0.0f;
        return;
    }
    
    

    if (progress >= 0 && progress <= 1.0f)
    {
        CABasicAnimation *animation   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue           = [NSNumber numberWithFloat:((CAShapeLayer *)self.progress_layer.presentationLayer).strokeEnd];
        
        animation.toValue             = [NSNumber numberWithFloat:_progress];
       // NSLog(@"----%f %f ",((CAShapeLayer *)self.progress_layer.presentationLayer).strokeEnd,_progress);
        animation.duration            = 0.1 + 0.1 * (fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode            = kCAFillModeForwards;
        animation.timingFunction     = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [self.progress_layer addAnimation:animation forKey:@"progress_layer"];
    }
    
}

/*
 *void 开始动画
 *
 */
- (void)startAnimation
{
    CATransform3D rotationTransform  = CATransform3DMakeRotation(M_PI, 0,0,.5f);//(CGFloat angle, CGFloat x,CGFloat y, CGFloat z)坐标控制旋转方式。
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    
    animation.toValue             = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration            = 0.4;
    animation.autoreverses        = NO;//为真时，旋转一次，再按原方向转回去
    animation.cumulative          = YES;//为NO时，旋转一次，回到原图再旋转
    animation.removedOnCompletion = NO;
    animation.fillMode            = kCAFillModeForwards;
    animation.repeatCount         = 999999;
    
    
    [self.background_view.layer addAnimation:animation forKey:@"cycel"];
    
    
}

/*
 *void 停止动画
 *
 */
- (void)stopAnimation
{
    
    [self.background_view.layer removeAllAnimations];
    
    self.background_view.transform = CGAffineTransformIdentity;
}



#pragma mark -
#pragma mark - dealloc

- (void)dealloc
{
    [self.progress_layer removeAllAnimations];
}

@end


#pragma mark -
#pragma mark -  LLPullToRefreshView

//#define LLNSLocalizedString(key, comment) \
//[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]
//#define LLNSLocalizedStringFromTable(key, tbl, comment) \
//[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:(tbl)]
//#define LLNSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
//[bundle localizedStringForKey:(key) value:@"" table:(tbl)]
//#define LLNSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
//[bundle localizedStringForKey:(key) value:(val) table:(tbl)]

#define PROGRESS_VALUE 0.96f

@interface LLPullToRefreshView ()

@property (nonatomic,assign) CGFloat              progress;
@property (nonatomic,strong) CycleLineView       *cycle_line_view;
@property (nonatomic,strong) UILabel             *information_label;
@property (nonatomic,strong) UILabel             *update_time_label;
@property (nonatomic,weak  ) UIScrollView        *scroll_view;



@property (nonatomic,copy  ) PullStartBlock       pull_start_block;
@property (nonatomic,copy  ) PullEndBlock         pull_end_block;

@property (nonatomic,assign) PullToRefreshState   pull_state;
@property (nonatomic,assign) BOOL                 is_observing;

@property (nonatomic,assign) BOOL                 is_dragging;


/*
 *void 加载图层
 *
 */
- (void)loadLayer;

@end

@implementation LLPullToRefreshView

@synthesize border_color;
@synthesize cycle_line_size;
@synthesize border_width;

@synthesize pull_start_block;
@synthesize pull_end_block;

@synthesize pull_state;
@synthesize scroll_view;
@synthesize is_observing;
@synthesize is_dragging;


/*
 *void 显示最后刷新的时间
 *
 *@param date_key : 当前时间的key
 *
 */
- (void)showLastRefreshTime: (NSString *) date_key
{
    NSString *key_name = date_key;
    if (nil == date_key)
    {
        key_name = @"PullRefreshView_LastRefresh";
    }
    
    
    NSString *time_str = [[NSUserDefaults standardUserDefaults] objectForKey:key_name];
    
    
    if (nil != time_str)
    {
        self.update_time_label.text = time_str;
    }
    else
    {
        self.update_time_label.text = @"上次刷新: 从未";
    }
    
}

/*
 *void 设置当前时间
 *
 *@param  date_key : 当前时间的key
 *
 */
- (void)setCurrentDate: (NSString *) date_key
{
    NSString *key_name = date_key;
    if (nil == date_key)
    {
        key_name = @"PullRefreshView_LastRefresh";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    self.update_time_label.text = [NSString stringWithFormat:@"上次刷新: %@", [formatter stringFromDate:[NSDate date]]];
   
    [[NSUserDefaults standardUserDefaults] setObject:self.update_time_label.text forKey:key_name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark - private


/*
 *void 加载图层
 *
 */
- (void)loadLayer
{
    
    self.is_observing              = NO;
    
    
    self.is_dragging               = NO;
    
    self.backgroundColor           = [UIColor clearColor];
    /*cycle line layer*/
    self.border_color              = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.border_width              = 1.0f;
    self.cycle_line_view           = [[CycleLineView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                     0.0f,
                                                                                     20.0f,
                                                                                     20.0f)];
    CGPoint point = CGPointMake(CGRectGetWidth(self.bounds) / 2.0f,CGRectGetHeight(self.bounds) / 2.0f);
    point.x      -= 70;
    self.cycle_line_view.center = point;
    self.cycle_line_view.track_layer.hidden = YES;
    [self addSubview:self.cycle_line_view];
    
    /*label*/
    self.information_label = [[UILabel alloc] initWithFrame:CGRectMake(point.x + 30.0f,
                                                                       point.y - 20.0f,
                                                                       180.0f,
                                                                       20.0f)];
    self.information_label.textAlignment = NSTextAlignmentLeft;
    [self.information_label setFont:[UIFont systemFontOfSize:12.0f]];
    [self.information_label setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:self.information_label];
    
    
    self.update_time_label = [[UILabel alloc] initWithFrame:CGRectMake(point.x + 30.0f,
                                                                       point.y,
                                                                       180.0f,
                                                                       20.0f)];
    [self.update_time_label setTextAlignment:NSTextAlignmentLeft];
    [self.update_time_label setFont:[UIFont systemFontOfSize:10.0f]];
    [self.update_time_label setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:self.update_time_label];
    
    [self setPullToRefreshState:PullToRefreshNormal];
}

#pragma mark -
#pragma mark - LLPullToRefreshView init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self loadLayer];
    }
    return self;
}

#pragma mark -
#pragma mark - public



/*
 *void 设置下拉刷新
 *
 *@param pull_state :  下拉的状态
 *
 */
- (void)setPullToRefreshState: (PullToRefreshState) a_pull_state
{
    if (self.pull_state == a_pull_state)
        return;
    
    switch (a_pull_state)
    {
        case PullToRefreshNormal:
        {
            
            //  self.information_label.text =  LLNSLocalizedString(@"下拉即可更新 ...", nil);
            self.information_label.text = @"下拉即可更新 ...";
            [self.cycle_line_view stopAnimation];
        }
            break;
            
        case PullToRefreshPulling:
        {
            //    self.information_label.text =  LLNSLocalizedString(@"松开即可更新 ...", nil);
            self.information_label.text =  @"松开即可更新 ...";
        }
            break;
            
        case PullToRefreshLoading:
        {
            self.information_label.text = @"刷新中...";
            

            if (self.progress <= PROGRESS_VALUE)
            {
                self.progress = PROGRESS_VALUE;
                
                [self.cycle_line_view setProgress:PROGRESS_VALUE animated:YES];
            }
            
            
            [self.cycle_line_view startAnimation];
        }
            break;
            
            
        default:
            break;
    }
    
    self.pull_state = a_pull_state;
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}


- (void)scrollViewDidScroll: (CGPoint) content_offset
{
    /*正在加载中*/
    if (PullToRefreshLoading == self.pull_state)
    {
        return;
    }
    
    /*开始下拉*/
    if (self.scroll_view.dragging && !self.is_dragging)
    {
        self.is_dragging = YES;
        
        if (self.pull_start_block)
        {
            self.pull_start_block();
        }
    }
    
    if (!self.scroll_view.dragging)
    {
        self.is_dragging = NO;
        
    }
    
    
    
    CGFloat temp_progress  = ( content_offset.y  / - PULL_HEIGHT)* PROGRESS_VALUE;
    
    
    self.progress          = temp_progress;
    
    if (self.progress > PROGRESS_VALUE)
    {
        self.progress = PROGRESS_VALUE;
    }
    else if(self.progress <= 0.0f)
    {
        self.progress = 0.0f;
    }
    
    
    
    if (temp_progress <= PROGRESS_VALUE && temp_progress >= 0.0f )
    {
        [self.cycle_line_view setProgress:self.progress animated:YES];
    }
    
    if (PullToRefreshPulling == self.pull_state && !self.scroll_view.dragging)
    {
        if (self.pull_end_block)
            self.pull_end_block(YES);
        return;
    }
    else if(PullToRefreshNormal == self.pull_state && !self.scroll_view.dragging)
    {
        if (self.pull_end_block)
            self.pull_end_block(NO);
        
    }
    
    
    
    if (content_offset.y <= -PULL_HEIGHT)
    {
        
        [self setPullToRefreshState:PullToRefreshPulling];
        
    }
    else
    {
        [self setPullToRefreshState:PullToRefreshNormal];
        
    }
    
    
    
}

@end



#pragma mark -
#pragma mark - UIScrollView (LLScrollViewPullToRefresh)

static char PullToRefreshView;
static char DateKey;




@implementation UIScrollView (LLScrollViewPullToRefresh)

@dynamic date_key;
@dynamic pull_to_refresh_view;

- (void)setPull_to_refresh_view:(LLPullToRefreshView *)pull_to_refresh_view
{
    [self willChangeValueForKey:@"pull_to_refresh_view"];
    objc_setAssociatedObject(self, &PullToRefreshView, pull_to_refresh_view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pull_to_refresh_view"];
}

- (LLPullToRefreshView *)pull_to_refresh_view
{
    return objc_getAssociatedObject(self, &PullToRefreshView);
}

- (void)setDate_key:(NSString *)date_key
{
    [self willChangeValueForKey:@"date_key"];
    objc_setAssociatedObject(self, &DateKey, date_key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"date_key"];
    
    if (nil != self.pull_to_refresh_view)
    {
        [self.pull_to_refresh_view showLastRefreshTime:self.date_key];
    }
    
    
 
}

- (NSString *)date_key
{
    return objc_getAssociatedObject(self, &DateKey);
}


- (PullToRefreshState)getRefreshState
{
    return self.pull_to_refresh_view.pull_state;
}



/*移除所有观察者*/
- (void)removeRefreshObserver
{

    [self setShowPullToRefresh:NO];
}

/*
 *void 设置当前时间
 *
 */
- (void)setCurrentDate
{
    if (nil == self.pull_to_refresh_view) {
        return;
    }
    
    [self.pull_to_refresh_view setCurrentDate:self.date_key];
}

- (void)setPullStartBlock:(PullStartBlock)pull_start_block
{
    if(nil == self.pull_to_refresh_view)
    {
        self.pull_to_refresh_view = [[LLPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                          -PULL_HEIGHT,
                                                                                          self.bounds.size.width,
                                                                                          PULL_HEIGHT)];
        self.pull_to_refresh_view.backgroundColor = [UIColor whiteColor];
        self.pull_to_refresh_view.scroll_view = self;
        self.pull_to_refresh_view.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.pull_to_refresh_view showLastRefreshTime:self.date_key];
        
        [self setShowPullToRefresh:YES];
        [self addSubview:self.pull_to_refresh_view];
        
    }
    
    self.pull_to_refresh_view.pull_start_block = pull_start_block;
    
}

- (void)setPullEndBlock:(PullEndBlock)pull_end_block
{
    if(nil == self.pull_to_refresh_view)
    {
        self.pull_to_refresh_view = [[LLPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                          -PULL_HEIGHT,
                                                                                          self.bounds.size.width,
                                                                                          PULL_HEIGHT)];
        self.pull_to_refresh_view.backgroundColor = [UIColor whiteColor];
        self.pull_to_refresh_view.scroll_view = self;
        self.pull_to_refresh_view.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self.pull_to_refresh_view showLastRefreshTime:self.date_key];
        
        [self setShowPullToRefresh:YES];
        
        [self addSubview:self.pull_to_refresh_view];
        
    }
    
    self.pull_to_refresh_view.pull_end_block = pull_end_block;
    
}

- (void)setShowPullToRefresh: (BOOL) show_pull_to_refresh
{
    if (nil ==self.pull_to_refresh_view)
    {
        return;
    }
    
    self.pull_to_refresh_view.hidden = !show_pull_to_refresh;
    
    if (show_pull_to_refresh)
    {
        if (!self.pull_to_refresh_view.is_observing)
        {
            [self addObserver:self.pull_to_refresh_view forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pull_to_refresh_view forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pull_to_refresh_view forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pull_to_refresh_view.is_observing = YES;
        }
    }
    else {
        if (self.pull_to_refresh_view.is_observing)
        {

            [self removeObserver:self.pull_to_refresh_view forKeyPath:@"contentOffset"];
            [self removeObserver:self.pull_to_refresh_view forKeyPath:@"contentSize"];
            [self removeObserver:self.pull_to_refresh_view forKeyPath:@"frame"];
            self.pull_to_refresh_view.is_observing = NO;
        }
    }
}


/*
 *void 开始动画
 *
 */
- (void)startPullToRefreshAnimation
{
    if (nil == self.pull_to_refresh_view) {
        return;
    }
    
    //[self.pull_to_refresh_view ];
    [self.pull_to_refresh_view setPullToRefreshState:PullToRefreshLoading];
    [UIView animateWithDuration:0.2f animations:^{
        self.contentInset = UIEdgeInsetsMake(PULL_HEIGHT, 0.0f, 0.0f, 0.0f);
        
        
    } completion:^(BOOL finished) {
        
    }];
}


/*
 *void 结束动画
 *
 */
- (void)stopPullToRefreshAnimation
{
    if (nil == self.pull_to_refresh_view) {
        return;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                     } completion:^(BOOL finished) {
                         [self.pull_to_refresh_view setPullToRefreshState:PullToRefreshNormal];
                     }];
}

@end

