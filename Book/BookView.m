//
//  BookView.m
//  Book
//
//  Created by Dawn on 13-10-6.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "BookView.h"
#import "UIImageView+WebCache.h"

#define VIEW_ANGLE M_PI_4
#define VIEW_DISTANCE 100.0
#define VIEW_MOVE 100.0
#define MIN_SCALE 0.6

@interface BookView()
@property (nonatomic,retain) NSMutableArray *leftPhotoArray;        // 左边图片容器
@property (nonatomic,retain) NSMutableArray *rightPhotoArray;       // 右边图片容器
@property (nonatomic,retain) NSArray *urlArray;                     // 图片地址
@end

@implementation BookView
@synthesize leftPhotoArray;
@synthesize rightPhotoArray;
@synthesize urlArray;

- (void) dealloc{
    self.leftPhotoArray = nil;
    self.rightPhotoArray = nil;
    self.urlArray = nil;
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
        
        // 选择
        for (int i = 0; i < self.leftPhotoArray.count;i++) {
            UIView *contentView = (UIView *)[self.leftPhotoArray objectAtIndex:i];
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -1.0f/1500;			//透视效果
            transform3D = CATransform3DRotate(transform3D,VIEW_ANGLE * (i + 1)/self.leftPhotoArray.count, 0, 1, 0);
            transform3D = CATransform3DScale(transform3D, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.leftPhotoArray.count, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.leftPhotoArray.count, 1);
            transform3D = CATransform3DTranslate(transform3D, - (VIEW_MOVE - VIEW_MOVE * (i + 1) / self.leftPhotoArray.count), 0, 0);
            
            contentView.layer.transform = transform3D;
        }
        
        for (int i = 0; i < self.rightPhotoArray.count;i++) {
            UIView *contentView = (UIView *)[self.rightPhotoArray objectAtIndex:i];
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -1.0f/1500;			//透视效果
            transform3D = CATransform3DRotate(transform3D,-VIEW_ANGLE * (i + 1)/self.rightPhotoArray.count, 0, 1, 0);
            transform3D = CATransform3DScale(transform3D, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.rightPhotoArray.count, MIN_SCALE + (1 - MIN_SCALE) * (i + 1) / self.rightPhotoArray.count, 1);
            transform3D = CATransform3DTranslate(transform3D,(VIEW_MOVE - VIEW_MOVE * (i + 1) / self.rightPhotoArray.count), 0, 0);
            
            contentView.layer.transform = transform3D;
        }
        
        
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
