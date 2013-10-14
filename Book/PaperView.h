//
//  PaperView.h
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PaperNormal,
    PaperFold,
    PaperUnfold
}PaperStatus;

@interface PaperView : UIView{
@private
    BOOL isMoving;                          // 单手滑动翻页，是否正在移动
    BOOL isPinching;                        // 双手捏合，是否正在移动
    CGPoint startTouch;                     // 记录单手滑动初始位置
    CGPoint endTouch;                       // 记录单手滑动结束位置
    CGPoint pinchTouch0;                    // 记录捏合手势初始位置0
    CGPoint pinchTouch1;                    // 记录捏合手势初始位置1
    NSInteger startPageIndex;               // 滑动开始前当前页
    float moveSensitivity;                  // 翻一页所需要的滑动距离
    float pinchSensitivity;                 // 捏合一页所需要的滑动距离
    float pinchSensitivity_;                // 展开一页所需要的滑动距离
    float zDistance;                        // 每页之间的间距
    float scope;                            // 手指捏合、展开的尺度
    UIPanGestureRecognizer *panGesture;     // 手指滑动手势
    UIPinchGestureRecognizer *pinchGesture; // 手指捏合手势
}
@property (nonatomic,assign) NSInteger pageIndex;
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images;
@end
