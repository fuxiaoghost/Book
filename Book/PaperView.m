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
#define VIEW_Z_DISTANCE (-400)                    // 沿z轴移动距离
#define VIEW_Z_MIN_DISTANCE 0
#define VIEW_Z_MAX_DISTANCE (-800)
#define VIEW_Z_PERSPECTIVE 1500                 // z轴透视
#define VIEW_ALPHA 0.6

@interface PaperView()
@property (nonatomic,retain) NSMutableArray *photoArray;        // 图片容器
@property (nonatomic,retain) NSArray *urlArray;                     // 图片地址
@property (nonatomic,retain) NSMutableArray *layerArray;
@end

@implementation PaperView
@synthesize pageIndex;
@synthesize photoArray;
@synthesize layerArray;
@synthesize urlArray;

- (void) dealloc{
    self.photoArray = nil;
    self.urlArray = nil;
    self.layerArray = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame photoUrls:(NSArray *)urls coverImage:(UIImage *)coverImage backImage:(UIImage *)backImage{
    self = [super initWithFrame:frame];
    if (self) {
        self.urlArray = urls;
        self.photoArray = [NSMutableArray arrayWithCapacity:0];
        self.layerArray = [NSMutableArray arrayWithCapacity:0];
        
        // 预先计算数据
        zDistance = sinf(VIEW_MIN_ANGLE) * self.frame.size.width;
        moveSensitivity = sinf(VIEW_MAX_ANGLE + VIEW_MIN_ANGLE) * frame.size.width;
        moveSensitivity = VIEW_Z_PERSPECTIVE * moveSensitivity/(VIEW_Z_PERSPECTIVE - VIEW_Z_DISTANCE);
        pinchSensitivity = moveSensitivity;
        pinchSensitivity_ = frame.size.width - pinchSensitivity;
        
        for (int i = urls.count - 1; i >= 0; i--) {
            // rightcell
            PaperCell *rightCell = [[PaperCell alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height) orientation:PaperCellRight];
            rightCell.layer.anchorPoint = CGPointMake(0, 0.5);
            rightCell.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
            if (i == urls.count - 1) {
                // backImage
                CATransformLayer *backLayer = [[CATransformLayer alloc] init];
                backLayer.anchorPoint = CGPointMake(0, 0.5);
                backLayer.frame =  CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
                rightCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                rightCell.layer.frame = backLayer.bounds;
                [backLayer addSublayer:rightCell.layer];			//底层
                
                CALayer *backImageLayer = [[CALayer alloc] init];
                backImageLayer.frame = backLayer.bounds;
                backImageLayer.contents = (id) [backImage CGImage];
                backImageLayer.contentsGravity = kCAGravityResize;
                backImageLayer.doubleSided = NO;
                backImageLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
                
                [backLayer addSublayer:backImageLayer];		//上层
                [backImageLayer release];
                
                [self.layer addSublayer:backLayer];
                [backLayer release];
                
                [self.layerArray insertObject:backLayer atIndex:0];
            }else{
                [self.layer addSublayer:rightCell.layer];
                [self.layerArray insertObject:rightCell.layer atIndex:0];
            }
            
            [self.photoArray insertObject:rightCell atIndex:0];
            [rightCell.photoView setImageWithURL:[NSURL URLWithString:[urls objectAtIndex:i]] options:SDWebImageRetryFailed progress:NO];
            [rightCell release];
            
            // leftcell
            PaperCell *leftcell = [[PaperCell alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height) orientation:PaperCellLeft];
            leftcell.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
            leftcell.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
            if (i == 0) {
                // backImage
                CATransformLayer *coverLayer = [[CATransformLayer alloc] init];
                coverLayer.anchorPoint = CGPointMake(1.0f, 0.5f);
                coverLayer.frame = leftcell.layer.frame;
                leftcell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                leftcell.layer.frame = coverLayer.bounds;
                [coverLayer addSublayer:leftcell.layer];			//底层
                
                CALayer *coverImageLayer = [[CALayer alloc] init];
                coverImageLayer.frame = coverLayer.bounds;
                coverImageLayer.contents = (id) [coverImage CGImage];
                coverImageLayer.doubleSided = NO;
                coverImageLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
                
                [coverLayer addSublayer:coverImageLayer];		//上层
                [coverImageLayer release];
                
                [self.layer addSublayer:coverLayer];
                [coverLayer release];
                
                [self.layerArray insertObject:coverLayer atIndex:0];
            }else{
                [self.layer addSublayer:leftcell.layer];
                [self.layerArray insertObject:leftcell.layer atIndex:0];
            }
            
            [self.photoArray insertObject:leftcell atIndex:0];
            [leftcell.photoView setImageWithURL:[NSURL URLWithString:[urls objectAtIndex:i]] options:SDWebImageRetryFailed progress:NO];
            [leftcell release];
        }

        [self resetViews];

        UIView *gestureView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:gestureView];
        [gestureView release];
        
        // 滑动翻页手势
        UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)]autorelease];
        [gestureView addGestureRecognizer:panGesture];
    
        // 双指捏合手势
        UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureReceive:)] autorelease];
        [gestureView addGestureRecognizer:pinchGesture];
    }
    return self;
}


- (void) resetViews{
    for (int i = 0; i < self.photoArray.count; i+=2) {
        PaperCell *leftcell = (PaperCell *)[self.photoArray objectAtIndex:i];
        PaperCell *rightcell = (PaperCell *)[self.photoArray objectAtIndex:i+1];
        
        CALayer *leftLayer = (CALayer *)[self.layerArray objectAtIndex:i];
        CALayer *rightLayer = (CALayer *)[self.layerArray objectAtIndex:i + 1];
        
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
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
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
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        
        if (index == pageIndex) {
            rightcell.markView.alpha = 0;
            leftcell.markView.alpha = 0;
        }
    }
}

- (void) unfold{
    [self pinchChange:pinchSensitivity_];
    
    
}

- (void) fold{
    [self pinchChange:-pinchSensitivity];
}


// 捏合运动
- (void) pinchChange:(float)move{
    // move<0 捏合；move>0 展开
    
    // 调整每一页的变换
    for (int i = 0; i < self.photoArray.count; i+=2) {
        
        CALayer *leftLayer = (CALayer *)[self.layerArray objectAtIndex:i];
        CALayer *rightLayer = (CALayer *)[self.layerArray objectAtIndex:i + 1];
        
        NSInteger index = i/2;
        
        //==========================leftlayer=============================
        // lTrans_0
        CATransform3D lTransform3D_0;
        float theta = 0; 
        if (move < 0) {
            //捏合
            theta = (1 + move/pinchSensitivity) * VIEW_MIN_ANGLE;
        }else{
            // 展开
            theta = VIEW_MIN_ANGLE;
        }
        lTransform3D_0 = CATransform3DMakeRotation(M_PI - theta, 0, 1, 0);
        
        // lTrans_1
        CATransform3D lTransform3D_1;
        float lCurrentDistance = 0;
        if (move < 0) {
            // 捏合
            lCurrentDistance = (pageIndex - index) * sinf(theta) * self.frame.size.width;
            
        }else{
            // 展开
            lCurrentDistance =  (pageIndex - index) * zDistance;
        }
        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance);
 
        
        // lTrans_2
        CATransform3D lTransform3D_2;
        float lCurrentAngle = 0;
        if (index <= pageIndex) {
            if (move < 0) {
                lCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE + (M_PI_2 + VIEW_MAX_ANGLE) * (-move)/pinchSensitivity;
            }else{
                lCurrentAngle = -M_PI_2 -VIEW_MAX_ANGLE - (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move/pinchSensitivity_;
            }
            
        }else{
            if (move < 0) {
                lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE - (VIEW_MAX_ANGLE - M_PI_2) * (-move)/pinchSensitivity;
            }else{
                lCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE + (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move/pinchSensitivity_;
            }
        }
       
        lTransform3D_2= CATransform3DMakeRotation(lCurrentAngle, 0, 1, 0);
        
        // lTrans_3
        CATransform3D lTransform3D_3;
        if (move < 0) {
            lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE + (VIEW_Z_MAX_DISTANCE - VIEW_Z_DISTANCE) * (-move)/pinchSensitivity);
        }else{
            lTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE + (VIEW_Z_MIN_DISTANCE - VIEW_Z_DISTANCE) * (move)/pinchSensitivity_);
        }
        
        
        // lTrans
        CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
        
        leftLayer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        
        
        //==========================rightlayer========================
        // rTrans_0
        CATransform3D rTransform3D_0;
        
        theta = 0;
        if (move < 0) {
            //捏合
            theta = (1 + move/pinchSensitivity) * VIEW_MIN_ANGLE;
        }else{
            // 展开
            theta = VIEW_MIN_ANGLE;
        }
        rTransform3D_0 = CATransform3DMakeRotation(theta, 0, 1, 0);
        
        //rTrans_1
        CATransform3D rTransform3D_1;
        float rCurrentDistance = 0;
        if (move < 0) {
            // 捏合
            rCurrentDistance = (pageIndex - index) * sinf(theta) * self.frame.size.width;
            
        }else{
            // 展开
            rCurrentDistance =  (pageIndex - index) * zDistance;
        }
        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance);
        
        //rTrans_2
        CATransform3D rTransform3D_2;
        float rCurrentAngle = 0;
        if (index < pageIndex) {            
            if (move < 0) {
                rCurrentAngle = -M_PI_2 - VIEW_MAX_ANGLE + (VIEW_MAX_ANGLE  + M_PI_2)* (-move)/pinchSensitivity;
            }else{
                rCurrentAngle = -M_PI_2 -VIEW_MAX_ANGLE - (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move/pinchSensitivity_;
            }

        }else{
            if (move < 0) {
                rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE - (VIEW_MAX_ANGLE - M_PI_2) * (-move)/pinchSensitivity;
            }else{
                rCurrentAngle = -M_PI_2 + VIEW_MAX_ANGLE + (M_PI_2-VIEW_MAX_ANGLE - VIEW_MIN_ANGLE) * move/pinchSensitivity_;
            }
        }
     
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle, 0, 1, 0);
        
        // rTrans_3
        CATransform3D rTransform3D_3;
        if (move < 0) {
            rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE + (VIEW_Z_MAX_DISTANCE - VIEW_Z_DISTANCE) * (-move)/pinchSensitivity);
        }else{
            rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE + (VIEW_Z_MIN_DISTANCE - VIEW_Z_DISTANCE) * (move)/pinchSensitivity_);
        }
        
        // rTrans
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
    }
}

// 单手滑动
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
        PaperCell *leftcell = (PaperCell *)[self.photoArray objectAtIndex:i];
        PaperCell *rightcell = (PaperCell *)[self.photoArray objectAtIndex:i+1];
        
        CALayer *leftLayer = (CALayer *)[self.layerArray objectAtIndex:i];
        CALayer *rightLayer = (CALayer *)[self.layerArray objectAtIndex:i + 1];
        
        NSInteger index = i/2;
        
        //==========================leftlayer=============================
        // lTrans_0
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
        

        lTransform3D_1 = CATransform3DMakeTranslation(0, 0, lCurrentDistance + (lNextDistance - lCurrentDistance) * pageRemainder/moveSensitivity);
        lTransform3D_2= CATransform3DMakeRotation(lCurrentAngle + (lNextAngle - lCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        
        // 变换纠偏
        if (lNextAngle == lCurrentAngle) {
            if (move > 0) {
                lTransform3D_1 = CATransform3DMakeTranslation(x , 0, z + ABS(pageIndex - index) * zDistance);
            }else if(move < 0){
                lTransform3D_1 = CATransform3DMakeTranslation(x_ , 0, z_ + ABS(pageIndex - 1 - index) * zDistance);
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

        rTransform3D_1 = CATransform3DMakeTranslation(0, 0, rCurrentDistance + (rNextDistance - rCurrentDistance) * pageRemainder/moveSensitivity);
        rTransform3D_2= CATransform3DMakeRotation(rCurrentAngle + (rNextAngle - rCurrentAngle) * pageRemainder/moveSensitivity, 0, 1, 0);
        
        // 变换纠偏
        if (rNextAngle == rCurrentAngle) {
            if (move > 0) {
                rTransform3D_1 = CATransform3DMakeTranslation(x_, 0, -z_ - ABS(index - pageIndex - 1) * zDistance);
            }else if(move < 0 ){
                rTransform3D_1 = CATransform3DMakeTranslation(x, 0, -z - ABS(index - pageIndex) * zDistance);
            }
        }        
        
        // rTrans_3
        CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, VIEW_Z_DISTANCE);
        
        // rTrans
        CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
        rightLayer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, VIEW_Z_PERSPECTIVE);
        

        // 图层阴影
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

// 滑动
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer{
    // 基于window的点击坐标
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning 显示last screenshot
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        startTouch = touchPoint;
        startPageIndex = pageIndex;
        isMoving = YES;
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        [self resetViewsAnimated:touchPoint];
        isMoving = NO;
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [self resetViewsAnimated:touchPoint];
        isMoving = NO;
        return;
    }
    if (isMoving) {
        float move = [self touchLengthMoveTo:touchPoint];
        [self moveChange:move];
    }
}

// 捏合
- (void) pinchGestureReceive:(UIPinchGestureRecognizer *)recoginzer{
    // 限制为双指操作
    if ([recoginzer numberOfTouches] <= 1) {
        return;
    }
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        isPinching = YES;
        pinchTouch0 = [recoginzer locationOfTouch:0 inView:self];
        pinchTouch1 = [recoginzer locationOfTouch:1 inView:self];
        NSLog(@"(%f,%f) (%f,%f)",pinchTouch0.x,pinchTouch0.y,pinchTouch1.x,pinchTouch1.y);
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        isPinching = NO;
        if (scope < 0 && scope < -100) {
            [UIView animateWithDuration:0.3 animations:^{
                [self fold];
            }];
        }else if(scope > 0 && scope > 100){
            [UIView animateWithDuration:0.3 animations:^{
                [self unfold];
            }];
        }else{
            [self resetViewsAnimated:startTouch];
        }
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        isPinching = NO;
        [self resetViewsAnimated:startTouch];
        return;
    }else if(recoginzer.state == UIGestureRecognizerStateChanged){
        // it keeps move with touch
        if (isPinching) {
            scope = 0;
            CGPoint touch0 = [recoginzer locationOfTouch:0 inView:self];
            CGPoint touch1 = [recoginzer locationOfTouch:1 inView:self];
            
            float x0 = ABS(pinchTouch0.x - pinchTouch1.x);
            float x1 =  ABS(touch0.x - touch1.x);
            
            scope = x1 - x0;
            
            if ((scope < 0 && ABS(scope)<pinchSensitivity)||(scope > 0 && ABS(scope) < pinchSensitivity_)) {
                [self pinchChange:scope];
            }
        }
    }
}
@end
