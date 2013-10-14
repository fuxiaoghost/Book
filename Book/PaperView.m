//
//  PaperView.m
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "PaperView.h"
#import "PaperLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "CATransform3DPerspect.h"

#define VIEW_MIN_ANGLE (M_PI_4/6)       // 书页夹角/2
#define VIEW_MAX_ANGLE (M_PI_4)         // (展开书页夹角 - 书页夹角)/2
#define VIEW_Z_DISTANCE (-300)          // 沿z轴距离
#define VIEW_Z_MIN_DISTANCE 0           // 最小z轴距离
#define VIEW_Z_MAX_DISTANCE (-800)      // 最大z轴距离
#define VIEW_Z_PERSPECTIVE 1500         // z轴透视
#define VIEW_ALPHA 0.8                  // 阴影透明度
#define VIEW_PRELOAD_NUM 4              // 预加载图片数量

@interface PaperView()
@property (nonatomic,retain) NSMutableArray *photoArray;        // 图片容器
@property (nonatomic,retain) NSArray *imageArray;               // 图片地址
@property (nonatomic,assign) PaperStatus paperStatus;           // 书页的当前状态(PaperNormal,PaperUnfold,PaperFold)
@end

@implementation PaperView
@synthesize pageIndex = _pageIndex;
@synthesize photoArray;
@synthesize imageArray;
@synthesize paperStatus;

- (void) dealloc{
    self.photoArray = nil;
    self.imageArray = nil;
    [super dealloc];
}

// 准备变化所需要数据
- (void) initData{
    // 预先计算数据
    zDistance = sinf(VIEW_MIN_ANGLE) * self.frame.size.width;
    moveSensitivity = sinf(VIEW_MAX_ANGLE + VIEW_MIN_ANGLE) * self.frame.size.width;
    moveSensitivity = VIEW_Z_PERSPECTIVE * moveSensitivity/(VIEW_Z_PERSPECTIVE - VIEW_Z_DISTANCE);
    pinchSensitivity = moveSensitivity;
    pinchSensitivity_ = self.frame.size.width - pinchSensitivity/2;
    
    moveSensitivity = 200;
}

- (id)initWithFrame:(CGRect)frame images:(NSArray *)images{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageArray = images;
        self.photoArray = [NSMutableArray arrayWithCapacity:0];
        self.paperStatus = PaperNormal;
        
        // 准备变化所需要数据
        [self initData];
        
        for (int i = self.imageArray.count - 1; i >= 0; i--) {
            // rightlayer
            PaperLayer *rightLayer = [[PaperLayer alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height) paperType:PaperLayerRight];
            rightLayer.layer.anchorPoint = CGPointMake(0, 0.5);
            rightLayer.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
            [self addSubview:rightLayer];
            rightLayer.layer.doubleSided = NO;
            
            if (i == self.imageArray.count - 1) {
                rightLayer.layer.doubleSided = YES;
            }
            [self.photoArray insertObject:rightLayer atIndex:0];
            [rightLayer release];
    
            // leftlayer
            PaperLayer *leftLayer = [[PaperLayer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height) paperType:PaperLayerLeft];
            
            leftLayer.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
            if (i == self.imageArray.count - 1 || i == 0) {
                leftLayer.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
            }else{
                leftLayer.frame = CGRectMake(0, 0, frame.size.width/2 + 0.5, frame.size.height);
            }
            [self addSubview:leftLayer];
            
            leftLayer.layer.doubleSided = NO;
            
            if (i == 0) {
                leftLayer.layer.doubleSided = YES;
            }
            
            [self.photoArray insertObject:leftLayer atIndex:0];
            [leftLayer release];
        }
        
        int startIndex = self.pageIndex - VIEW_PRELOAD_NUM/2;
        if (startIndex < 0) {
            startIndex = -startIndex;
        }
        

        dispatch_async(dispatch_get_main_queue(), ^{
            for(int i = 0; i < self.photoArray.count; i+=2){
                NSInteger index = i/2;
                PaperLayer *leftLayer = (PaperLayer *)[self.photoArray objectAtIndex:i];
                PaperLayer *rightLayer =  (PaperLayer *)[self.photoArray objectAtIndex:i + 1];
                [rightLayer setImage:[UIImage imageWithContentsOfFile:[self.imageArray objectAtIndex:index]]];
                [leftLayer setImage:[UIImage imageWithContentsOfFile:[self.imageArray objectAtIndex:index]]];
            }
        });

        
       

        [self resetViews];
        
        // 滑动翻页手势
        panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)]autorelease];
        [self addGestureRecognizer:panGesture];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        
    
        // 双指捏合手势
        pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureReceive:)] autorelease];
        [self addGestureRecognizer:pinchGesture];
        [pinchGesture requireGestureRecognizerToFail:panGesture];
        
        // 点击手势
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureReceive:)] autorelease];
        [self addGestureRecognizer:tapGesture];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
    }
    return self;
}

- (void) setPageIndex:(NSInteger)pageIndex{
    _pageIndex = pageIndex;
    
    [self resetViewsAnimated:CGPointZero time:0.3];
}

- (void) setFrame:(CGRect)frame{
    if (frame.size.width == self.frame.size.width && frame.size.height == self.frame.size.height) {
        [super setFrame:frame];
        return;
    }
    [super setFrame:frame];
    
    // 预先计算数据
    [self initData];
    
    for (int i = 0; i < self.photoArray.count; i += 2){
        PaperLayer *leftcell = [self.photoArray objectAtIndex:i];
        PaperLayer *rightcell = [self.photoArray objectAtIndex:i + 1];
       
        rightcell.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height);
        
        if (i == self.photoArray.count - 2 || i == 0) {
            leftcell.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
        }else{
            leftcell.frame = CGRectMake(0, 0, self.frame.size.width/2 + 0.5, self.frame.size.height);
        }
    }
    
    [self resetViews];
}


#pragma mark -
#pragma mark Reset & ResetAnimated
- (void) resetViews{
    self.paperStatus = PaperNormal;
    
    for (int i = 0; i < self.photoArray.count; i+=2) {
        CALayer *leftLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i]).layer;
        CALayer *rightLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i+1]).layer;
    
        
        NSInteger index = i/2;
        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_MIN_ANGLE, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        if (index <= self.pageIndex) {
            lCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            lCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        if (index <= self.pageIndex) {
            lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        lTransform3D_2 = CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //=====================
        
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_MIN_ANGLE, 0, 1, 0);
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        if (index < self.pageIndex) {
            rCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            rCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        if (index < self.pageIndex) {
            rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
    
        
        PaperLayer *leftcell = ((PaperLayer *)[self.photoArray objectAtIndex:i]);
        PaperLayer *rightcell = ((PaperLayer *)[self.photoArray objectAtIndex:i+1]);
        
        if (index == self.pageIndex) {
            rightcell.markView.alpha = 0;
            leftcell.markView.alpha = 0;
        }
    }
}


- (void) resetViewsAnimated:(CGPoint)touchPoint time:(NSTimeInterval)time{
    [UIView animateWithDuration:time animations:^{
        [self resetViews];
    }];
}


#pragma mark -
#pragma mark Unfold & Fold & UnfoldAnimated & FoldAnimated
- (void) foldAnimated{
    if (self.paperStatus == PaperNormal) {
        if (ABS(pinchSensitivity * 3/4) < ABS(scope)) {
            [UIView animateWithDuration:0.4 animations:^{
                [self fold];
            }];
        }else{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                [self pinchChange:-pinchSensitivity * 3/4];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                    [self pinchChange:-pinchSensitivity * 2/4];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                        [self pinchChange:-pinchSensitivity * 3/4];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3 animations:^{
                            [self fold];
                        }];
                    }];
                }];
            }];
        }
        
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            [self fold];
        }];
    }
    self.paperStatus = PaperFold;
}

- (void) unfoldAnimated{
    self.paperStatus = PaperUnfold;
    [UIView animateWithDuration:0.4 animations:^{
        [self unfold];
    }];
}

- (void) fold{
    self.paperStatus = PaperFold;
    for (int i = 0; i < self.photoArray.count; i+=2) {
        CALayer *leftLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i]).layer;
        CALayer *rightLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i + 1]).layer;

        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        lTransform3D_2 = CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_MAX_DISTANCE);
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //=====================
        
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(0, 0, 1, 0);
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_MAX_DISTANCE);
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
    }
}

- (void) unfold{
    self.paperStatus = PaperUnfold;
    for (int i = 0; i < self.photoArray.count; i+=2) {
        CALayer *leftLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i]).layer;
        CALayer *rightLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i + 1]).layer;

        
        NSInteger index = i/2;
        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_MIN_ANGLE, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        if (index <= self.pageIndex) {
            lCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            lCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        if (index <= self.pageIndex) {
            lCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
        }else{
            lCurrentAngle = -VIEW_MIN_ANGLE;
        }
        lTransform3D_2 = CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_MIN_DISTANCE);
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //=====================
        
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_MIN_ANGLE, 0, 1, 0);
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        if (index < self.pageIndex) {
            rCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            rCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        if (index < self.pageIndex) {
            rCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
        }else{
            rCurrentAngle = -VIEW_MIN_ANGLE;
        }
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_MIN_DISTANCE);
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
    }
}


#pragma mark -
#pragma mark PinchChange
// 捏合运动
- (void) pinchChange:(float)move{
    // move<0 捏合；move>0 展开
    
    // 调整每一页的变换
    for (int i = 0; i < self.photoArray.count; i+=2) {
        CALayer *leftLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i]).layer;
        CALayer *rightLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i + 1]).layer;
        
        
        NSInteger index = i/2;
        float move_ = ABS(move);
        
        //==========================leftlayer=============================
        // lTrans_0
        CATransform3D lTransform3D_0;
        float theta = 0; 
        if (move < 0) {
            //捏合
            if (self.paperStatus == PaperNormal) {
                if (move_ < pinchSensitivity) {
                    theta = VIEW_MIN_ANGLE * (1 - move_/pinchSensitivity);
                }else{
                    theta = 0;
                }
            }else if(self.paperStatus == PaperUnfold){
                if (move_ < pinchSensitivity_) {
                    theta = VIEW_MIN_ANGLE;
                }else{
                    theta = VIEW_MIN_ANGLE * (1 - (move_ - pinchSensitivity_)/pinchSensitivity);
                }
                if (theta < 0) {
                    theta = 0;
                }
            }else if(self.paperStatus == PaperFold){
                theta = 0;
            }
        }else{
            // 展开
            if (self.paperStatus == PaperNormal) {
                theta = VIEW_MIN_ANGLE;
            }else if(self.paperStatus == PaperUnfold){
                theta = VIEW_MIN_ANGLE;
            }else if(self.paperStatus == PaperFold){
                theta = VIEW_MIN_ANGLE * move/pinchSensitivity;
                if (theta > VIEW_MIN_ANGLE) {
                    theta = VIEW_MIN_ANGLE;
                }
            }
        }
        lTransform3D_0 = CATransform3DMakeRotation(M_PI - theta, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        lCurrentDistance = (self.pageIndex - index) * sinf(theta) * self.frame.size.width;
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
 
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        if (index <= self.pageIndex) {
            if (move < 0) {
                // 捏合
                if (self.paperStatus == PaperNormal) {
                    lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE + (M_PI_2 + VIEW_MAX_ANGLE) * move_/pinchSensitivity;
                    
                    if (lCurrentAngle > 0) {
                        lCurrentAngle = 0;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    lCurrentAngle = (-M_PI + VIEW_MIN_ANGLE) + (M_PI_2 - VIEW_MIN_ANGLE) * move_/ (pinchSensitivity + pinchSensitivity_);
                    if (lCurrentAngle > -M_PI_2) {
                        lCurrentAngle = -M_PI_2;
                    }
                }else if(self.paperStatus == PaperFold){
                    lCurrentAngle = 0;
                }
                
            }else{
                // 展开
                if (self.paperStatus == PaperNormal) {
                    lCurrentAngle = -M_PI_2 -VIEW_MAX_ANGLE - (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move_/pinchSensitivity_;
                    if(lCurrentAngle < -M_PI + VIEW_MIN_ANGLE){
                        lCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    lCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                }else if(self.paperStatus == PaperFold){
                    lCurrentAngle = (-M_PI + VIEW_MIN_ANGLE) * move_/ (pinchSensitivity + pinchSensitivity_);
                    if (lCurrentAngle < -M_PI + VIEW_MIN_ANGLE) {
                        lCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                    }
                }
            }
            
        }else{
            if (move < 0) {
                // 捏合
                if (self.paperStatus == PaperNormal) {
                    lCurrentAngle =  -M_PI_2 + VIEW_MAX_ANGLE - (VIEW_MAX_ANGLE - M_PI_2) * move_/pinchSensitivity;
                    if (lCurrentAngle > 0) {
                        lCurrentAngle = 0;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    lCurrentAngle = -VIEW_MIN_ANGLE + (VIEW_MIN_ANGLE - M_PI_2) * move_/(pinchSensitivity_ + pinchSensitivity);
                 
                    if (lCurrentAngle <  -M_PI_2) {
                        lCurrentAngle =  -M_PI_2;
                    }
                }else if(self.paperStatus == PaperFold){
                    lCurrentAngle = 0;
                }
                
            }else{
                // 展开
                if (self.paperStatus == PaperNormal) {
                    lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE + (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move_/pinchSensitivity_;
                    if (lCurrentAngle > - VIEW_MIN_ANGLE) {
                        lCurrentAngle = - VIEW_MIN_ANGLE;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    lCurrentAngle = - VIEW_MIN_ANGLE;
                }else if(self.paperStatus == PaperFold){
                    
                    lCurrentAngle =  -VIEW_MIN_ANGLE * move_/(pinchSensitivity + pinchSensitivity_);
                   
                    if (lCurrentAngle < - VIEW_MIN_ANGLE) {
                        lCurrentAngle = - VIEW_MIN_ANGLE;
                    }
                }
                
            }
        }
       
        lTransform3D_2= CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        // lTrans_3
        CATransform3D lTransform3D_3;
        float lCurrentZDistance = 0;
        if (move < 0) {
            // 捏合
            if (self.paperStatus == PaperNormal) {
                lCurrentZDistance = VIEW_Z_DISTANCE + (VIEW_Z_MAX_DISTANCE - VIEW_Z_DISTANCE) * move_/pinchSensitivity;
                if (lCurrentZDistance < VIEW_Z_MAX_DISTANCE) {
                    lCurrentZDistance = VIEW_Z_MAX_DISTANCE;
                }
            }else if(self.paperStatus == PaperUnfold){
                lCurrentZDistance = VIEW_Z_MIN_DISTANCE + (VIEW_Z_MAX_DISTANCE - VIEW_Z_MIN_DISTANCE) * move_/(pinchSensitivity + pinchSensitivity_);
                if (lCurrentZDistance < VIEW_Z_MAX_DISTANCE) {
                    lCurrentZDistance = VIEW_Z_MAX_DISTANCE;
                }
            }else if(self.paperStatus == PaperFold){
                lCurrentZDistance = VIEW_Z_MAX_DISTANCE;
            }
            
        }else{
            // 展开
            if(self.paperStatus == PaperNormal){
                lCurrentZDistance = VIEW_Z_DISTANCE + (VIEW_Z_MIN_DISTANCE - VIEW_Z_DISTANCE) * move_/pinchSensitivity_;
                if (lCurrentZDistance > 0) {
                    lCurrentZDistance = 0;
                }
            }else if(self.paperStatus == PaperUnfold){
                lCurrentZDistance = 0;
            }else if(self.paperStatus == PaperFold){
                lCurrentZDistance = VIEW_Z_MAX_DISTANCE + (ABS(VIEW_Z_MAX_DISTANCE) - ABS(VIEW_Z_MIN_DISTANCE)) *move_/(pinchSensitivity + pinchSensitivity_);
                if (lCurrentZDistance > 0) {
                    lCurrentZDistance = 0;
                }
            }
        }
        
        lTransform3D_3 = CATransform3DMakeTranslation(0, 0, lCurrentZDistance);
        
        // lTrans
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        
        //==========================rightlayer========================
        // rTrans_0
        CATransform3D rTransform3D_0;

        rTransform3D_0 = CATransform3DMakeRotation(theta, 0, 1, 0);
        
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        rCurrentDistance = (self.pageIndex - index) * sinf(theta) * self.frame.size.width;
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        if (index < self.pageIndex) {            
            if (move < 0) {
                // 捏合
                if (self.paperStatus == PaperNormal) {
                    rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE + (M_PI_2 + VIEW_MAX_ANGLE) * move_/pinchSensitivity;
                    
                    if (rCurrentAngle > 0) {
                        rCurrentAngle = 0;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    rCurrentAngle = (-M_PI + VIEW_MIN_ANGLE) + (M_PI_2 - VIEW_MIN_ANGLE) * move_/ (pinchSensitivity + pinchSensitivity_);
                    if (rCurrentAngle >  -M_PI_2) {
                        rCurrentAngle =  -M_PI_2;
                    }
                }else if(self.paperStatus == PaperFold){
                    rCurrentAngle = 0;
                }
                
            }else{
                // 展开
                if (self.paperStatus == PaperNormal) {
                    rCurrentAngle = -M_PI_2 -VIEW_MAX_ANGLE - (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move_/pinchSensitivity_;
                    if(rCurrentAngle < -M_PI + VIEW_MIN_ANGLE){
                        rCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    rCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                }else if(self.paperStatus == PaperFold){
                    rCurrentAngle = (-M_PI + VIEW_MIN_ANGLE) * move_/ (pinchSensitivity + pinchSensitivity_);
                    if (rCurrentAngle < -M_PI + VIEW_MIN_ANGLE) {
                        rCurrentAngle = -M_PI + VIEW_MIN_ANGLE;
                    }
                }
            }
        }else{
            if (move < 0) {
                // 捏合
                if (self.paperStatus == PaperNormal) {
                    rCurrentAngle =  -M_PI_2 + VIEW_MAX_ANGLE - (VIEW_MAX_ANGLE - M_PI_2) * move_/pinchSensitivity;
                    if (rCurrentAngle > 0) {
                        rCurrentAngle = 0;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    rCurrentAngle = -VIEW_MIN_ANGLE + (VIEW_MIN_ANGLE - M_PI_2) * move_/(pinchSensitivity_ + pinchSensitivity);
                    
                    if (rCurrentAngle < -M_PI_2) {
                        rCurrentAngle = -M_PI_2;
                    }
                }else if(self.paperStatus == PaperFold){
                    rCurrentAngle = 0;
                }
                
            }else{
                // 展开
                if (self.paperStatus == PaperNormal) {
                    rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE + (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move_/pinchSensitivity_;
                    if (rCurrentAngle > - VIEW_MIN_ANGLE) {
                        rCurrentAngle = - VIEW_MIN_ANGLE;
                    }
                }else if(self.paperStatus == PaperUnfold){
                    rCurrentAngle = - VIEW_MIN_ANGLE;
                }else if(self.paperStatus == PaperFold){
                    rCurrentAngle = -VIEW_MIN_ANGLE * move_/(pinchSensitivity + pinchSensitivity_);
                    
                    if (rCurrentAngle < - VIEW_MIN_ANGLE) {
                        rCurrentAngle = - VIEW_MIN_ANGLE;
                    }
                }
                
            }
        }
     
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        
        // rTrans_3
        CATransform3D rTransform3D_3;
        float rCurrentZDistance = lCurrentZDistance;
        
        rTransform3D_3 = CATransform3DMakeTranslation(0, 0, rCurrentZDistance);
        
        // rTrans
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
    }
}

#pragma mark -
#pragma mark MoveChange

// 单手滑动
- (void) moveChange:(float)move{
    
    NSInteger currentIndex = startPageIndex + (int)(move/moveSensitivity);
    if (currentIndex < 0 || currentIndex >= self.imageArray.count) {
        return;
    }
    
    // 当前页面的值
    self.pageIndex = currentIndex;
    
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
    NSInteger nextPageIndex = move > 0 ? (self.pageIndex + 1):(self.pageIndex - 1);
    
    // 纠偏参数
    float x = 0,z = 0,x_ = 0,z_ = 0;
    float theta = 2 * VIEW_MAX_ANGLE - 2 *VIEW_MAX_ANGLE * pageRemainder/moveSensitivity; 
    float alpha = 2 * VIEW_MAX_ANGLE * pageRemainder/moveSensitivity;
    
    float d = zDistance * pageRemainder/moveSensitivity;
    x = sinf(theta) * d;
    z = cosf(theta) * d;
    x_ = sinf(alpha) * (zDistance - d);
    z_ = cosf(alpha) * (zDistance - d);
    

    // 调整每一页的变换
    for (int i = 0; i < self.photoArray.count; i+=2) {
        CALayer *leftLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i]).layer;
        CALayer *rightLayer = ((PaperLayer *)[self.photoArray objectAtIndex:i + 1]).layer;
        
        NSInteger index = i/2;
        
        //==========================leftlayer=============================
        // lTrans_0
        CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_MIN_ANGLE, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lNextDistance = 0;
        float lCurrentDistance = 0;
        if (index <= self.pageIndex) {
            lCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            lCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        if (index <= nextPageIndex) {
            lNextDistance = (nextPageIndex - index) * zDistance;
        }else{
            lNextDistance = -(index - nextPageIndex) * zDistance;
        }
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lNextAngle = 0;
        float lCurrentAngle = 0;
        if (index <= self.pageIndex) {
            lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        if (index <= nextPageIndex) {
            lNextAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            lNextAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }

        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance + (lNextDistance - lCurrentDistance) * pageRemainder/moveSensitivity);
        lTransform3D_2= CATransform3DMakeRotation(lCurrentAngle + (lNextAngle - lCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        
        // 变换纠偏
        if (lNextAngle == lCurrentAngle) {
            if (move > 0) {
                if (index <= self.pageIndex) {
                    lTransform3D_1 = CATransform3DMakeTranslation(x , 0, z + (self.pageIndex - index) * zDistance);
                }else if(index > self.pageIndex+1){
                    lTransform3D_1 = CATransform3DMakeTranslation(x_ , 0, -z_ - (index - self.pageIndex - 1) * zDistance);
                }
            }else if(move < 0){
                if (index < self.pageIndex) {
                    lTransform3D_1 = CATransform3DMakeTranslation(x_ , 0, z_ + (self.pageIndex - index - 1) * zDistance);
                }else if(index > self.pageIndex){
                    lTransform3D_1 = CATransform3DMakeTranslation(x , 0, -z - (index - self.pageIndex) * zDistance);
                }
            }
        }
        
        // lTrans_3
        CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        
        // lTrans
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        //==========================rightlayer========================
        // rTrans_0
        CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_MIN_ANGLE, 0, 1, 0);
        
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rNextDistance = 0;
        float rCurrentDistance = 0;
        if (index < self.pageIndex) {
            rCurrentDistance = (self.pageIndex - index) * zDistance;
        }else{
            rCurrentDistance = -(index - self.pageIndex) * zDistance;
        }
        if (index < nextPageIndex) {
            rNextDistance = (nextPageIndex - index) * zDistance;
        }else{
            rNextDistance = -(index - nextPageIndex) * zDistance;
        }
        
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rNextAngle = 0;
        float rCurrentAngle = 0;
        if (index < self.pageIndex) {
            rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }
        if (index < nextPageIndex) {
            rNextAngle = -M_PI_2 - VIEW_MAX_ANGLE;
        }else{
            rNextAngle = -M_PI_2 + VIEW_MAX_ANGLE;
        }

        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance + (rNextDistance - rCurrentDistance) * pageRemainder/moveSensitivity);
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle + (rNextAngle - rCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        
        // 变换纠偏
        if (rNextAngle == rCurrentAngle) {
            if (move > 0) {
                if (index < self.pageIndex) {
                    rTransform3D_1 = CATransform3DMakeTranslation(x, 0, z + (self.pageIndex - index) *zDistance);
                }else if(index > self.pageIndex ){
                    rTransform3D_1 = CATransform3DMakeTranslation(x_, 0, -z_ - (index - self.pageIndex - 1) *zDistance);
                }
                
            }else if(move < 0 ){
                if (index < self.pageIndex - 1) {
                    rTransform3D_1 = CATransform3DMakeTranslation(x_, 0, z_ + (self.pageIndex - index - 1) * zDistance);
                }else if(index >= self.pageIndex){
                    rTransform3D_1 = CATransform3DMakeTranslation(x, 0, -z - (index - self.pageIndex) *zDistance);
                }
            }
        }        
        
        // rTrans_3
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        
        // rTrans
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);

        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        

        // 图层阴影
        PaperLayer *leftcell = ((PaperLayer *)[self.photoArray objectAtIndex:i]);
        PaperLayer *rightcell = ((PaperLayer *)[self.photoArray objectAtIndex:i + 1]);
        if (move > 0) {
            if (index == self.pageIndex) {
                rightcell.markView.alpha = VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
            if (index == self.pageIndex + 1) {
                leftcell.markView.alpha = VIEW_ALPHA - VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
        }else if(move < 0){
            if (index == self.pageIndex) {
                leftcell.markView.alpha = VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
            if (index == self.pageIndex - 1) {
                rightcell.markView.alpha = VIEW_ALPHA - VIEW_ALPHA * pageRemainder/moveSensitivity;
            }
        }
    }
}


#pragma mark -
#pragma mark PanMove & PinchMove
- (float) touchLengthMoveTo:(CGPoint)touchPoint{
    return -touchPoint.x + startTouch.x;
}

- (float) pinchLengthMoveTo:(CGPoint)touchPoint0 anotherPoint:(CGPoint)touchPoint1{
    float x0 = ABS(pinchTouch0.x - pinchTouch1.x);
    float x1 =  ABS(touchPoint0.x - touchPoint1.x);
    return x1 - x0;
}


#pragma mark -
#pragma mark GestureReceive
// 点击
- (void) tapGestureReceive:(UITapGestureRecognizer *)recoginzer{
    if (self.paperStatus == PaperUnfold || self.paperStatus == PaperFold) {
   
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
            [self pinchChange:pinchSensitivity/4];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                [self pinchChange:pinchSensitivity/2];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                    [self pinchChange:pinchSensitivity* 3/4];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                        [self resetViews];
                    } completion:^(BOOL finished) {

                    }];
                }];
            }];
        }];
    }else if(self.paperStatus == PaperNormal){
        [self unfoldAnimated];
    }
}

- (void) preloadImages{
    float move = [self touchLengthMoveTo:endTouch];
    float pageRemainder = 0;
    if (move > 0) {
        pageRemainder = move - moveSensitivity * ((int)(move/moveSensitivity));
    }else if(move < 0){
        pageRemainder = (-move) + moveSensitivity * ((int)(move/moveSensitivity));
    }
    if (pageRemainder > moveSensitivity/2) {
        if (move > 0) {
            if (self.pageIndex + 1 < self.imageArray.count) {
                self.pageIndex++;
            }
        }else{
            if (self.pageIndex - 1 >= 0 ) {
                self.pageIndex--;
            }
        }
    }
}

// 滑动
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer{
    if (isPinching || self.paperStatus == PaperFold) {
        return;
    }
    // begin paning 显示last screenshot
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        if (self.paperStatus == PaperUnfold) {
            [self resetViewsAnimated:CGPointZero time:0.4];
            return;
        }
        endTouch = [recoginzer locationOfTouch:0 inView:self];
        startTouch = endTouch;
        startPageIndex = self.pageIndex;
        isMoving = YES;
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        [self preloadImages];
        [self resetViewsAnimated:endTouch time:0.3];
        isMoving = NO;
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [self preloadImages];
        [self resetViewsAnimated:endTouch time:0.3];
        isMoving = NO;
        return;
    }else if(recoginzer.state == UIGestureRecognizerStateChanged){
        endTouch = [recoginzer locationOfTouch:0 inView:self];
        if (isMoving) {
            float move = [self touchLengthMoveTo:endTouch];
            [self moveChange:move];
        }
    }
   
}

// 捏合
- (void) pinchGestureReceive:(UIPinchGestureRecognizer *)recoginzer{
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        // 限制为双指操作
        if ([recoginzer numberOfTouches] <= 1) {
            return;
        }
        panGesture.enabled = NO;
        
        isPinching = YES;
        pinchTouch0 = [recoginzer locationOfTouch:0 inView:self];
        pinchTouch1 = [recoginzer locationOfTouch:1 inView:self];
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        isPinching = NO;
    
        if (self.paperStatus == PaperNormal) {
            if (scope < -100) {
                // 捏合
                [self foldAnimated];
            }else if(scope > 100){
                // 展开
                [self unfoldAnimated];
            }else{
                [self resetViewsAnimated:CGPointMake(0, 0) time:0.3];
                // 还原
            }
        }else if(self.paperStatus == PaperUnfold){
            if (scope < - 100) {
                // 还原
                [self resetViewsAnimated:CGPointMake(0, 0) time:0.3];
            }else{
                // 展开
                [self unfoldAnimated];
            }
        }else if(self.paperStatus == PaperFold){
            if (scope > 100 && scope < pinchSensitivity) {
                // 还原
                [self resetViewsAnimated:CGPointMake(0, 0) time:0.6];
            }else if(scope > pinchSensitivity){
                // 展开
                [self unfoldAnimated];
            }else{
                // 捏合
                [self foldAnimated];
            }
        }
        [panGesture performSelector:@selector(setEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        isPinching = NO;
        [self resetViewsAnimated:startTouch time:0.3];
        panGesture.enabled = YES;
        return;
    }else if(recoginzer.state == UIGestureRecognizerStateChanged){
        // 限制为双指操作
        if ([recoginzer numberOfTouches] <= 1) {
            return;
        }
        if (isPinching) {
            scope = 0;
            CGPoint touch0 = [recoginzer locationOfTouch:0 inView:self];
            CGPoint touch1 = [recoginzer locationOfTouch:1 inView:self];
            
            scope = [self pinchLengthMoveTo:touch0 anotherPoint:touch1];

            [self pinchChange:scope];
        }
    }
}
@end
