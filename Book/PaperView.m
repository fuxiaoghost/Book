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

#define VIEW_ANGLE (M_PI_4/4)


@interface PaperView()
@property (nonatomic,retain) NSMutableArray *photoArray;        // 图片容器
@property (nonatomic,retain) NSArray *urlArray;                     // 图片地址
@end

@implementation PaperView

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

        float zDistance = sinf(VIEW_ANGLE) * frame.size.width;
        for (int i = 0; i < self.photoArray.count; i+=2) {
            PaperCell *leftcell = (PaperCell *)[self.photoArray objectAtIndex:i];
            PaperCell *rightcell = (PaperCell *)[self.photoArray objectAtIndex:i+1];
            
            CATransform3D lTransform3D_0 = CATransform3DMakeRotation(M_PI - VIEW_ANGLE, 0, 1, 0);
            CATransform3D lTransform3D_1 = CATransform3DMakeTranslation(0, 0, -i*zDistance/2);
            CATransform3D lTransform3D_2 = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
            CATransform3D lTransform3D_3 = CATransform3DMakeTranslation(0, 0, -200);
            CATransform3D lTransfrom3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(lTransform3D_0, lTransform3D_1), lTransform3D_2), lTransform3D_3);
            leftcell.layer.transform = CATransform3DPerspect(lTransfrom3D, CGPointZero, 500);
            
            CATransform3D rTransform3D_0 = CATransform3DMakeRotation(VIEW_ANGLE, 0, 1, 0);
            CATransform3D rTransform3D_1 = CATransform3DMakeTranslation(0, 0, -i*zDistance/2);
            CATransform3D rTransform3D_2 = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
            CATransform3D rTransform3D_3 = CATransform3DMakeTranslation(0, 0, -200);
            CATransform3D rTransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(rTransform3D_0, rTransform3D_1), rTransform3D_2), rTransform3D_3);
            rightcell.layer.transform = CATransform3DPerspect(rTransform3D, CGPointZero, 500);
        }
    }
    return self;
}

@end
