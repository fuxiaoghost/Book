//
//  PaperCell.m
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "PaperCell.h"

@interface PaperCell()
@property (nonatomic,readonly) UIImageView *photoView;
@end

@implementation PaperCell

- (void) dealloc{
    self.photoView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame orientation:(PaperCellOrientation)orientation{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

@end
