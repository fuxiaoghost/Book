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
    BOOL isMoving;              // 单手滑动翻页，是否正在移动
    BOOL isPinching;            // 双手捏合，是否正在移动
    CGPoint startTouch;         // 记录单手滑动初始位置
    CGPoint endTouch;
    CGPoint pinchTouch0;        // 记录捏合手势初始位置
    CGPoint pinchTouch1;
    NSInteger startPageIndex;
    float moveSensitivity;      // 翻一页所需要的滑动距离
    float pinchSensitivity;     // 捏合一页所需要的滑动距离
    float pinchSensitivity_;    // 展开一页所需要的滑动距离
    float zDistance;            // 每页之间的间距
    float scope;                //
    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UIView *gestureView;
}
@property (nonatomic,assign) NSInteger pageIndex;
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images;
@end
