//
//  BookView.m
//  Book
//
//  Created by Dawn on 13-10-6.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "BookView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

// 判断当前ViewController的方向
#define INTERFACE_UNKNOWN               ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationUnknown)
#define INTERFACE_PORTRAIT              ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortrait)
#define INTERFACE_PORTRAITUPSIDEDOWN    ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
#define INTERFACE_LANDSCAPELEFT         ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationLandscapeLeft)
#define INTERFACE_LANDSCAPERIGHT        ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationLandscapeRight)
#define INTERFACE_FACEUP                ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationFaceUp)
#define INTERFACE_FACEDOWN              ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationFaceDown)


#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define VIEW_ANGLE (M_PI/3)
#define VIEW_DISTANCE 100.0
#define VIEW_MOVE 100.0
#define MIN_SCALE 0.6
#define VIEW_MOVE_END 100

@interface BookView()
@property (nonatomic,retain) NSMutableArray *leftPhotoArray;        // 左边图片容器
@property (nonatomic,retain) NSMutableArray *rightPhotoArray;       // 右边图片容器
@property (nonatomic,retain) NSArray *urlArray;                     // 图片地址
@end

@implementation BookView
@synthesize leftPhotoArray;
@synthesize rightPhotoArray;
@synthesize urlArray;
@synthesize coverImage;

- (void) dealloc{
    self.leftPhotoArray = nil;
    self.rightPhotoArray = nil;
    self.urlArray = nil;
    self.coverImage = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame photoUrls:(NSArray *)urls{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 图片地址
        self.urlArray = [NSArray arrayWithArray:urls];
        
        // 图片容器
        self.leftPhotoArray = [NSMutableArray arrayWithCapacity:0];
        self.rightPhotoArray = [NSMutableArray arrayWithCapacity:0];
        
        for (NSString *photoUrl in self.urlArray) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height)];
            contentView.clipsToBounds = YES;
            contentView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
            contentView.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView setImageWithURL:[NSURL URLWithString:photoUrl] options:SDWebImageRetryFailed progress:YES];
            [contentView addSubview:imageView];
            [imageView release];
            [self addSubview:contentView];
            [contentView release];
            [self.leftPhotoArray addObject:contentView];
            
        }
        
        for (NSString *photoUrl in self.urlArray) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height)];
            contentView.clipsToBounds = YES;
            contentView.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
            contentView.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-frame.size.width/2, 0, frame.size.width, frame.size.height)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView setImageWithURL:[NSURL URLWithString:photoUrl] options:SDWebImageRetryFailed progress:YES];
            [contentView addSubview:imageView];
            [imageView release];
            [self addSubview:contentView];
            [contentView release];
            [self.rightPhotoArray addObject:contentView];
            
        }
        
        // 所有图片按顺序排列
        [self resetLeftViews];
        
        [self resetRightViews];
        
        // 添加手势
        UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                     action:@selector(paningGestureReceive:)]autorelease];
        [self addGestureRecognizer:panGesture];

    }
    return self;
}

- (void) resetLeftViews{
    for (int i = 0; i < self.leftPhotoArray.count;i++) {
        UIView *contentView = (UIView *)[self.leftPhotoArray objectAtIndex:i];
        CATransform3D transform3D = CATransform3DIdentity;
        transform3D.m34 = -1.0f/1500;			//透视效果
        transform3D = CATransform3DRotate(transform3D,VIEW_ANGLE * (i + 1)/self.leftPhotoArray.count, 0, 1, 0);
        transform3D = CATransform3DScale(transform3D, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.leftPhotoArray.count, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.leftPhotoArray.count, 1);
        
        transform3D = CATransform3DTranslate(transform3D, -(VIEW_MOVE - VIEW_MOVE * (i + 1)*(i + 1)/(self.leftPhotoArray.count * self.leftPhotoArray.count)), 0, 0);
        
        contentView.layer.transform = transform3D;
    }
}

- (void) resetRightViews{
    for (int i = 0; i < self.rightPhotoArray.count;i++) {
        UIView *contentView = (UIView *)[self.rightPhotoArray objectAtIndex:i];
        CATransform3D transform3D = CATransform3DIdentity;
        transform3D.m34 = -1.0f/1500;			//透视效果
        transform3D = CATransform3DRotate(transform3D,-VIEW_ANGLE * (i + 1)/self.rightPhotoArray.count, 0, 1, 0);
        transform3D = CATransform3DScale(transform3D, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.rightPhotoArray.count, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.rightPhotoArray.count, 1);
        transform3D = CATransform3DTranslate(transform3D,(VIEW_MOVE - VIEW_MOVE * (i + 1)*(i + 1)/(self.rightPhotoArray.count * self.rightPhotoArray.count)), 0, 0);
        
        contentView.layer.transform = transform3D;
    }
}

- (void) moveLeftViews:(float)move{
    NSInteger count = self.leftPhotoArray.count - 1;
    for (int i = 0; i < count; i++) {
        UIView *contentView = (UIView *)[self.leftPhotoArray objectAtIndex:i];
        CATransform3D transform3D = CATransform3DIdentity;
        transform3D.m34 = -1.0f/1500;			//透视效果
        float angle = VIEW_ANGLE * (i + 1)/(count + 1) + (VIEW_ANGLE * (i + 1)/count - VIEW_ANGLE * (i + 1)/(count + 1)) * move/VIEW_MOVE_END;
        transform3D = CATransform3DRotate(transform3D, angle, 0, 1, 0);
        
        float scale = MIN_SCALE + (1-MIN_SCALE)*(i + 1)/(count + 1) + ((1-MIN_SCALE) * (i + 1)/count - (1-MIN_SCALE) * (i + 1)/(count + 1))*move/VIEW_MOVE_END;
        transform3D = CATransform3DScale(transform3D,scale ,scale, 1);
        
        float moveX = -(VIEW_MOVE - VIEW_MOVE * (i + 1)*(i + 1)/((count + 1) * (count + 1)) - (VIEW_MOVE * (i + 1)*(i+1)/(count * count) - VIEW_MOVE * (i + 1) * (i + 1)/((count + 1) *(count + 1)))*move/VIEW_MOVE_END);
        transform3D = CATransform3DTranslate(transform3D, moveX, 0, 0);
        
        contentView.layer.transform = transform3D;
    }
}

- (void) moveRightViews:(float)move{
    NSInteger count = self.rightPhotoArray.count - 1;
    for (int i = 0; i < count; i++) {
        UIView *contentView = (UIView *)[self.rightPhotoArray objectAtIndex:i];
        CATransform3D transform3D = CATransform3DIdentity;
        transform3D.m34 = -1.0f/1500;			//透视效果
        float angle = VIEW_ANGLE * (i + 1)/(count + 1) + (VIEW_ANGLE * (i + 1)/count - VIEW_ANGLE * (i + 1)/(count + 1)) * move/VIEW_MOVE_END;
        transform3D = CATransform3DRotate(transform3D, -angle, 0, 1, 0);
        
        float scale = MIN_SCALE + (1-MIN_SCALE)*(i + 1)/(count + 1) + ((1-MIN_SCALE) * (i + 1)/count - (1-MIN_SCALE) * (i + 1)/(count + 1))*move/VIEW_MOVE_END;
        transform3D = CATransform3DScale(transform3D,scale ,scale, 1);
        
        float moveX = -(VIEW_MOVE - VIEW_MOVE * (i + 1)*(i + 1)/((count + 1) * (count + 1)) - (VIEW_MOVE * (i + 1)*(i+1)/(count * count) - VIEW_MOVE * (i + 1) * (i + 1)/((count + 1) *(count + 1)))*move/VIEW_MOVE_END);
        transform3D = CATransform3DTranslate(transform3D, -moveX, 0, 0);
        
        contentView.layer.transform = transform3D;
    }
}

- (float) touchLengthMoveTo:(CGPoint)touchPoint{
    
    if (INTERFACE_PORTRAIT) {
        return touchPoint.x - startTouch.x;
    }else if(INTERFACE_PORTRAITUPSIDEDOWN){
        return startTouch.x - touchPoint.x;
    }else if(INTERFACE_LANDSCAPELEFT){
        return touchPoint.y - startTouch.y;
    }else if(INTERFACE_LANDSCAPERIGHT){
        return startTouch.y - touchPoint.y;
    }
    return 0;
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer{
    
    // 基于window的点击坐标
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning 显示last screenshot
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
       
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        float move = [self touchLengthMoveTo:touchPoint];
        NSLog(@"%f",move);
        if (move > VIEW_MOVE_END){
            // 向右滑动
            UIView *contentView = (UIView *)[self.leftPhotoArray lastObject];
            contentView.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
            contentView.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height);
            [self.rightPhotoArray addObject:contentView];
            [self.leftPhotoArray removeLastObject];
            
            NSInteger index = self.leftPhotoArray.count - 1;
            if (index >= self.urlArray.count) {
                index = index - self.urlArray.count;
            }
            UIImageView *imageView = (UIImageView *)[[contentView subviews] objectAtIndex:0];
            [imageView setImageWithURL:[NSURL URLWithString:[self.urlArray objectAtIndex:index]] options:SDWebImageRetryFailed progress:YES];
            
            imageView.frame = CGRectMake(-self.frame.size.width/2, 0, self.frame.size.width, self.frame.size.height);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self resetLeftViews];
                [self resetRightViews];
            }];
        }else if(move < -VIEW_MOVE_END){
            // 向左滑动
            UIView *contentView = (UIView *)[self.rightPhotoArray lastObject];
            contentView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
            contentView.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
            [self.leftPhotoArray addObject:contentView];
            [self.rightPhotoArray removeLastObject];
            
            NSInteger index = self.rightPhotoArray.count - 1;
            if (index >= self.urlArray.count) {
                index = index - self.urlArray.count;
            }
            UIImageView *imageView = (UIImageView *)[[contentView subviews] objectAtIndex:0];
            [imageView setImageWithURL:[NSURL URLWithString:[self.urlArray objectAtIndex:index]] options:SDWebImageRetryFailed progress:YES];
            
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self resetLeftViews];
                [self resetRightViews];
            }];
        }
        else{
            [UIView animateWithDuration:0.2 animations:^{
                [self resetLeftViews];
                [self resetRightViews];
            }];
        }
        return;
        // cancal panning 回弹
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [self resetLeftViews];
        [self resetRightViews];
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        float move = [self touchLengthMoveTo:touchPoint];
        if (move > VIEW_MOVE_END || move < -VIEW_MOVE_END) {
            if (move > VIEW_MOVE_END) {
                UIView *contentView = (UIView *)[self.leftPhotoArray lastObject];
                CATransform3D transform3D = CATransform3DIdentity;
                transform3D.m34 = -1.0f/1500;			//透视效果
                transform3D = CATransform3DRotate(transform3D,VIEW_ANGLE + (M_PI_2 - VIEW_ANGLE) * move/VIEW_MOVE_END, 0, 1, 0);
                contentView.layer.transform = transform3D;
                
                [self moveLeftViews:VIEW_MOVE_END];
            }else if(move < -VIEW_MOVE_END){
                move = -move;
                UIView *contentView = (UIView *)[self.rightPhotoArray lastObject];
                CATransform3D transform3D = CATransform3DIdentity;
                transform3D.m34 = -1.0f/1500;			//透视效果
                transform3D = CATransform3DRotate(transform3D,-VIEW_ANGLE - (M_PI_2 - VIEW_ANGLE) * move/VIEW_MOVE_END, 0, 1, 0);
                contentView.layer.transform = transform3D;
                
                [self moveRightViews:VIEW_MOVE_END];
            }
            return;
        }
        if (move > 0) {
            // 向右滑动
            UIView *contentView = (UIView *)[self.leftPhotoArray lastObject];
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -1.0f/1500;			//透视效果
            transform3D = CATransform3DRotate(transform3D,VIEW_ANGLE + (M_PI_2 - VIEW_ANGLE) * move/VIEW_MOVE_END, 0, 1, 0);
            contentView.layer.transform = transform3D;

            [self moveLeftViews:move];
        }else if(move < 0){
            move = -move;
            // 向左滑动
            UIView *contentView = (UIView *)[self.rightPhotoArray lastObject];
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -1.0f/1500;			//透视效果
            transform3D = CATransform3DRotate(transform3D,-VIEW_ANGLE - (M_PI_2 - VIEW_ANGLE) * move/VIEW_MOVE_END, 0, 1, 0);
            contentView.layer.transform = transform3D;
            
            [self moveRightViews:move];
        }
    }
}


- (void) layoutSubviews{
    [super layoutSubviews];
    
}



@end
