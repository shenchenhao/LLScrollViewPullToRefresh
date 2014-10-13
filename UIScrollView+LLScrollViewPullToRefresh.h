//
//  UIScrollView+LLScrollViewPullToRefresh.h
//
//
//  Created by 沈 晨豪 on 14-3-13.
//
//


#import <UIKit/UIKit.h>


typedef void (^PullStartBlock)(void);
typedef void (^PullEndBlock)(BOOL can_refresh);

typedef NS_ENUM(NSInteger, PullToRefreshState)
{
    
	PullToRefreshNone = 0,     //没有状态
    
	PullToRefreshNormal,       //下拉刷新
    
    PullToRefreshPulling ,     //松开刷新
    
	PullToRefreshLoading,      //刷新中
    
};



@class LLPullToRefreshView;

@interface UIScrollView (LLScrollViewPullToRefresh)

@property (readonly, strong, nonatomic) LLPullToRefreshView *pull_to_refresh_view;
@property (nonatomic,copy)              NSString            *date_key;

- (PullToRefreshState)getRefreshState;

- (void)setPullStartBlock: (PullStartBlock) pull_start_block;

- (void)setPullEndBlock: (PullEndBlock) pull_end_block;

- (void)setShowPullToRefresh: (BOOL) show_pull_to_refresh;

- (void)removeRefreshObserver;

/*
 *void 开始动画
 *
 */
- (void)startPullToRefreshAnimation;

/*
 *void 结束动画
 *
 */
- (void)stopPullToRefreshAnimation;


/*
 *void 设置当前时间
 *
 *@param  date_key : 当前时间的key
 *
 */
- (void)setCurrentDate;

@end

#pragma mark -
#pragma mark - LLPullToRefreshView

@interface LLPullToRefreshView : UIView

@property (nonatomic,strong) UIColor *border_color;
@property (nonatomic,assign) CGSize   cycle_line_size;
@property (nonatomic,assign) CGFloat  border_width;


/*
 *void 设置下拉刷新
 *
 *@param pull_state :  下拉的状态
 *
 */
- (void)setPullToRefreshState: (PullToRefreshState) a_pull_state;

/*
 *void 显示最后刷新的时间
 *
 *@param date_key : 当前时间的key
 *
 */
- (void)showLastRefreshTime: (NSString *) date_key;


@end


#pragma mark -
#pragma mark - CycleLineLayer
@interface CycleLineView : UIView

@property (nonatomic, assign) UIColor      *track_color;
@property (nonatomic, assign) UIColor      *progress_color;
@property (nonatomic, assign) CGFloat       progress;       //0~1
@property (nonatomic, assign) CGFloat       progress_width;


/*
 *void 设置进度条
 *
 *@param progress : 进度条百分比
 *@param animated : 是否动画效果
 *
 */
- (void)setProgress: (CGFloat) progress  animated: (BOOL) animated;


/*
 *void 开始动画
 *
 */
- (void)startAnimation;

/*
 *void 停止动画
 *
 */
- (void)stopAnimation;
 
@end

