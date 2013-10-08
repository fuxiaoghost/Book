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
        self.backgroundColor = [UIColor whiteColor];
        
        if (orientation == PaperCellLeft) {
            photoView.frame = CGRectMake(0, 0, frame.size.width * 2, frame.size.height);
        }else if(orientation == PaperCellRight){
            photoView.frame = CGRectMake(-frame.size.width, 0, frame.size.width * 2, frame.size.height);
        }
    }
    return self;
}

@end
