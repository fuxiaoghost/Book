//
//  PaperView.m
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "PaperView.h"
#import "PaperCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "CATransform3DPerspect.h"

// 判断当前ViewController的方向
#define INTERFACE_UNKNOWN               ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationUnknown)
#define INTERFACE_PORTRAIT              ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortrait)
#define INTERFACE_PORTRAITUPSIDEDOWN    ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
#define INTERFACE_LANDSCAPELEFT         ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationLandscapeLeft)
#define INTERFACE_LANDSCAPERIGHT        ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationLandscapeRight)
#define INTERFACE_FACEUP                ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationFaceUp)
#define INTERFACE_FACEDOWN              ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationFaceDown)

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define VIEW_MIN_ANGLE (M_PI_4/6)
#define VIEW_MAX_ANGLE (M_PI_4)
#define VIEW_Z_DISTANCE -400                    // 沿z轴移动距离
#define VIEW_Z_PERSPECTIVE 1500                 // z轴透视
#define VIEW_ALPHA 0.6

@interface PaperView()
@property (nonatomic,retain) NSMutableArray *photoArray;        // 图片容器
@property (nonatomic,retain) NSArray *urlArray;                     // 图片地址
@end

@implementation PaperView
@synthesize pageIndex;
@synthesize photoArray;
@synthesize urlArray;

- (void) dealloc{
    self.photoArray = nil;
    self.urlArray = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame photoUrls:(NSArray *)urls{
    self = [super initWithFrame:frame];
    if (self) {
        self.urlArray = urls;
        self.photoArray = [NSMutableArray arrayWithCapacity:0];
        zDistance = sinf(VIEW_MIN_ANGLE) * self.frame.size.width;
        moveSensitivity = sinf(VIEW_MAX_ANGLE + VIEW_MIN_ANGLE) * frame.size.width + zDistance;
        moveSensitivity = VIEW_Z_PERSPECTIVE * moveSensitivity/(VIEW_Z_PERSPECTIVE - VIEW_Z_DISTANCE);

        for (int i = urls.count - 1; i >= 0; i--) {
            // rightcell
            PaperCell *rightCell = [[PaperCell alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height) orientation:PaperCellRight];
            rightCell.layer.anchorPoint = CGPointMake(0, 0.5);
            rightCell.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
            [self addSubview:rightCell];
            [rightCell release];
            [self.photoArray insertObject:rightCell atIndex:0];
            [rightCell.photoView setImageWithURL:[NSURL URLWithString:[urls objectAtIndex:i]] options:SDWebImageRetryFailed progress:NO];
           
            
            // leftcell
            PaperCell *leftcell = [[PaperCell alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height) orientation:PaperCellLeft];
            leftcell.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
            leftcell.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
            [self addSubview:leftcell];
            [leftcell release];
            [self.photoArray insertObject:leftcell atIndex:0];
            [leftcell.photoView setImageWithURL:[NSURL URLWithString:[urls objectAtIndex:i]] options:SDWebImageRetryFailed progress:NO];
        }

        [self resetViews];
        
        // 添加手势
        UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                     action:@selector(paningGestureReceive:)]autorelease];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void) resetViews{
    for (int i = 0; i < self.photoArray.count; i+=2) {
        PaperCell *leftcell = (PaperCell *)[self.photoArray objectAtIndex:i];
        PaperCell *rightcell = (PaperCell *)[self.photoArray objectAtIndex:i+1];
        
        leftcell.tipsLbl.text = [NSString stringWithFormat:@"%d",i];
        rightcell.tipsLbl.text = [NSString stringWithFormat:@"%d",i+1];
        leftcell.tipsLbl.hidden = YES;
        rightcell.tipsLbl.hidden = YES;
        
        NSInteger index = i/2;
        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_MIN_ANGLE, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        if (index <= pageIndex) {
            lCurrentDistance = (pageIndex - index) * zDistance;
        }else{
            lCurrentDistance = -(index - pageIndex) * zDistance;
        }
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        if (index <= pageIndex) {
            lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        lTransform3D_2 = CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        leftcell.layer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //=====================
        
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_MIN_ANGLE, 0, 1, 0);
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        if (index < pageIndex) {
            rCurrentDistance = (pageIndex - index) * zDistance;
        }else{
            rCurrentDistance = -(index - pageIndex) * zDistance;
        }
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        if (index < pageIndex) {
            rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightcell.layer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        
        if (index == pageIndex) {
            rightcell.markView.alpha = 0;
            leftcell.markView.alpha = 0;
        }
    }
}

- (float) touchLengthMoveTo:(CGPoint)touchPoint{
    
    if (INTERFACE_PORTRAIT) {
        return -touchPoint.x + startTouch.x;
    }else if(INTERFACE_PORTRAITUPSIDEDOWN){
        return -startTouch.x + touchPoint.x;
    }else if(INTERFACE_LANDSCAPELEFT){
        return -touchPoint.y + startTouch.y;
    }else if(INTERFACE_LANDSCAPERIGHT){
        return -startTouch.y + touchPoint.y;
    }
    return 0;
}

- (void) moveChange:(float)move{
    NSInteger currentIndex = startPageIndex + (int)(move/moveSensitivity);
    if (currentIndex < 0 || currentIndex >= self.urlArray.count) {
        return;
    }
    
    // 当前页面的值
    pageIndex = currentIndex;
    
    float pageRemainder = 0;
    if (move > 0) {
        pageRemainder = move - moveSensitivity * ((int)(move/moveSensitivity));
        if (pageRemainder > moveSensitivity/2) {
            currentIndex++;
        }
    }else if(move < 0){
        pageRemainder = (-move) + moveSensitivity * ((int)(move/moveSensitivity));
        if (pageRemainder > moveSensitivity/2) {
            currentIndex--;
        }
    }
    
    // 下一页的预测值
    NSInteger nextPageIndex = move > 0 ? (pageIndex + 1):(pageIndex - 1);
    
    // 夹页间距
    for (int i = 0; i < self.photoArray.count; i+=2) {
        PaperCell *leftcell = (PaperCell *)[self.photoArray objectAtIndex:i];
        PaperCell *rightcell = (PaperCell *)[self.photoArray objectAtIndex:i+1];
        
        NSInteger index = i/2;
        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_MIN_ANGLE, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lNextDistance = 0;
        float lCurrentDistance = 0;
        if (index <= pageIndex) {
            lCurrentDistance = (pageIndex - index) * zDistance;
        }else{
            lCurrentDistance = -(index - pageIndex) * zDistance;
        }
        if (index <= nextPageIndex) {
            lNextDistance = (nextPageIndex - index) * zDistance;
        }else{
            lNextDistance = -(index - nextPageIndex) * zDistance;
        }
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance + (lNextDistance - lCurrentDistance) * pageRemainder/moveSensitivity);
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lNextAngle = 0;
        float lCurrentAngle = 0;
        if (index <= pageIndex) {
            lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        if (index <= nextPageIndex) {
            lNextAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lNextAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        
        lTransform3D_2 = CATransform3DMakeRotation(lCurrentAngle + (lNextAngle - lCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        leftcell.layer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //=====================
        
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_MIN_ANGLE, 0, 1, 0);
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rNextDistance = 0;
        float rCurrentDistance = 0;
        if (index < pageIndex) {
            rCurrentDistance = (pageIndex - index) * zDistance;
        }else{
            rCurrentDistance = -(index - pageIndex) * zDistance;
        }
        if (index < nextPageIndex) {
            rNextDistance = (nextPageIndex - index) * zDistance;
        }else{
            rNextDistance = -(index - nextPageIndex) * zDistance;
        }
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance + (rNextDistance - rCurrentDistance) * pageRemainder/moveSensitivity);
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rNextAngle = 0;
        float rCurrentAngle = 0;
        if (index < pageIndex) {
            rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        if (index < nextPageIndex) {
            rNextAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rNextAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle + (rNextAngle - rCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightcell.layer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        

        if (move > 0) {
            if (index == pageIndex) {
                rightcell.markView.alpha = VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
            if (index == pageIndex + 1) {
                leftcell.markView.alpha = VIEW_ALPHA - VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
        }else if(move < 0){
            if (index == pageIndex) {
                leftcell.markView.alpha = VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
            if (index == pageIndex - 1) {
                rightcell.markView.alpha = VIEW_ALPHA - VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
        }
    }

}

- (void) resetViewsAnimated:(CGPoint)touchPoint{
    float move = [self touchLengthMoveTo:touchPoint];
    float pageRemainder = 0;
    if (move > 0) {
        pageRemainder = move - moveSensitivity * ((int)(move/moveSensitivity));
    }else if(move < 0){
        pageRemainder = (-move) + moveSensitivity * ((int)(move/moveSensitivity));
    }
    if (pageRemainder > moveSensitivity/2) {
        if (move > 0) {
            if (pageIndex + 1 < self.urlArray.count) {
                pageIndex++;
            }
        }else{
            if (pageIndex - 1 >= 0 ) {
                pageIndex--;
            }
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self resetViews];
    }];
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer{
    
    // 基于window的点击坐标
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning 显示last screenshot
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        startPageIndex = pageIndex;
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        [self resetViewsAnimated:touchPoint];
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [self resetViewsAnimated:touchPoint];
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        float move = [self touchLengthMoveTo:touchPoint];
        [self moveChange:move];
    }
}
@end
