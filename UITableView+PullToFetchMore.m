//
//  UIScrollView+PullToFetchMore.m
//  sch的下拉加载
//
//  Created by 沈 晨豪 on 14-3-24.
//  Copyright (c) 2014年 sch. All rights reserved.
//

#import "UITableView+PullToFetchMore.h"
#import <objc/runtime.h>



#pragma mark -
#pragma mark - LLBlockProgressView
@interface LLBlockProgressView : UIView

/*
 *void 更新进度条
 *
 *@param progress 进度条的值
 *
 */
- (void)updateBlockProgress: (CGFloat) progress;

/*
 *void 设置遮掩图层的color
 *
 *@param color : 设置掩盖图层的颜色
 *
 */
- (void)setCoverUpColor: (UIColor*) color;


@end



#define BLOCK_SIZE      CGSizeMake(5, 10)
#define CALCULATE_WIDHT 3.0f  //估算的值


@interface LLBlockProgressView()

@property (nonatomic,assign) CGFloat   block_space_width;

@property (nonatomic,strong) CALayer  *move_layer;
@property (nonatomic,assign) CGFloat   progress;

@property (nonatomic,assign) int       block_count;

@end

@implementation LLBlockProgressView

#pragma mark -
#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        /*移动的图层*/
        self.move_layer       = [[CALayer alloc] init];
        
        self.clipsToBounds    = YES;
        
        self.move_layer.frame = self.bounds;
        
        [self.layer addSublayer:self.move_layer];
        
        self.move_layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        /*计算值*/
        CGFloat temp_width     =  (CGRectGetWidth(self.bounds) + CALCULATE_WIDHT) / (BLOCK_SIZE.width + CALCULATE_WIDHT);
        CGFloat overstep_width = temp_width - (int)temp_width;
        
        if (overstep_width > 0.5f)
        {
            self.block_count = (int)temp_width + 1;
            self.block_space_width =  CALCULATE_WIDHT -  (1.0f - overstep_width) * (BLOCK_SIZE.width + CALCULATE_WIDHT) / (CGFloat)((int)temp_width);
        }
        else
        {
            self.block_count = (int)temp_width;
            self.block_space_width = CALCULATE_WIDHT +  overstep_width * (BLOCK_SIZE.width + CALCULATE_WIDHT) / (CGFloat)(self.block_count - 1);
        }
        
        
    }
    return self;
}

/*
 *void 设置遮掩图层的color
 *
 *@param color : 设置掩盖图层的颜色
 *
 */
- (void)setCoverUpColor: (UIColor*) color
{
    self.move_layer.backgroundColor = color.CGColor;
}


- (void)updateBlockProgress: (CGFloat) progress
{
    CGFloat temp_progress = progress;
    if (temp_progress > 1.0f)
    {
        temp_progress = 1.0f;
    }
    else if(temp_progress < 0.0f)
    {
        temp_progress = 0.0f;
    }
    
    self.progress = temp_progress;
    
    self.move_layer.frame = CGRectOffset(self.bounds,
                                         temp_progress * self.bounds.size.width,
                                         0.0f);
    [self setNeedsDisplay];
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 252/ 255.0f, 209/ 255.0f, 9/ 255.0f,0.3 + 0.7 * self.progress);//颜色（RGB）,透明度
    
    CGFloat y = (rect.size.height - BLOCK_SIZE.height) / 2;
    
    for (int i = 0; i < self.block_count; ++i)
    {
        CGRect rect = CGRectMake(i * (self.block_space_width + BLOCK_SIZE.width),
                                 y,
                                 BLOCK_SIZE.width,
                                 BLOCK_SIZE.height);
        CGContextFillRect(context,rect);
    }
    
}

@end


#pragma mark -
#pragma mark - LLPullToFetchtMoreView

//高度45.0f
@interface LLPullToFetchMoreView()


/*
 *void 加载图层
 *
 */
- (void)loadLayer;


@property (nonatomic,weak  ) UITableView             *scroll_view;              //加载的view

@property (nonatomic,strong) LLBlockProgressView     *block_progress_view;      //进度条
@property (nonatomic,strong) UIActivityIndicatorView *activity_indicator_view;  //加载的view
@property (nonatomic,strong) UILabel                 *indicator_label;          //拉动信息的label

@property (nonatomic,assign) PullToFetchMoreState     pull_to_fetch_more_state; //上拉加载的状态
@property (nonatomic,assign) CGFloat                  progress;                 //进度条
@property (nonatomic,assign) BOOL                     is_observing;
@property (nonatomic,assign) BOOL                     is_start_drag;            //是否开始拖拽

@property (nonatomic,copy  ) PullFetchMoreEndBlock    fetch_more_end_block;     //获取更多结束的block

@end



@implementation LLPullToFetchMoreView

#pragma mark -
#pragma mark - private

/*
 *void 加载图层
 *
 */
- (void)loadLayer
{
    
    self.backgroundColor = [UIColor clearColor];
    
    /*load view*/
    self.activity_indicator_view                  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity_indicator_view.hidesWhenStopped = YES;
    
    CGRect  activity_bounds = [self.activity_indicator_view bounds];
    CGPoint origin          = CGPointMake(roundf((self.bounds.size.width-activity_bounds.size.width)/2), roundf((self.bounds.size.height-activity_bounds.size.height)/2));
    [self.activity_indicator_view setFrame:CGRectMake(origin.x, origin.y, activity_bounds.size.width, activity_bounds.size.height)];
    
    [self addSubview:self.activity_indicator_view];
    
    
    /*progress*/
    CGFloat progress_width   = 120.0f;
    CGFloat progress_heihgt  = 12.0f;
    CGFloat x_offset         = (CGRectGetWidth(self.frame) - progress_width) / 2.0f;
    
    self.block_progress_view = [[LLBlockProgressView alloc] initWithFrame:CGRectMake(x_offset,
                                                                                     30.0f,
                                                                                     progress_width,
                                                                                     progress_heihgt)];
    [self.block_progress_view setBackgroundColor:[UIColor whiteColor]];
    
    [self addSubview:self.block_progress_view];
    
    /*label*/
    self.indicator_label               = [[UILabel alloc] init];
    self.indicator_label.textColor     = [UIColor grayColor];
    self.indicator_label.textAlignment = NSTextAlignmentCenter;
    [self.indicator_label setFrame:CGRectMake(0.0f,
                                              5.0f,
                                              CGRectGetWidth(self.bounds),
                                              20.0f)];
    [self.indicator_label setBackgroundColor:[UIColor clearColor]];
    [self.indicator_label setFont:[UIFont systemFontOfSize:15.0f]];
    [self setPullToFetchMoreState:PullToFetchMoreNormal];
    
    [self addSubview:self.indicator_label];
    
    self.is_start_drag = NO;
    
}


#pragma mark -
#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    
    if (self)
    {
        [self loadLayer];
    }
    
    return self;
}


#pragma mark -
#pragma mark - public


/*
 *void 设置上拉加载
 *
 *@param a_pull_to_fetch_more_state :  上拉加载 的状态
 *
 */
- (void)setPullToFetchMoreState: (PullToFetchMoreState) a_pull_to_fetch_more_state
{
    if (a_pull_to_fetch_more_state == self.pull_to_fetch_more_state)
        return;
    
    self.pull_to_fetch_more_state = a_pull_to_fetch_more_state;
    
    switch (self.pull_to_fetch_more_state)
    {
        case PullToFetchMoreNormal:
            self.indicator_label.text = @"上拉加载更多";
            self.progress = 0.0f;
            [self.block_progress_view updateBlockProgress:0.0f];
            [self stopAnimation];
            break;
            
        case PullToFetchMorePulling:
            self.indicator_label.text = @"松开加载更多";
            break;
        case PullToFetchMoreLoading:
            self.is_start_drag = NO;
            [self startAnimation];
            break;
        default:
            break;
    }
}



/*
 *void 开始上拉动画
 *
 */
- (void)startAnimation
{
    
    self.indicator_label.hidden     = YES;
    self.block_progress_view.hidden = YES;
    [self.activity_indicator_view startAnimating];
}

/*
 *void 结束上拉动画
 *
 */
- (void)stopAnimation
{
    self.indicator_label.hidden     = NO;
    self.block_progress_view.hidden = NO;
    [self.activity_indicator_view stopAnimating];
}

#pragma mark -
#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (self.scroll_view.contentSize.height >= CGRectGetHeight(self.scroll_view.bounds))
        {
            [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
        }
    }
}

#define OFF_SET_Y 60.0f
- (void)scrollViewDidScroll: (CGPoint) point
{

   
    if (PullToFetchMoreLoading == self.pull_to_fetch_more_state )
        return;
    
    if (NO == self.is_start_drag && self.scroll_view.isDragging)
    {
        self.is_start_drag = YES;
    }
    
    if (!self.is_start_drag)
        return;
    
    CGFloat y_offset = point.y +  CGRectGetHeight(self.scroll_view.bounds) - self.scroll_view.contentSize.height ;
    
    
    CGFloat temp_progress = y_offset / 15.0f;
    
    if (temp_progress > 1.0f) {
        temp_progress = 1.0f;
    }
    else if(temp_progress < 0.0f)
    {
        temp_progress = 0.0f;
    }
    self.progress = temp_progress;
    
    
    [self.block_progress_view updateBlockProgress:self.progress];
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.indicator_label.alpha = 0.5f +  0.5f * self.progress;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    if (PullToFetchMorePulling == self.pull_to_fetch_more_state && !self.scroll_view.dragging)
    {
 
        if (self.fetch_more_end_block)
            self.fetch_more_end_block(YES);
        return;
    }
    else if(PullToFetchMoreNormal == self.pull_to_fetch_more_state && !self.scroll_view.dragging)
    {
        if (self.fetch_more_end_block)
            self.fetch_more_end_block(NO);
    }
    
    if (self.progress >= 1.0f)
    {
        [self setPullToFetchMoreState:PullToFetchMorePulling];
        
    }
    else
    {
        [self setPullToFetchMoreState:PullToFetchMoreNormal];
        
    }
    
    
}

@end



#pragma mark -
#pragma mark - UITab;e PullToFetchMore

static char LL_Pull_To_Fetch_More_View_Key;

@implementation UITableView (PullToFetchMore)

@dynamic pull_to_fetch_more_view;

- (void)setPull_to_fetch_more_view:(LLPullToFetchMoreView *)pull_to_fetch_more_view
{
    [self willChangeValueForKey:@"pull_to_fetch_more_view"];
    objc_setAssociatedObject(self, &LL_Pull_To_Fetch_More_View_Key, pull_to_fetch_more_view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pull_to_fetch_more_view"];
}

- (LLPullToFetchMoreView *)pull_to_fetch_more_view
{
    return objc_getAssociatedObject(self, &LL_Pull_To_Fetch_More_View_Key);
}


- (PullToFetchMoreState)getFectMoreState
{
    return self.pull_to_fetch_more_view.pull_to_fetch_more_state;
}

- (BOOL)show_infinite_scrolling
{
    return !self.pull_to_fetch_more_view.hidden;
}

- (void)setShow_infinite_scrolling:(BOOL)show_infinite_scrolling
{
    
    
    self.pull_to_fetch_more_view.hidden = !show_infinite_scrolling;
    
    
    if (!show_infinite_scrolling)
    {
        self.tableFooterView = nil;
        if (self.pull_to_fetch_more_view.is_observing) {
            [self removeObserver:self.pull_to_fetch_more_view forKeyPath:@"contentOffset"];
            self.pull_to_fetch_more_view.is_observing = NO;
        }
    } else {
        self.tableFooterView = self.pull_to_fetch_more_view;
        if (!self.pull_to_fetch_more_view.is_observing) {
            [self addObserver:self.pull_to_fetch_more_view forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            self.pull_to_fetch_more_view.is_observing = YES;
            
        }
    }
}

- (void)setPullToFetchMoreEndBlock:(PullFetchMoreEndBlock)fetch_more_end_block
{
    if (nil == self.pull_to_fetch_more_view)
    {
        //        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), PullToFetctMoreViewHeight)];
        
        self.pull_to_fetch_more_view                      = [[LLPullToFetchMoreView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 45.0f)];
        self.pull_to_fetch_more_view.fetch_more_end_block = fetch_more_end_block;
        self.pull_to_fetch_more_view.scroll_view          = self;
        
        self.tableFooterView         = self.pull_to_fetch_more_view;
        
        self.show_infinite_scrolling = YES;
    }
}


/*
 *void 开始下拉加载更多的动画
 *
 */
- (void)startPullToFetchMoreAnimating
{
    
    [self.pull_to_fetch_more_view setPullToFetchMoreState:PullToFetchMoreLoading];
}

/*
 *void 结束下拉加载更多的动画
 *
 */
- (void)stopPullToFetchMoreAnimating
{
    [self.pull_to_fetch_more_view setPullToFetchMoreState:PullToFetchMoreNormal];
}


/*
 *void 移除获取更多的观察者
 *
 */
- (void)removeFetchMoreObserver
{
    if (nil != self.pull_to_fetch_more_view)
    {
        if (self.pull_to_fetch_more_view.is_observing)
        {
            [self removeObserver:self.pull_to_fetch_more_view forKeyPath:@"contentOffset"];
            self.pull_to_fetch_more_view.is_observing = NO;
        }
    }
}


@end



