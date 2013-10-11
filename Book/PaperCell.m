//
//  PaperCell.m
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "PaperCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PaperCell()

@end

@implementation PaperCell
@synthesize photoView;
@synthesize tipsLbl;
@synthesize markView;

- (void) dealloc{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame orientation:(PaperCellOrientation)orientation{
    self = [super initWithFrame:frame];
    if (self) {
        photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        photoView.clipsToBounds = YES;
        photoView.layer.doubleSided = NO;
        [self addSubview:photoView];
        self.clipsToBounds = YES;
        self.layer.doubleSided = NO;
        photoView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        
        tipsLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
        [self addSubview:tipsLbl];
        [tipsLbl release];
        
        if (orientation == PaperCellLeft) {
            photoView.frame = CGRectMake(0, 0, frame.size.width * 2, frame.size.height);
            tipsLbl.frame = CGRectMake(0, 0, 60, 40);
        }else if(orientation == PaperCellRight){
            photoView.frame = CGRectMake(-frame.size.width, 0, frame.size.width * 2, frame.size.height);
            tipsLbl.frame = CGRectMake(frame.size.width - 60, 0, 60, 40);
        }
        
        markView = [[UIView alloc] initWithFrame:self.bounds];
        markView.backgroundColor = [UIColor blackColor];
        markView.alpha = 0;
        [self addSubview:markView];
        [markView release];
    }
    return self;
}

@end
