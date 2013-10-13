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
        photoView.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        
        //photoView.layer.cornerRadius = 10.0f;
        self.layer.borderWidth = 3;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.shouldRasterize = YES;
        
        if (orientation == PaperCellLeft) {
            photoView.frame = CGRectMake(0, 0, frame.size.width * 2, frame.size.height);
        }else if(orientation == PaperCellRight){
            photoView.frame = CGRectMake(-frame.size.width, 0, frame.size.width * 2, frame.size.height);
        }
        
//        self.layer.borderWidth = 3;
//        self.layer.borderColor = [UIColor clearColor].CGColor;

        
        markView = [[UIView alloc] initWithFrame:self.bounds];
        markView.backgroundColor = [UIColor blackColor];
        markView.alpha = 0;
        [self addSubview:markView];
        [markView release];
    }
    return self;
}

@end
